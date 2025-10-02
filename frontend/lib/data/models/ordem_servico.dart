import 'package:flutter/material.dart';

enum StatusOS { pendente, finalizada, cancelada }
enum PrioridadeOS { baixa, media, alta }

class OrdemServico {
  final String titulo;
  final String ativo;
  final DateTime inicio;
  final DateTime fim;
  final String usuarioSolicitante;
  final DateTime dataCriacao;
  final String tipoManutencao;
  final StatusOS status;

  OrdemServico({
    required this.titulo,
    required this.ativo,
    required this.inicio,
    required this.fim,
    required this.usuarioSolicitante,
    required this.dataCriacao,
    required this.tipoManutencao,
    required this.status,
  });
}