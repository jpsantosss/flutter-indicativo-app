import json
from django.contrib.gis.geos import Point
from rest_framework_gis.serializers import GeoFeatureModelSerializer
from rest_framework import serializers
from .models import Ativo, OrdemServico

class AtivoSerializer(GeoFeatureModelSerializer):
    """
    Um GeoFeatureModelSerializer que sabe como criar e ATUALIZAR um Ativo
    a partir de dados GeoJSON.
    """
    class Meta:
        model = Ativo
        geo_field = "localizacao"
        fields = ('id', 'nome', 'marca', 'modelo', 'periodicidade', 'manual', 'endereco', 'localizacao', 'mtbf', 'mttr')

    def create(self, validated_data):
        """
        Sobrescreve o método de criação para lidar com o campo PointField.
        """
        localizacao_data = json.loads(validated_data.pop('localizacao'))
        longitude = localizacao_data['coordinates'][0]
        latitude = localizacao_data['coordinates'][1]
        ponto = Point(longitude, latitude)
        ativo = Ativo.objects.create(localizacao=ponto, **validated_data)
        return ativo

    # MÉTODO DE ATUALIZAÇÃO
    def update(self, instance, validated_data):
        """
        Sobrescreve o método de atualização para lidar com o campo PointField.
        """
        # Se 'localizacao' foi enviado nos dados, processa-o
        if 'localizacao' in validated_data:
            localizacao_data = json.loads(validated_data.pop('localizacao'))
            longitude = localizacao_data['coordinates'][0]
            latitude = localizacao_data['coordinates'][1]
            instance.localizacao = Point(longitude, latitude)

        # Atualiza os outros campos do modelo
        instance.nome = validated_data.get('nome', instance.nome)
        instance.marca = validated_data.get('marca', instance.marca)
        instance.modelo = validated_data.get('modelo', instance.modelo)
        instance.periodicidade = validated_data.get('periodicidade', instance.periodicidade)
        instance.endereco = validated_data.get('endereco', instance.endereco)
        instance.mtbf = validated_data.get('mtbf', instance.mtbf)
        instance.mttr = validated_data.get('mttr', instance.mttr)
        
        # Lida com o upload do manual (se um novo ficheiro for enviado)
        if 'manual' in validated_data:
            instance.manual = validated_data.get('manual', instance.manual)

        instance.save()
        return instance

class OrdemServicoSerializer(serializers.ModelSerializer):
    solicitante = serializers.StringRelatedField(read_only=True)
    # <<< CORREÇÃO: Adicionado 'allow_null=True' para evitar erros se o ativo for nulo
    ativo_nome = serializers.CharField(source='ativo.nome', read_only=True, allow_null=True)

    class Meta:
        model = OrdemServico
        # <<< CORREÇÃO: Adicionado o campo 'prioridade' que faltava
        fields = (
            'id', 'titulo', 'tipo', 'descricao', 'status', 
            'ativo', 'ativo_nome', 'data_criacao', 'data_prevista', 'solicitante', 
        )
        read_only_fields = ('status', 'data_criacao', 'solicitante', 'ativo_nome')