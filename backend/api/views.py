from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.authtoken.models import Token
from rest_framework.exceptions import AuthenticationFailed
from django.contrib.auth import authenticate, get_user_model
from rest_framework import viewsets
from .models import Ativo
from .serializers import AtivoSerializer

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
        


#
#
#

class AtivoViewSet(viewsets.ModelViewSet):
    """
    API endpoint que permite que ativos sejam vistos ou editados.
    """
    queryset = Ativo.objects.all()
    serializer_class = AtivoSerializer
