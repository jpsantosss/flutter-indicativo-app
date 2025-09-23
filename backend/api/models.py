from django.db import models
from django.contrib.auth.models import AbstractUser

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
