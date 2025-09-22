import 'package:flutter/material.dart';
import 'package:flutter_tcc/data/models/ordem_servico.dart';
import 'package:intl/intl.dart';

class IniciarOrdemServicoScreen extends StatefulWidget {
  final OrdemServico ordemServico;

  const IniciarOrdemServicoScreen({super.key, required this.ordemServico});

  @override
  State<IniciarOrdemServicoScreen> createState() =>
      _IniciarOrdemServicoScreenState();
}

class _IniciarOrdemServicoScreenState extends State<IniciarOrdemServicoScreen> {
  DateTime? _dataHoraInicio;
  DateTime? _dataHoraFim;
  final _observacoesController = TextEditingController();

  Future<void> _selecionarDataHora(
    BuildContext context, {
    required bool isInicio,
  }) async {
    const Color primaryColor = Color(0xFF12385D);

    final DateTime? dataSelecionada = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('pt', 'BR'),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor:
                    primaryColor, //Cor dos botões "OK" e "CANCELAR"
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (dataSelecionada == null) return;

    final TimeOfDay? horaSelecionada = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(DateTime.now()),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            timePickerTheme: const TimePickerThemeData(
              backgroundColor: Colors.white,
              hourMinuteShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                side: BorderSide(color: Colors.grey, width: 1),
              ),
              dayPeriodShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                side: BorderSide(color: Colors.grey, width: 1),
              ),
              dayPeriodColor: Colors.white,
              dayPeriodTextColor: primaryColor,
              hourMinuteColor: Colors.white,
              hourMinuteTextColor: primaryColor,
              dialHandColor: primaryColor,
              dialBackgroundColor: Colors.blueGrey,
              dialTextColor: Colors.white,
              entryModeIconColor: primaryColor,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor:
                    primaryColor, //Cor dos botões "OK" e "CANCELAR"
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (horaSelecionada == null) return;

    final DateTime dataHoraFinal = DateTime(
      dataSelecionada.year,
      dataSelecionada.month,
      dataSelecionada.day,
      horaSelecionada.hour,
      horaSelecionada.minute,
    );

    setState(() {
      if (isInicio) {
        _dataHoraInicio = dataHoraFinal;
      } else {
        _dataHoraFim = dataHoraFinal;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF12385D);
    const String nomeExecutor = "Técnico Padrão";
    final String dataExecucao = DateFormat.yMd('pt_BR').format(DateTime.now());
    final dateFormatter = DateFormat('dd/MM/y HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Execução da O.S.'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informações da Execução',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.person, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Executor: $nomeExecutor',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Data: $dataExecucao',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const Divider(height: 32),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Data/Hora Início',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed:
                            () => _selecionarDataHora(context, isInicio: true),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primaryColor,
                        ),
                        child: Text(
                          _dataHoraInicio != null
                              ? dateFormatter.format(_dataHoraInicio!)
                              : 'Selecionar',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Data/Hora Fim',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed:
                            () => _selecionarDataHora(context, isInicio: false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primaryColor,
                        ),
                        child: Text(
                          _dataHoraFim != null
                              ? dateFormatter.format(_dataHoraFim!)
                              : 'Selecionar',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Descrição',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _observacoesController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Descreva o que foi realizado...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Observações',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _observacoesController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Escreva alguma observação...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
      persistentFooterButtons: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.check_circle),
              label: const Text('FINALIZAR O.S.'),
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
