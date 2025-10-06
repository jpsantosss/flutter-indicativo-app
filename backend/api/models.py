from django.db import models
from django.contrib.auth.models import AbstractUser
from django.contrib.gis.db import models as gis_models

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

    def __str__(self):
        return self.nome