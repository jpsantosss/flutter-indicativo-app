# api/management/commands/calcula_mtbf.py
from django.core.management.base import BaseCommand
from django.db import transaction
from django.utils import timezone
import datetime
import math

from api.models import Ativo, OrdemServico, Manutencao


class Command(BaseCommand):
    help = (
        "Calcula e atualiza o MTBF (em minutos) de cada Ativo usando EXCLUSIVAMENTE "
        "o intervalo Manutencao.data_fim_execucao -> OrdemServico.data_criacao (próxima OS corretiva).\n"
        "MTBF = (soma de todos esses intervalos) / (número de falhas = número de OS corretivas).\n"
        "Por padrão grava as alterações no banco; use --dry-run para simular."
    )

    def add_arguments(self, parser):
        parser.add_argument(
            '--dry-run',
            action='store_true',
            help='Se passado, NÃO grava alterações no banco (simula apenas).'
        )
        parser.add_argument(
            '--ativo-id',
            type=int,
            help='Calcula apenas para o ativo com este id (opcional).'
        )
        parser.add_argument(
            '--tipo',
            type=str,
            default='corretiva',
            help="Tipo de ordem a considerar (padrão: 'corretiva')."
        )

    def handle(self, *args, **options):
        dry_run = options.get('dry_run', False)
        ativo_id = options.get('ativo_id')
        tipo_filter = options.get('tipo')

        started = timezone.now()
        self.stdout.write(self.style.NOTICE(f'Iniciando cálculo de MTBF (fim_manut -> ordem.criacao) - {started}'))
        if dry_run:
            self.stdout.write(self.style.WARNING('MODO DRY-RUN: nenhuma alteração será persistida.'))

        ativos_qs = Ativo.objects.all()
        if ativo_id:
            ativos_qs = ativos_qs.filter(pk=ativo_id)

        total_processados = 0
        total_atualizados = 0
        total_sem_alteracao = 0
        erros = 0

        for ativo in ativos_qs:
            total_processados += 1
            try:
                # pegar ordens do tipo corretiva ordenadas por criação
                ordens_corretivas = ativo.ordens_servico.filter(tipo__iexact=tipo_filter).order_by('data_criacao')
                n_failures = ordens_corretivas.count()

                if n_failures == 0:
                    novo_mtbf = 0
                    novo_mtbf_float = 0.0
                    self.stdout.write(f'Ativo {ativo.id} ({ativo}): sem ordens do tipo "{tipo_filter}" — novo_mtbf={novo_mtbf}')
                else:
                    # montamos map de manutenções por ordem_id (se existir)
                    manut_map = {}
                    manut_qs = Manutencao.objects.filter(ordem_servico__in=ordens_corretivas)
                    for m in manut_qs:
                        manut_map[m.ordem_servico_id] = m

                    ordens_list = list(ordens_corretivas)
                    operation_intervals = []

                    # percorre pares (ordem_i, ordem_j) e calcula:
                    # intervalo = manut_of_i.data_fim_execucao -> ordem_j.data_criacao
                    for idx in range(len(ordens_list) - 1):
                        ordem_atual = ordens_list[idx]
                        ordem_proxima = ordens_list[idx + 1]

                        manut_atual = manut_map.get(ordem_atual.id)
                        data_fim_execucao_atual = getattr(manut_atual, 'data_fim_execucao', None) if manut_atual else None
                        data_criacao_proxima = getattr(ordem_proxima, 'data_criacao', None)

                        if data_fim_execucao_atual and data_criacao_proxima:
                            # só usamos este intervalo se data_criacao_proxima for posterior ao fim da manut anterior
                            if data_criacao_proxima > data_fim_execucao_atual:
                                interval = data_criacao_proxima - data_fim_execucao_atual
                                operation_intervals.append(interval)
                                self.stdout.write(
                                    f'Ativo {ativo.id}: intervalo (ordem {ordem_atual.id} fim_manut={data_fim_execucao_atual} -> '
                                    f'ordem {ordem_proxima.id} criacao={data_criacao_proxima}) = {interval}'
                                )
                            else:
                                self.stdout.write(
                                    f'Ativo {ativo.id}: ordem_proxima.data_criacao ({data_criacao_proxima}) <= prev.data_fim_execucao ({data_fim_execucao_atual}) — intervalo ignorado.'
                                )
                        else:
                            self.stdout.write(
                                f'Ativo {ativo.id}: dados ausentes para intervalo entre ordens {ordem_atual.id} -> {ordem_proxima.id} '
                                f'(prev.fim={data_fim_execucao_atual}, next.criacao={data_criacao_proxima}) — ignorando.'
                            )

                    # soma todos os intervals e divide por número de falhas (n_failures)
                    if not operation_intervals:
                        novo_mtbf = 0
                        novo_mtbf_float = 0.0
                        self.stdout.write(f'Ativo {ativo.id}: nenhum intervalo calculável — novo_mtbf=0')
                    else:
                        total_seconds = sum([td.total_seconds() for td in operation_intervals])
                        novo_mtbf_float = (total_seconds / n_failures) / 60.0  # minutos (float)
                        novo_mtbf = int(round(novo_mtbf_float))  # salvar como inteiro arredondado
                        self.stdout.write(
                            f'Ativo {ativo.id}: total_operational_seconds={total_seconds} total_intervals={len(operation_intervals)} '
                            f'n_failures={n_failures} => mtbf_float={novo_mtbf_float:.6f} min => mtbf_saved={novo_mtbf} min (arredondado)'
                        )

                # grava apenas se diferente
                if ativo.mtbf != novo_mtbf:
                    if dry_run:
                        self.stdout.write(self.style.WARNING(
                            f'[DRY-RUN] Ativo {ativo.id}: mtbf atual={ativo.mtbf} -> novo={novo_mtbf} (não gravado)'
                        ))
                        # considerar como "mudança prevista" no dry-run
                        total_atualizados += 1
                    else:
                        old = ativo.mtbf
                        with transaction.atomic():
                            ativo.mtbf = novo_mtbf
                            ativo.save(update_fields=['mtbf'])
                        self.stdout.write(self.style.SUCCESS(
                            f'Ativo {ativo.id}: mtbf atualizado {old} -> {novo_mtbf} (float calculado: {novo_mtbf_float:.6f})'
                        ))
                        total_atualizados += 1
                else:
                    total_sem_alteracao += 1
                    self.stdout.write(f'Ativo {ativo.id}: sem alteração (mtbf permanece {ativo.mtbf}).')

            except Exception as e:
                erros += 1
                self.stdout.write(self.style.ERROR(f'Erro ao processar ativo {ativo.id}: {e}'))

        ended = timezone.now()
        duration = ended - started
        self.stdout.write(self.style.SUCCESS(
            f'-------------- Concluído. -------------- \nProcessados: {total_processados}.\nAtualizados: {total_atualizados}. \nSem alteração: {total_sem_alteracao}. \nErros: {erros}.'
        ))



