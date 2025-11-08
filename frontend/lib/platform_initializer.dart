export 'mobile_initializer.dart' // Exporta a versão mobile por padrão
    if (dart.library.html) 'web_initializer.dart'; // Mas se for web, exporta a versão web.
