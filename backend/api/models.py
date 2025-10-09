from django.db import models
from django.contrib.auth.models import AbstractUser
from django.contrib.gis.db import models as gis_models
from django.conf import settings

class CustomUser(AbstractUser):
    CARGO_CHOICES = [
        ('tecnico', 'Técnico'),
        ('admin', 'Admin'),
        ('operador', 'Operador'),
    ]
    SITUACAO_CHOICES = [
        ('ativo', 'Ativo'),
        ('desativado', 'Desativado'),
    ]

    telefone = models.CharField(max_length=15, blank=True, null=True)
    cargo = models.CharField(max_length=10, choices=CARGO_CHOICES, default='tecnico')
    situacao = models.CharField(max_length=10, choices=SITUACAO_CHOICES, default='ativo')

    def __str__(self):
        return self.username


# Modelo para os Ativos
class Ativo(models.Model):
    nome = models.CharField(max_length=255)
    marca = models.CharField(max_length=255)
    modelo = models.CharField(max_length=255)
    periodicidade = models.IntegerField()
    manual = models.FileField(upload_to='manuais/', blank=True, null=True)
    endereco = models.CharField(max_length=255)
    # GeoDjango: Um único campo para guardar o ponto geográfico (longitude, latitude).
    localizacao = gis_models.PointField()
    mtbf = models.CharField(max_length=100, blank=True, default="N/A")
    mttr = models.CharField(max_length=100, blank=True, default="N/A")

    def __str__(self):
        return self.nome
    

class OrdemServico(models.Model):
    TIPO_CHOICES = [
        ('corretiva', 'Corretiva'),
        ('preditiva', 'Preditiva'),
        ('preventiva', 'Preventiva'),
    ]
    STATUS_CHOICES = [
        ('pendente', 'Pendente'),
        ('finalizada', 'Finalizada'),
    ]

    titulo = models.CharField(max_length=255)
    tipo = models.CharField(max_length=20, choices=TIPO_CHOICES)
    descricao = models.TextField(blank=True, null=True)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pendente')
    ativo = models.ForeignKey(Ativo, on_delete=models.SET_NULL, null=True, related_name='ordens_servico')
    data_criacao = models.DateTimeField(auto_now_add=True)
    data_prevista = models.DateTimeField()
    solicitante = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True, related_name='os_solicitadas')

    def __str__(self):
        return f"O.S. #{self.id} - {self.titulo}"
