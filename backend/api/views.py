from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.authtoken.models import Token
from rest_framework.exceptions import AuthenticationFailed
from django.contrib.auth import authenticate, get_user_model
from rest_framework import viewsets, permissions
from .models import Ativo, OrdemServico
from .serializers import AtivoSerializer, OrdemServicoSerializer
from rest_framework.filters import SearchFilter
from django_filters import rest_framework as filters

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
        


# -------------------
# ATIVOS
# -------------------


class AtivoViewSet(viewsets.ModelViewSet):
    """
    API endpoint que permite que ativos sejam vistos ou editados.
    """
    ## Visualização
    queryset = Ativo.objects.all()
    serializer_class = AtivoSerializer

    ## Busca
    filter_backends = [SearchFilter]
    search_fields = ['nome'] # Define que a pesquisa deve ser feita no campo 'nome'




class OrdemServicoViewSet(viewsets.ModelViewSet):
    """
    API endpoint que permite que Ordens de Serviço sejam vistas ou criadas.
    """
    queryset = OrdemServico.objects.all().order_by('-data_criacao')
    serializer_class = OrdemServicoSerializer
    # Permite acesso público para o modo de desenvolvimento
    permission_classes = [permissions.AllowAny]

    def perform_create(self, serializer):
        # Como o acesso é público, o solicitante será nulo por enquanto.
        serializer.save(solicitante=None)

class OrdemServicoFilter(filters.FilterSet):
    # Este filtro permite-nos pesquisar por O.S. numa data específica,
    # ignorando a parte da hora do campo `data_prevista`.
    # O frontend irá enviar um pedido como: /api/ordens-servico/?data_prevista=2025-10-09
    data_prevista = filters.DateFilter(field_name='data_prevista__date')

    class Meta:
        model = OrdemServico
        fields = ['data_prevista', 'status', 'tipo']