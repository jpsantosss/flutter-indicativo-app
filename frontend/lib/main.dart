// REMOVA essas importações:
// import 'dart:async';
// import 'package:flutter/foundation.dart';
// import 'dart:html' as html;
// import 'dart:ui_web' as ui_web;

// ADICIONE esta importação:
import 'package:flutter_tcc/platform_initializer.dart'; // <- Nosso seletor!

import 'package:flutter/material.dart';
import 'package:flutter_tcc/presentation/screens/login/login_screen.dart';
import 'package:flutter_tcc/presentation/screens/map/map_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await configureApp();

  await initializeDateFormatting('pt_BR', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [Locale('pt', 'BR')],
      home: LoginScreen(),
    );
  }
}
