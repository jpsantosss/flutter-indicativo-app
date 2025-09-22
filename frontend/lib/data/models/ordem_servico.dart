import 'package:flutter/material.dart';

enum StatusOS { pendente, finalizada, cancelada }
enum PrioridadeOS { baixa, media, alta }

class OrdemServico {
  final String titulo;
  final String ativo;
  final DateTime inicio;
  final DateTime fim;
  final Color cor;
  final String usuarioSolicitante;
  final DateTime dataCriacao;
  final String tipoManutencao;
  final StatusOS status;
  final PrioridadeOS prioridade;

  OrdemServico({
    required this.titulo,
    required this.ativo,
    required this.inicio,
    required this.fim,
    required this.cor,
    required this.usuarioSolicitante,
    required this.dataCriacao,
    required this.tipoManutencao,
    required this.status,
    required this.prioridade,
  });
}