import json # <<< 1. IMPORTE A BIBLIOTECA JSON DO PYTHON
from django.contrib.gis.geos import Point
from rest_framework_gis.serializers import GeoFeatureModelSerializer
from rest_framework import serializers
from .models import Ativo

class AtivoSerializer(GeoFeatureModelSerializer):
    """
    Um GeoFeatureModelSerializer que sabe como criar um Ativo
    a partir de dados GeoJSON.
    """
    class Meta:
        model = Ativo
        geo_field = "localizacao"
        fields = ('id', 'nome', 'marca', 'modelo', 'periodicidade', 'manual', 'endereco', 'localizacao')

    def create(self, validated_data):
        """
        Sobrescreve o método de criação para lidar com o campo PointField.
        """
        # 2. RETIRA A STRING DE LOCALIZAÇÃO DOS DADOS
        localizacao_str = validated_data.pop('localizacao')
        
        # <<< 3. CONVERTE A STRING DE VOLTA PARA UM DICIONÁRIO PYTHON
        localizacao_data = json.loads(localizacao_str)
        
        # A partir daqui, o resto do código funciona como esperado
        longitude = localizacao_data['coordinates'][0]
        latitude = localizacao_data['coordinates'][1]

        ponto = Point(longitude, latitude)

        ativo = Ativo.objects.create(localizacao=ponto, **validated_data)
        
        return ativo
