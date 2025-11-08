import 'package:flutter_tcc/platform_initializer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tcc/presentation/screens/login/login_screen.dart';
// import 'package:flutter_tcc/presentation/screens/map/map_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';


/*
================================= BLOCO ÚNICO — main.dart =================================
Este arquivo é o ponto de entrada principal da aplicação Flutter.
Ele é responsável por inicializar configurações globais, preparar o ambiente da aplicação 
e iniciar a interface principal (tela de login, neste caso).

--- FUNCIONAMENTO DETALHADO ---
1. **Função main()**
   - Marcada como `async` porque executa operações assíncronas antes de rodar o app.
   - `WidgetsFlutterBinding.ensureInitialized();`
     → Garante que o Flutter tenha inicializado completamente antes de qualquer operação
       que dependa do framework (como chamadas nativas, inicializações de plugins, etc).

   - `await configureApp();`
     → Chama uma função definida em outro arquivo (`platform_initializer.dart`),
       provavelmente usada para inicializar dependências específicas da plataforma,
       como configurações de API, bancos locais, permissões, ou inicializações de SDKs.

   - `await initializeDateFormatting('pt_BR', null);`
     → Configura a formatação de datas no padrão **português do Brasil**.
       Isso é essencial para exibir corretamente nomes de meses, dias da semana e formatos de data.

   - `runApp(const MyApp());`
     → Inicia a aplicação Flutter, carregando o widget principal (`MyApp`).

---

2. **Classe MyApp**
   - Extende `StatelessWidget`, o que significa que é um widget imutável, usado como container raiz.
   - Dentro de `build()`, retorna um `MaterialApp`, que é o núcleo de toda aplicação Flutter com Material Design.

   **Configurações do MaterialApp:**
   - `localizationsDelegates` e `supportedLocales`
     → Adicionam suporte completo à localização em português (pt_BR),
       garantindo que textos padrão (como datas, botões e formatações do sistema)
       apareçam traduzidos.
   - `home: LoginScreen()`
     → Define a primeira tela que será exibida quando o app iniciar.
       Nesse caso, é a **tela de login**, importada de `presentation/screens/login/login_screen.dart`.

---

Em resumo:
O `main.dart` prepara o ambiente do aplicativo Flutter (configurações, idioma, dependências)
e inicializa a interface principal com suporte à localização em português.
Ele é o "ponto de partida" que conecta toda a lógica de inicialização ao frontend do app.

============================================================================================
*/

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
