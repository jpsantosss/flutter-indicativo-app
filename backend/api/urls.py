from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import LoginView, AtivoViewSet, OrdemServicoViewSet

"""
================================ BLOCO ÚNICO — urls.py =================================
Este arquivo define as rotas (URLs) da API para o aplicativo Django REST Framework.  
Ele conecta as *views* criadas no arquivo `views.py` às URLs que o frontend (por exemplo, o app Flutter)
irá acessar para realizar operações como login, criação e consulta de dados.

--- FUNCIONAMENTO DO ROUTER ---
O `DefaultRouter` simplifica a criação de rotas REST, eliminando a necessidade
de declarar manualmente cada URL (como `/ativos/`, `/ativos/<id>/`, etc).

1. `router = DefaultRouter()` → cria um roteador padrão da API.
2. `router.register(r'ativos', AtivoViewSet, basename='ativo')`
   → Gera automaticamente endpoints para a entidade **Ativo**:
     - `GET /ativos/` → lista todos os ativos.
     - `POST /ativos/` → cria um novo ativo.
     - `GET /ativos/{id}/` → busca um ativo específico.
     - `PUT /ativos/{id}/` → atualiza um ativo.
     - `DELETE /ativos/{id}/` → exclui um ativo.
   O `basename` serve como identificador interno para o conjunto de URLs.

3. `router.register(r'ordens-servico', OrdemServicoViewSet, basename='ordemservico')`
   → Cria automaticamente as mesmas rotas REST, mas para o modelo de Ordens de Serviço.

--- DEFINIÇÃO DAS URLS ---
O array `urlpatterns` lista as rotas acessíveis externamente:

• `path('login/', LoginView.as_view(), name='login')`
  → Define a rota para login do usuário.  
    Essa rota chama uma *class-based view* (`LoginView`) responsável por autenticação
    (provavelmente recebendo usuário/senha e retornando token ou sessão).

• `path('', include(router.urls))`
  → Inclui todas as rotas automaticamente geradas pelo router, como `/ativos/` e `/ordens-servico/`.

--- RESUMO GERAL ---
O arquivo `urls.py` é o ponto de entrada para todas as rotas da API REST:
- Ele gerencia autenticação (`/login/`).
- Expõe endpoints CRUD completos para os modelos Ativo e Ordem de Serviço.
- Centraliza a configuração de URLs, facilitando a manutenção e expansão do sistema.
========================================================================================
"""


# O router irá gerar automaticamente as URLs para o CRUD de Ativos.
router = DefaultRouter()
router.register(r'ativos', AtivoViewSet, basename='ativo')
router.register(r'ordens-servico', OrdemServicoViewSet, basename='ordemservico')

# As URLs da API são agora determinadas automaticamente pelo router.
urlpatterns = [
    path('login/', LoginView.as_view(), name='login'),
    path('', include(router.urls)),
]