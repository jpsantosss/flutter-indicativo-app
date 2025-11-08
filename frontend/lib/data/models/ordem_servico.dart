import 'package:flutter_tcc/data/models/manutencao.dart';

// Enums para representar as escolhas do backend
enum StatusOS { pendente, finalizada, cancelada }

class OrdemServico {
  final int id;
  final String titulo;
  final String ativo;
  final DateTime dataPrevista;
  final String? usuarioSolicitante; // Pode ser nulo
  final DateTime dataCriacao;
  final String tipoManutencao;
  final StatusOS status;
  final String? descricao; // Pode ser nulo
  final Manutencao? manutencao;

  OrdemServico({
    required this.id,
    required this.titulo,
    required this.ativo,
    required this.dataPrevista,
    this.usuarioSolicitante,
    required this.dataCriacao,
    required this.tipoManutencao,
    required this.status,
    this.descricao,
    this.manutencao,
  });

  // Função auxiliar para converter uma string no enum StatusOS
  static StatusOS _statusFromString(String? statusStr) {
    switch (statusStr) {
      case 'finalizada':
        return StatusOS.finalizada;
      case 'cancelada':
        return StatusOS.cancelada;
      default:
        return StatusOS.pendente;
    }
  }


  // <<< CORREÇÃO: 'factory' em vez de 'Future<void>'
  // Um construtor de fábrica é usado para criar uma instância da classe a partir de lógica customizada.
  factory OrdemServico.fromJson(Map<String, dynamic> json) {
    return OrdemServico(
      id: json['id'],
      titulo: json['titulo'] ?? 'Sem título',
      ativo: json['ativo_nome'] ?? 'Ativo não especificado',
      // Garante que a data seja processada corretamente, mesmo que seja nula
      dataPrevista:
          json['data_prevista'] != null
              ? DateTime.parse(json['data_prevista'])
              : DateTime.now(),
      dataCriacao: DateTime.parse(json['data_criacao']),
      usuarioSolicitante: json['solicitante'],
      tipoManutencao: json['tipo'] ?? 'Não especificado',
      descricao: json['descricao'],
      status: _statusFromString(json['status']),
      manutencao: json['manutencao'] != null
        ? Manutencao.fromJson(json['manutencao'])
        : null,
    );
  }
}
