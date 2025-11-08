import 'dart:async';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

// A função tem o mesmo nome que teremos no arquivo mobile
Future<void> configureApp() async {
  // Todo o código que antes estava dentro do if (kIsWeb) vem para cá.
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
