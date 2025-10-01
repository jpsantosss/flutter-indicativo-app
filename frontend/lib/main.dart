import 'dart:async';
import 'package:flutter/foundation.dart';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import 'package:flutter_tcc/presentation/screens/login/login_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    final completer = Completer<void>();

    const String apiKey = String.fromEnvironment('WEB_MAPS_API_KEY');
    if (apiKey == '') {
      print('ERRO: A chave da API do Google Maps para Web não foi definida.');
      return;
    }

    ui_web.platformViewRegistry.registerViewFactory(
      'google-map',
      (int viewId) =>
          html.IFrameElement()
            ..id = 'map-iframe'
            ..style.border = 'none',
    );

    final script =
        html.ScriptElement()
          ..id = 'google-maps-script'
          ..src = 'https://maps.googleapis.com/maps/api/js?key=$apiKey'
          ..async = true
          ..defer = true;

    script.onLoad.listen((_) {
      completer.complete();
    });

    html.document.head!.children.add(script);

    await completer.future;
  }
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
