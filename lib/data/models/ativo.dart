class Ativo {
  final String id;
  final String nome;
  final String marca;
  final String modelo;
  final String periodicidade;
  final String? nomeArquivoManual;
  final String endereco;
  final String longitude;
  final String latitude;
  final String mtbf; // Mean Time Between Failures
  final String mttr; // Mean Time To Repair

  Ativo({
    required this.id,
    required this.nome,
    required this.marca,
    required this.modelo,
    required this.periodicidade,
    this.nomeArquivoManual,
    required this.endereco,
    required this.longitude,
    required this.latitude,
    required this.mtbf,
    required this.mttr,
  });
}