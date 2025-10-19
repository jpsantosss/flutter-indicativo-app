import json
from django.contrib.gis.geos import Point
from rest_framework_gis.serializers import GeoFeatureModelSerializer
from rest_framework import serializers
from .models import Ativo, OrdemServico, Manutencao


##
## --- serializers.py ---
## Componente usado para converter dados complexos (como objetos de modelo) 
## em formatos que podem ser facilmente transmitidos, como JSON ou XML, e vice-versa
##


"""
============================== BLOCO 1 — AtivoSerializer ==============================

Esta classe é um **serializador especializado para modelos geográficos (GeoDjango)**,
usando o `GeoFeatureModelSerializer` da biblioteca `rest_framework_gis`.  
Ela converte objetos do modelo `Ativo` em formato GeoJSON (usado em mapas) e também
lida com a criação/atualização desses objetos a partir desse formato.

--- PRINCIPAIS PONTOS ---
• O campo `geo_field = "localizacao"` indica que o atributo geográfico do modelo é
  um campo `PointField`, ou seja, contém coordenadas geográficas (latitude e longitude).
• Os campos listados em `fields` definem quais atributos do modelo serão expostos
  ou aceitos via API.

--- MÉTODO create() ---
Esse método sobrescreve a criação padrão do serializer para processar o campo de localização,
já que ele chega como um JSON (GeoJSON) e precisa ser transformado em um objeto `Point`.

1. Remove o campo `localizacao` de `validated_data` e o converte de string JSON para dicionário.
2. Extrai `longitude` e `latitude` de `localizacao_data['coordinates']`.
3. Cria um objeto `Point(longitude, latitude)` do GeoDjango.
4. Cria um novo `Ativo` passando o ponto e os demais campos validados.
5. Retorna o objeto recém-criado.

--- MÉTODO update() ---
Esse método personaliza o processo de atualização de um `Ativo`, garantindo que o
campo `localizacao` (caso enviado) seja tratado corretamente e os demais campos
sejam atualizados individualmente.

1. Verifica se `localizacao` foi enviado na requisição:
   - Se sim, ele faz o mesmo processo do `create`: converte JSON → Point e substitui
     o campo `localizacao` do objeto.
2. Atualiza todos os outros campos com os novos valores, se fornecidos, 
   mantendo os anteriores caso não sejam enviados.
3. Trata o caso do campo `manual` (upload de arquivo) — se um novo for enviado, substitui.
4. Salva o objeto atualizado no banco.
5. Retorna a instância modificada.

Em resumo, o `AtivoSerializer` garante que dados geográficos e arquivos sejam
corretamente processados tanto na criação quanto na edição de ativos, 
permitindo a integração com mapas e coordenadas no frontend.

========================================================================================
"""
class AtivoSerializer(GeoFeatureModelSerializer):
    class Meta:
        model = Ativo
        geo_field = "localizacao"
        fields = ('id', 'nome', 'marca', 'modelo', 'periodicidade', 'manual', 'endereco', 'localizacao', 'mtbf', 'mttr')

    def create(self, validated_data):
        localizacao_data = json.loads(validated_data.pop('localizacao'))
        longitude = localizacao_data['coordinates'][0]
        latitude = localizacao_data['coordinates'][1]
        ponto = Point(longitude, latitude)
        ativo = Ativo.objects.create(localizacao=ponto, **validated_data)
        return ativo

    def update(self, instance, validated_data):
        if 'localizacao' in validated_data:
            localizacao_data = json.loads(validated_data.pop('localizacao'))
            longitude = localizacao_data['coordinates'][0]
            latitude = localizacao_data['coordinates'][1]
            instance.localizacao = Point(longitude, latitude)

        instance.nome = validated_data.get('nome', instance.nome)
        instance.marca = validated_data.get('marca', instance.marca)
        instance.modelo = validated_data.get('modelo', instance.modelo)
        instance.periodicidade = validated_data.get('periodicidade', instance.periodicidade)
        instance.endereco = validated_data.get('endereco', instance.endereco)
        instance.mtbf = validated_data.get('mtbf', instance.mtbf)
        instance.mttr = validated_data.get('mttr', instance.mttr)
        
        if 'manual' in validated_data:
            instance.manual = validated_data.get('manual', instance.manual)

        instance.save()
        return instance



"""
========================== BLOCO 2 — OrdemServicoSerializer ===========================
Este é um serializer padrão do Django REST Framework para o modelo `OrdemServico`.

--- FUNÇÃO PRINCIPAL ---
Converter objetos `OrdemServico` em JSON para exibição na API e
receber dados JSON para criar novas ordens de serviço.

--- CAMPOS PERSONALIZADOS ---
• `solicitante = serializers.StringRelatedField(read_only=True)`
  → Exibe o nome legível do solicitante, usando o método `__str__` do modelo relacionado.

• `ativo_nome = serializers.CharField(source='ativo.nome', read_only=True, allow_null=True)`
  → Adiciona um campo derivado que mostra apenas o nome do ativo associado, sem precisar
    retornar o objeto completo.  
  → O `allow_null=True` evita erros quando a ordem de serviço não está ligada a nenhum ativo.

--- Meta ---
• O `model` define que este serializer trabalha com o modelo `OrdemServico`.
• `fields` define quais atributos serão incluídos no JSON retornado.
  Inclui:
  - Dados principais: `titulo`, `tipo`, `descricao`, `status`
  - Relacionamentos: `ativo`, `ativo_nome`, `solicitante`
  - Datas de criação e previsão.
• `read_only_fields` protege certos campos de edição pela API
  (por exemplo, `status`, `data_criacao` e `solicitante` só podem ser definidos internamente).

Em resumo, o `OrdemServicoSerializer` organiza e controla
como as ordens de serviço são representadas e validadas pela API, 
permitindo leitura e criação de dados de forma segura e consistente.
========================================================================================
"""
class ManutencaoSerializer(serializers.ModelSerializer):
    # Mostra o nome do executor em vez do ID
    usuario_executor = serializers.StringRelatedField()

    class Meta:
        model = Manutencao
        fields = ('usuario_executor', 'data_inicio_execucao', 'data_fim_execucao', 'tempo_gasto', 'observacoes')


# <<< SERIALIZER DA ORDEM DE SERVIÇO ATUALIZADO >>>
class OrdemServicoSerializer(serializers.ModelSerializer):
    solicitante = serializers.StringRelatedField(read_only=True)
    ativo_nome = serializers.CharField(source='ativo.nome', read_only=True, allow_null=True)
    # Inclui os detalhes da manutenção no JSON da O.S.
    manutencao = ManutencaoSerializer(read_only=True)

    class Meta:
        model = OrdemServico
        fields = (
            'id', 'titulo', 'tipo', 'descricao', 'status', 
            'ativo', 'ativo_nome', 'data_criacao', 'data_prevista', 'solicitante', 'manutencao'
        )
        read_only_fields = ('status', 'data_criacao', 'solicitante', 'ativo_nome', 'manutencao')


class FinalizarOSSerializer(serializers.Serializer):
    """
    Serializer para validar os dados enviados ao finalizar uma O.S.
    """
    data_inicio_execucao = serializers.DateTimeField()
    data_fim_execucao = serializers.DateTimeField()
    observacoes = serializers.CharField(allow_blank=True, required=False)

    def validate(self, data):
        """ Garante que a data de fim seja posterior à de início. """
        if data['data_inicio_execucao'] >= data['data_fim_execucao']:
            raise serializers.ValidationError("A data de fim deve ser posterior à data de início.")
        return data