import 'package:flutter_dotenv/flutter_dotenv.dart';

const appEnvironment = String.fromEnvironment(
  'APP_ENV',
  defaultValue: 'development',
);

final class AppEnv {
  AppEnv._();

  static String get fileName {
    switch (appEnvironment) {
      case 'production':
        return '.env.production';
      case 'development':
      default:
        return '.env.development';
    }
  }

  static Future<void> load() {
    return dotenv.load(fileName: fileName);
  }

  static String get apiBaseUrl {
    return dotenv.get('API_BASE_URL', fallback: 'http://localhost:8080/api');
  }
}
