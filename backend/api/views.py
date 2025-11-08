import requests
from django.conf import settings
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.authtoken.models import Token
from rest_framework.exceptions import AuthenticationFailed
from rest_framework.decorators import action
from rest_framework.filters import SearchFilter
from rest_framework import viewsets, permissions, status
from django.contrib.auth import authenticate, get_user_model
from django_filters import rest_framework as filters
from .models import Ativo, OrdemServico, Manutencao
from .serializers import AtivoSerializer, OrdemServicoSerializer, FinalizarOSSerializer

##
## --- view.py ---
## função ou classe Python que recebe uma requisição HTTP, processa-a e retorna uma resposta HTTP.
##  Ele é a camada de lógica de negócio, responsável por buscar dados no banco de dados, interagir 
## com modelos e templates, e finalmente renderizar uma página HTML ou outro tipo de resposta
## (como um redirecionamento, JSON, etc.) para o usuário. 
##

import requests
from django.conf import settings
from rest_framework import viewsets, permissions, status
from rest_framework.filters import SearchFilter
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.decorators import action
from rest_framework.authtoken.models import Token
from rest_framework.exceptions import AuthenticationFailed
from django.contrib.auth import authenticate, get_user_model
from .models import Ativo, OrdemServico, Manutencao
from .serializers import AtivoSerializer, OrdemServicoSerializer, FinalizarOSSerializer

class RouteProxyView(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request, *args, **kwargs):
        start_lat = request.data.get('start_lat')
        start_lng = request.data.get('start_lng')
        end_lat = request.data.get('end_lat') # Para rota A->B
        end_lng = request.data.get('end_lng') # Para rota A->B
        waypoints_data = request.data.get('waypoints') # Lista de waypoints

        if not start_lat or not start_lng:
             return Response({'error': 'Coordenadas de origem são obrigatórias.'}, status=status.HTTP_400_BAD_REQUEST)

        google_api_url = 'https://maps.googleapis.com/maps/api/directions/json'
        params = {
            'origin': f'{start_lat},{start_lng}',
            'key': settings.GOOGLE_MAPS_API_KEY,
            'mode': 'driving',
        }

        # Decide se é uma rota A->B ou uma rota otimizada
        if waypoints_data and isinstance(waypoints_data, list) and len(waypoints_data) > 0:
            # Rota Otimizada com Waypoints
            # Separa o último waypoint para ser o destino final explícito
            final_destination_data = waypoints_data[-1]
            intermediate_waypoints_data = waypoints_data[:-1] # Todos exceto o último

            # Define o destino final
            params['destination'] = f"{final_destination_data['lat']},{final_destination_data['lng']}"

            # Formata os waypoints intermédios se houver algum
            if intermediate_waypoints_data:
                 waypoints_str = "optimize:true|" + "|".join([f"{wp['lat']},{wp['lng']}" for wp in intermediate_waypoints_data])
                 params['waypoints'] = waypoints_str
            # Se só houver 1 waypoint, ele torna-se o destino e não há waypoints intermédios
            
        elif end_lat and end_lng:
            # Rota Simples A -> B
            params['destination'] = f'{end_lat},{end_lng}'
        else:
            return Response({'error': 'Coordenadas de destino ou waypoints são obrigatórios.'}, status=status.HTTP_400_BAD_REQUEST)

        try:
            print(f"A pedir rota para Google com params: {params}")
            response = requests.get(google_api_url, params=params)
            response.raise_for_status()
            print("Resposta da Google recebida.")
            return Response(response.json())
        except requests.exceptions.RequestException as e:
            # Tenta extrair a mensagem de erro da resposta da Google, se disponível
            error_detail = str(e)
            try:
                error_json = response.json()
                error_detail = error_json.get('error_message', str(e))
            except: # Ignora erros ao tentar ler o JSON
                pass
            print(f"Erro ao contactar Google ({response.status_code}): {error_detail}")
            return Response({'error': f'Erro ao contactar API Externa: {error_detail}'}, status=status.HTTP_503_SERVICE_UNAVAILABLE)
        except Exception as e:
            print(f"Erro inesperado no proxy: {e}")
            return Response({'error': f'Erro interno no servidor: {e}'}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)



