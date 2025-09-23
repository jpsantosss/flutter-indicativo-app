from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from .models import CustomUser

class CustomUserAdmin(UserAdmin):
    fieldsets = UserAdmin.fieldsets + (
        ('Campos Personalizados', {'fields': ('telefone', 'cargo', 'situacao')}),
    )
    add_fieldsets = UserAdmin.add_fieldsets + (
        ('Campos Personalizados', {'fields': ('telefone', 'cargo', 'situacao')}),
    )

# Diz ao Django para usar a configuração customizada para o modelo CustomUser
admin.site.register(CustomUser, CustomUserAdmin)