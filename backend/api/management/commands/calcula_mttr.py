# api/management/commands/calcula_mttr.py
from django.core.management.base import BaseCommand
from django.db import transaction
from django.db.models import Sum, Count
from django.utils import timezone
import datetime
import math

# imports com nomes exatos dos seus modelos
from api.models import Ativo, OrdemServico, Manutencao


class Command(BaseCommand):
    help = 'Calcula e atualiza o MTTR (em minutos) de cada Ativo com base nas manutenções de ordens finalizadas. Por padrão grava as alterações no banco; use --dry-run para apenas simular.'

    def add_arguments(self, parser):
        parser.add_argument(
            '--dry-run',
            action='store_true',
            help='Se passado, NÃO grava alterações no banco (simula apenas). Por padrão o comando grava as alterações.'
        )
        parser.add_argument(
            '--ativo-id',
            type=int,
            help='Calcula apenas para o ativo com este id (opcional).'
        )
        parser.add_argument(
            '--status',
            type=str,
            default='finalizada',
            help="Status das ordens a considerar (padrão: 'finalizada')."
        )

    def handle(self, *args, **options):
        dry_run = options.get('dry_run', False)
        ativo_id = options.get('ativo_id')
        status_filter = options.get('status')

        started = timezone.now()
        self.stdout.write(self.style.NOTICE(f'Iniciando cálculo de MTTR - {started}'))
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
                # Relacionamento reverso 'ordens_servico' (related_name)
                ordens_finalizadas_qs = ativo.ordens_servico.filter(status__iexact=status_filter)

                if not ordens_finalizadas_qs.exists():
                    novo_mttr = 0
                    self.stdout.write(f'Ativo {ativo.id} ({ativo}): nenhuma O.S. finalizada encontrada — novo_mttr={novo_mttr}')
                else:
                    manutencoes_qs = Manutencao.objects.filter(ordem_servico__in=ordens_finalizadas_qs)
                    agg = manutencoes_qs.aggregate(total_tempo=Sum('tempo_gasto'), qtd=Count('pk'))

                    total_tempo = agg.get('total_tempo')  # timedelta ou None
                    qtd = agg.get('qtd') or 0

                    if not total_tempo or qtd == 0:
                        novo_mttr = 0
                    else:
                        if isinstance(total_tempo, datetime.timedelta):
                            total_seconds = total_tempo.total_seconds()
                            avg_seconds = total_seconds / qtd
                            novo_mttr = int(math.floor(avg_seconds / 60.0))  # média em minutos (inteiro)
                        else:
                            novo_mttr = int(total_tempo) // int(qtd)

                    self.stdout.write(
                        f'Ativo {ativo.id} ({str(ativo)}): manut_count={qtd} total_tempo={total_tempo} => novo_mttr={novo_mttr} minutos'
                    )

                # Atualiza somente se for diferente
                if ativo.mttr != novo_mttr:
                    if dry_run:
                        self.stdout.write(self.style.WARNING(
                            f'[DRY-RUN] Ativo {ativo.id}: mttr atual={ativo.mttr} -> novo={novo_mttr} (não gravado)'
                        ))
                        total_atualizados += 1  # conta como "mudança prevista" no dry-run
                    else:
                        with transaction.atomic():
                            ativo.mttr = novo_mttr
                            ativo.save(update_fields=['mttr'])
                        self.stdout.write(self.style.SUCCESS(
                            f'Ativo {ativo.id}: mttr atualizado {ativo.mttr} -> {novo_mttr}'
                        ))
                        total_atualizados += 1
                else:
                    total_sem_alteracao += 1
                    self.stdout.write(f'Ativo {ativo.id}: sem alteração (mttr permanece {ativo.mttr}).')

            except Exception as e:
                erros += 1
                self.stdout.write(self.style.ERROR(f'Erro ao processar ativo {ativo.id}: {e}'))

        ended = timezone.now()
        duration = ended - started
        self.stdout.write(self.style.SUCCESS(
            f'-------------- Concluído. -------------- \nProcessados: {total_processados}.\nAtualizados: {total_atualizados}. \nSem alteração: {total_sem_alteracao}. \nErros: {erros}.'
        ))


