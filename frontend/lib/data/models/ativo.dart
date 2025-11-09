import 'package:flutter/foundation.dart';

class Ativo {
  final String id;
  final String nome;
  final String marca;
  final String modelo;
  final int periodicidade;
  final String endereco;
  final double latitude;
  final double longitude;
  // Campos que podem ser nulos agora têm '?'
  final String? manualUrl;
  final String? nomeArquivoManual;
  final int mtbf;
  final int mttr;

  Ativo({
    required this.id,
    required this.nome,
    required this.marca,
    required this.modelo,
    required this.periodicidade,
    required this.endereco,
    required this.latitude,
    required this.longitude,
    this.manualUrl,
    this.nomeArquivoManual,
    required this.mtbf,
    required this.mttr,
  });

  factory Ativo.fromJson(Map<String, dynamic> json) {
    // Extrai as propriedades do ativo
    final properties = json['properties'];

    // Pega na string de geometria, ex: "SRID=4326;POINT (-42.962726 -22.428925)"
    final String geometryString = json['geometry'];

    // Remove a parte "SRID=...;POINT (" e o ")" final
    final String coordsString = geometryString
        .split('POINT (')[1]
        .replaceAll(')', '');

    // Separa os dois números (longitude e latitude)
    final List<String> coords = coordsString.split(' ');

    final double longitude = double.tryParse(coords[0]) ?? 0.0;
    final double latitude = double.tryParse(coords[1]) ?? 0.0;

    return Ativo(
      // Busca o 'id' no nível superior do JSON
      id: json['id']?.toString() ?? '',

      // O '??' (operador de coalescência nula) fornece um valor padrão se o campo for nulo
      nome: properties['nome'] ?? 'Nome não disponível',
      marca: properties['marca'] ?? 'Marca não disponível',
      modelo: properties['modelo'] ?? 'Modelo não disponível',
      periodicidade: properties['periodicidade'] ?? 0,
      endereco: properties['endereco'] ?? 'Endereço não disponível',

      // <<< CORREÇÃO: Usa os valores processados da string de geometria
      longitude: longitude,
      latitude: latitude,

      // Lida com os campos que podem ser nulos
      manualUrl: properties['manual'],
      nomeArquivoManual: properties['nomeArquivoManual'],
      mtbf: properties['mtbf'],
      mttr: properties['mttr'],
    );
  }
}
