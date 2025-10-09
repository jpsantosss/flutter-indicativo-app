from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import LoginView, AtivoViewSet, OrdemServicoViewSet

# O router irá gerar automaticamente as URLs para o CRUD de Ativos.
router = DefaultRouter()
router.register(r'ativos', AtivoViewSet, basename='ativo')
router.register(r'ordens-servico', OrdemServicoViewSet, basename='ordemservico')

# As URLs da API são agora determinadas automaticamente pelo router.
urlpatterns = [
    path('login/', LoginView.as_view(), name='login'),
    path('', include(router.urls)),
]