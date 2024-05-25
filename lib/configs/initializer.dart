import 'package:silent_signal/configs/environment.dart';
import 'package:silent_signal/database/manager.dart';

class Initializer {
  static Future<void> initEnv() async {
    await Environment.loadProperties();
  }

  static Future<void> initMigration() async {
    await ConnectionManager.executeMigration();
  }
}
