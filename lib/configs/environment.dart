import 'dart:io';

class Environment {
  static final Map<String, String> _properties = {};

  static Future<void> loadProperties() async {
    try {
      File file = File('.env');
      if (await file.exists()) {
        List<String> lines = await file.readAsLines();
        for (String line in lines) {
          if (line.isNotEmpty) {
            final key = line.substring(0, line.indexOf('='));
            final value = line.substring(line.indexOf('=') + 1);
            _properties[key] = value;
          }
        }
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  static String? getProperty(String key) {
    return _properties[key];
  }
}
