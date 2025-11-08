import 'dart:io';

class ApiConfig {
  static String get baseUrl {
    if (Platform.isAndroid || Platform.isIOS) {
      // Dispositivo físico (mesma rede do PC)
      return 'https://cognitive-groomishly-cade.ngrok-free.dev';
    } else {
      // Testes no desktop
      return 'http://127.0.0.1:8000';
    }
  }
}