"""
================================= BLOCO 1 — LoginView =================================
A classe `LoginView` é uma *APIView* do Django REST Framework que implementa o processo
de autenticação de usuários e geração de tokens.

--- FUNÇÃO PRINCIPAL ---
Permitir que o usuário faça login enviando `username` e `password`, e retornar um token
de autenticação que será usado para acessar as demais rotas protegidas da API.

--- FUNCIONAMENTO PASSO A PASSO ---
1. O método `post()` é chamado quando o frontend envia uma requisição HTTP POST
   para a rota `/login/` com os campos `username` e `password`.

2. Os dados são extraídos de `request.data`.

3. Caso algum campo esteja ausente, é lançada uma exceção `AuthenticationFailed`
   (retorna erro 401 - Unauthorized).

4. O método `authenticate()` tenta validar as credenciais contra o banco de dados de usuários
   do Django.  
   - Se o usuário existir e a senha estiver correta, retorna um objeto `User`.
   - Caso contrário, retorna `None`.

5. Se a autenticação for bem-sucedida:
   - O código obtém (ou cria, se ainda não existir) um `Token` para o usuário
     usando `Token.objects.get_or_create(user=user)`.
   - Esse token é uma chave única usada em futuras requisições (autenticação por token).

6. Retorna uma resposta JSON com o token no corpo:
   { "token": "<chave_token_gerada>" }

7. Se a autenticação falhar, a exceção AuthenticationFailed é lançada novamente,
    resultando em uma resposta automática do DRF com erro 401 e a mensagem
    "Usuário ou senha inválidos."

Em resumo: esta view é responsável por autenticar o usuário e entregar um token JWT-like
que será usado pelo app Flutter para acessar endpoints protegidos da API.
========================================================================================
"""
User = get_user_model()
class LoginView(APIView):
    """
    View para lidar com a autenticação de usuários e retornar um token.
    """
    def post(self, request, *args, **kwargs):
        username = request.data.get('username')
        password = request.data.get('password')

        if not username or not password:
            raise AuthenticationFailed('Usuário e senha são obrigatórios.')

        #Tenta autenticar o usuário com as credenciais fornecidas
        user = authenticate(username=username, password=password)

        if user is not None:
            # Se a autenticação for bem-sucedida, pega o token do usuário ou cria um novo
            token, created = Token.objects.get_or_create(user=user)
            
            # Retorna uma resposta de sucesso (HTTP 200 OK) com o token
            return Response({'token': token.key})
        else:
            # Se a autenticação falhar, lança uma exceção que o DjangoRestFramework transforma
            # em uma resposta de erro (HTTP 401 Unauthorized)
            raise AuthenticationFailed('Usuário ou senha inválidos.')
        


"""
============================== BLOCO 2 — AtivoViewSet ==============================
Esta classe cria um endpoint REST completo (CRUD) para o modelo Ativo.

--- O QUE É UM VIEWSET? ---
Um ModelViewSet do Django REST Framework fornece automaticamente as operações padrão:

- GET /ativos/ → listar todos os ativos
- GET /ativos/{id}/ → visualizar um ativo específico
- POST /ativos/ → criar um ativo
- PUT /ativos/{id}/ → atualizar um ativo
- DELETE /ativos/{id}/ → deletar um ativo

--- FUNCIONAMENTO INTERNO ---

1. queryset = Ativo.objects.all() → define o conjunto de objetos retornados pela view.

2. serializer_class = AtivoSerializer → especifica como os dados serão convertidos
    para JSON e vice-versa.

3. filter_backends = [SearchFilter] e search_fields = ['nome']
    → habilitam buscas textuais usando o parâmetro ?search=.
    Exemplo: /api/ativos/?search=Sensor retornará todos os ativos cujo nome contenha “Sensor”.

Em resumo: esta view controla todos os endpoints de manipulação de Ativos,
com suporte a listagem, busca e edição completa via API.
====================================================================================
"""
class AtivoViewSet(viewsets.ModelViewSet):
    queryset = Ativo.objects.all()
    serializer_class = AtivoSerializer
    permission_classes = [permissions.AllowAny]
    filter_backends = [SearchFilter]
    search_fields = ['nome']

    # <<< NOVA AÇÃO CUSTOMIZADA PARA BUSCAR O HISTÓRICO
    @action(detail=True, methods=['get'])
    def historico(self, request, pk=None):
        """
        Endpoint que retorna o histórico de Ordens de Serviço finalizadas para um ativo específico.
        URL: /api/ativos/{id}/historico/
        """
        ativo = self.get_object() # Pega o ativo específico (ex: ativo de id=1)
        # Filtra as O.S. relacionadas a este ativo que tenham o status 'finalizada'
        historico_os = ativo.ordens_servico.filter(status='finalizada').order_by('-data_criacao')
        # Serializa os dados para serem enviados como resposta
        serializer = OrdemServicoSerializer(historico_os, many=True)
        return Response(serializer.data)


