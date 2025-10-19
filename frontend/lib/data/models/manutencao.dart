class Manutencao {
  final String? usuarioExecutor;
  final DateTime dataInicioExecucao;
  final DateTime dataFimExecucao;
  final Duration tempoGasto;
  final String? observacoes;

  Manutencao({
    this.usuarioExecutor,
    required this.dataInicioExecucao,
    required this.dataFimExecucao,
    required this.tempoGasto,
    this.observacoes,
  });

  // Função para converter o formato de duração do Django (ex: "1 01:30:00") para um objeto Duration
  static Duration _parseDjangoDuration(String durationStr) {
    try {
      final parts = durationStr.split(' ');
      final timeParts = parts.last.split(':');
      final days = parts.length > 1 ? (int.tryParse(parts[0]) ?? 0) : 0;
      final hours = int.tryParse(timeParts[0]) ?? 0;
      final minutes = int.tryParse(timeParts[1]) ?? 0;
      final seconds = double.tryParse(timeParts[2])?.toInt() ?? 0;

      return Duration(days: days, hours: hours, minutes: minutes, seconds: seconds);
    } catch (e) {
      return Duration.zero;
    }
  }

  factory Manutencao.fromJson(Map<String, dynamic> json) {
    return Manutencao(
      usuarioExecutor: json['usuario_executor'],
      dataInicioExecucao: DateTime.parse(json['data_inicio_execucao']),
      dataFimExecucao: DateTime.parse(json['data_fim_execucao']),
      tempoGasto: _parseDjangoDuration(json['tempo_gasto']),
      observacoes: json['observacoes'],
    );
  }
}
