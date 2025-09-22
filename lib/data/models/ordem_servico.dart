import 'package:flutter/material.dart';

class OrdemServico {
  final String titulo;
  final String cliente;
  final DateTime inicio;
  final DateTime fim;
  final Color cor;

  OrdemServico({
    required this.titulo,
    required this.cliente,
    required this.inicio,
    required this.fim,
    required this.cor,
  });
}