"""
=========================== BLOCO 3 — OrdemServicoViewSet ===========================
Assim como AtivoViewSet, esta classe fornece endpoints REST automáticos para o modelo
OrdemServico.

--- FUNCIONALIDADES ---

1. queryset = OrdemServico.objects.all().order_by('-data_criacao')
    → Retorna todas as ordens de serviço, ordenadas da mais recente para a mais antiga.

2. serializer_class = OrdemServicoSerializer
    → Define como os objetos serão convertidos de/para JSON.

3. permission_classes = [permissions.AllowAny]
    → Permite acesso público (sem autenticação).
    Geralmente usado em fase de desenvolvimento ou quando o endpoint não exige login.

4. perform_create(self, serializer)
    → Método chamado automaticamente durante a criação de uma nova ordem de serviço (POST).

    - Aqui, a função sobrescreve o comportamento padrão para definir o campo solicitante
    como None (pois o login ainda não está integrado).

    - serializer.save(solicitante=None) salva o registro no banco.

Em resumo: este ViewSet é responsável por criar, listar e consultar ordens de serviço,
tratando a criação de forma personalizada para lidar com usuários anônimos.
====================================================================================
"""
class OrdemServicoViewSet(viewsets.ModelViewSet):
    """
    API endpoint que permite que Ordens de Serviço sejam vistas ou criadas.
    """
    queryset = OrdemServico.objects.all().order_by('data_prevista')
    serializer_class = OrdemServicoSerializer
    permission_classes = [permissions.AllowAny] # Para desenvolvimento

    @action(detail=True, methods=['post'])
    def finalizar(self, request, pk=None):
        """
        Endpoint customizado para finalizar uma O.S. e criar o registo de manutenção.
        URL: /api/ordens-servico/{id}/finalizar/
        """
        ordem_servico = self.get_object() # Pega a O.S. específica (ex: O.S. de id=5)

        # Valida os dados recebidos do Flutter (datas, observações)
        serializer = FinalizarOSSerializer(data=request.data)
        if serializer.is_valid():
            data = serializer.validated_data
            
            # Calcula o tempo gasto
            tempo_gasto = data['data_fim_execucao'] - data['data_inicio_execucao']

            # Cria o registo de Manutenção
            Manutencao.objects.create(
                ordem_servico=ordem_servico,
                # No futuro, usaremos o utilizador autenticado: request.user
                usuario_executor=None, 
                data_inicio_execucao=data['data_inicio_execucao'],
                data_fim_execucao=data['data_fim_execucao'],
                tempo_gasto=tempo_gasto,
                observacoes=data.get('observacoes', '')
            )

            # Atualiza o status da O.S. para "finalizada"
            ordem_servico.status = 'finalizada'
            ordem_servico.save()

            return Response({'status': 'Ordem de serviço finalizada com sucesso'}, status=status.HTTP_200_OK)
        else:
            # Se a validação falhar (ex: data de fim antes do início), retorna um erro
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def perform_create(self, serializer):
        # Como o acesso é público, o solicitante será nulo por enquanto.
        serializer.save(solicitante=None)


"""
=========================== BLOCO 4 — OrdemServicoFilter ============================
Esta classe define um conjunto de filtros personalizados para o modelo OrdemServico,
usando o pacote django-filter, que integra filtros automáticos à API REST.

--- OBJETIVO ---
Permitir ao frontend filtrar as ordens de serviço por data, status e tipo.

--- FUNCIONAMENTO ---

1. data_prevista = filters.DateFilter(field_name='data_prevista__date')
    → Cria um filtro que compara apenas a data (ignorando a hora) do campo data_prevista.
    Assim, o frontend pode enviar uma requisição como:
        /api/ordens-servico/?data_prevista=2025-10-09
    e receberá todas as O.S. com data_prevista igual a esse dia, mesmo que o campo
    contenha horários diferentes.

2. class Meta define:
    model = OrdemServico: o modelo alvo dos filtros.
    fields = ['data_prevista', 'status', 'tipo']: lista os campos que podem ser filtrados via URL.

Em resumo: OrdemServicoFilter oferece uma maneira simples e eficiente de
buscar ordens de serviço específicas por data, tipo ou status, melhorando
a interação do app com o backend.
====================================================================================
"""
class OrdemServicoFilter(filters.FilterSet):
    # Este filtro permite-nos pesquisar por O.S. numa data específica,
    # ignorando a parte da hora do campo `data_prevista`.
    # O frontend irá enviar um pedido como: /api/ordens-servico/?data_prevista=2025-10-09
    data_prevista = filters.DateFilter(field_name='data_prevista__date')

    class Meta:
        model = OrdemServico
        fields = ['data_prevista', 'status', 'tipo']

