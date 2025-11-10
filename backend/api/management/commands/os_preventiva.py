# api/management/commands/os_preventiva.py
from django.core.management.base import BaseCommand
from django.db import transaction
from django.utils import timezone
from django.conf import settings
import datetime

from api.models import Ativo, OrdemServico, Manutencao


class Command(BaseCommand):
    help = (
        "Gera ordens de serviço preventivas com base na periodicidade dos ativos.\n\n"
        "Regras:\n"
        "1) Se não existir nenhuma OS do tipo 'preventiva' para o ativo → cria uma OS com data_prevista = hoje + periodicidade dias.\n"
        "2) Se existir alguma OS preventiva com status 'pendente' → não gera nova OS.\n"
        "3) Se existirem apenas OS preventivas finalizadas → gera nova OS com data_prevista = última_manutencao_finalizada.data_fim_execucao + periodicidade dias.\n\n"
        "Por padrão grava no banco; utilize --dry-run para simular sem persistir."
    )

    def add_arguments(self, parser):
        parser.add_argument(
            '--dry-run',
            action='store_true',
            help='Simula a execução sem gravar nada no banco.'
        )
        parser.add_argument(
            '--ativo-id',
            type=int,
            help='Executa apenas para o ativo com este id (opcional).'
        )
        parser.add_argument(
            '--tipo',
            type=str,
            default='preventiva',
            help="Tipo de ordem a considerar (padrão: 'preventiva')."
        )

    def handle(self, *args, **options):
        dry_run = options.get('dry_run', False)
        ativo_id = options.get('ativo_id')
        tipo_preventiva = options.get('tipo', 'preventiva')

        now = timezone.now()
        self.stdout.write(self.style.NOTICE(f'Iniciando geração OS preventiva - {now}'))
        if dry_run:
            self.stdout.write(self.style.WARNING('MODO DRY-RUN: nenhuma alteração será persistida.'))

        ativos_qs = Ativo.objects.all()
        if ativo_id:
            ativos_qs = ativos_qs.filter(pk=ativo_id)

        total = 0
        criadas = 0
        puladas = 0
        erros = 0

        for ativo in ativos_qs:
            total += 1
            try:
                periodicidade_days = int(ativo.periodicidade or 0)
                if periodicidade_days <= 0:
                    self.stdout.write(self.style.WARNING(
                        f'Ativo {ativo.id} ({ativo}): periodicidade inválida ({ativo.periodicidade}), pulando.'
                    ))
                    puladas += 1
                    continue

                # todas as ordens do tipo preventiva deste ativo
                ordens_preventivas_qs = ativo.ordens_servico.filter(tipo__iexact=tipo_preventiva)

                # Caso 1: não tem nenhuma preventiva -> criar para hoje + periodicidade
                if not ordens_preventivas_qs.exists():
                    suggested_date = now + datetime.timedelta(days=periodicidade_days)
                    # set date_prevista time to same time as now (or midnight if you prefer)
                    suggested_date = suggested_date.replace(microsecond=0)
                    self.stdout.write(
                        f'Ativo {ativo.id} ({ativo}): nenhuma OS preventiva encontrada -> sugerindo data_prevista {suggested_date}'
                    )

                    if not dry_run:
                        with transaction.atomic():
                            OrdemServico.objects.create(
                                titulo='Preventiva automática',
                                tipo=tipo_preventiva,
                                descricao='Ordens preventiva gerada automaticamente pelo comando os_preventiva.',
                                status='pendente',
                                ativo=ativo,
                                data_prevista=suggested_date,
                            )
                        criadas += 1
                    else:
                        criadas += 1  # contar como prevista em dry-run

                    continue

                # Caso 2: se existir alguma preventiva pendente -> não gera
                if ordens_preventivas_qs.filter(status__iexact='pendente').exists():
                    self.stdout.write(
                        f'Ativo {ativo.id} ({ativo}): existe OS preventiva com status PENDENTE -> nenhuma ação.'
                    )
                    puladas += 1
                    continue

                # Caso 3: existem preventivas, mas não pendentes => verificar últimas finalizadas
                ordens_finalizadas = ordens_preventivas_qs.filter(status__iexact='finalizada')
                if not ordens_finalizadas.exists():
                    # não há pendentes, nem finalizadas (talvez outras statuses) -> criar baseada em hoje
                    suggested_date = now + datetime.timedelta(days=periodicidade_days)
                    self.stdout.write(
                        f'Ativo {ativo.id} ({ativo}): preventivas existem mas sem PENDENTE/Nem FINALIZADA clara -> sugerindo {suggested_date}'
                    )
                    if not dry_run:
                        with transaction.atomic():
                            OrdemServico.objects.create(
                                titulo='Preventiva automática',
                                tipo=tipo_preventiva,
                                descricao='Ordens preventiva gerada automaticamente pelo comando os_preventiva.',
                                status='pendente',
                                ativo=ativo,
                                data_prevista=suggested_date,
                            )
                        criadas += 1
                    else:
                        criadas += 1
                    continue

                # Temos ordens_finalizadas -> queremos o último data_fim_execucao da manutenção ligada a essas ordens
                # Buscamos manutenções associadas
                manut_qs = Manutencao.objects.filter(ordem_servico__in=ordens_finalizadas).order_by('-data_fim_execucao')

                if not manut_qs.exists():
                    # não encontramos manutenções nem com finalizadas -> fallback usar data_prevista da última OS finalizada
                    ultima_ordem = ordens_finalizadas.order_by('-data_prevista').first()
                    if ultima_ordem and ultima_ordem.data_prevista:
                        base_date = ultima_ordem.data_prevista
                    else:
                        base_date = now
                    suggested_date = base_date + datetime.timedelta(days=periodicidade_days)
                    self.stdout.write(
                        f'Ativo {ativo.id} ({ativo}): ordens finalizadas sem manutenção associada -> usando ultima.data_prevista {base_date} -> sugerindo {suggested_date}'
                    )
                else:
                    ultima_manut = manut_qs.first()
                    base_date = ultima_manut.data_fim_execucao
                    suggested_date = base_date + datetime.timedelta(days=periodicidade_days)
                    self.stdout.write(
                        f'Ativo {ativo.id} ({ativo}): ultima manut finalizada em {base_date} -> sugerindo {suggested_date}'
                    )

                # Evitar criar duplicatas: verificar se já existe uma preventiva com data_prevista na mesma data
                exists_same_date = ordens_preventivas_qs.filter(data_prevista__date=suggested_date.date()).exists()
                if exists_same_date:
                    self.stdout.write(
                        f'Ativo {ativo.id} ({ativo}): já existe OS preventiva agendada para a data {suggested_date.date()} -> pulando.'
                    )
                    puladas += 1
                    continue

                # Criar nova OS preventiva com data_prevista calculada
                if not dry_run:
                    with transaction.atomic():
                        OrdemServico.objects.create(
                            titulo='Preventiva automática',
                            tipo=tipo_preventiva,
                            descricao='Ordem preventiva gerada automaticamente.',
                            status='pendente',
                            ativo=ativo,
                            data_prevista=suggested_date,
                        )
                    criadas += 1
                    self.stdout.write(self.style.SUCCESS(
                        f'Ativo {ativo.id}: OS preventiva criada com data_prevista {suggested_date}'
                    ))
                else:
                    criadas += 1
                    self.stdout.write(self.style.WARNING(
                        f'[DRY-RUN] Ativo {ativo.id}: OS preventiva SIMULADA com data_prevista {suggested_date}'
                    ))

            except Exception as e:
                erros += 1
                self.stdout.write(self.style.ERROR(f'Erro ao processar ativo {ativo.id}: {e}'))

        self.stdout.write(self.style.SUCCESS(
            f'Finalizado. \nAtivos processados: {total}. \nOS criadas: {criadas}. \nPuladas: {puladas}. \nErros: {erros}.'
        ))


