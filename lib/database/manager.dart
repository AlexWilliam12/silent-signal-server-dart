import 'dart:convert';
import 'dart:io';

import 'package:postgres/postgres.dart';
import 'package:silent_signal/configs/environment.dart';

class ConnectionManager {
  static Future<void> executeMigration() async {
    Connection? conn;
    try {
      final queries = ConnectionManager._readScript();
      conn = await ConnectionManager.getConnection();
      for (final query in queries) {
        await conn.execute(query);
      }
    } finally {
      if (conn != null) {
        await conn.close();
      }
    }
  }

  static Future<Connection> getConnection() async {
    return await Connection.open(
      Endpoint(
        host: Environment.getProperty('DB_HOST')!,
        database: Environment.getProperty('DB_NAME')!,
        username: Environment.getProperty('DB_USER')!,
        password: Environment.getProperty('DB_PASSWORD')!,
        port: int.parse(Environment.getProperty('DB_PORT')!),
      ),
      settings: ConnectionSettings(
        sslMode: SslMode.disable,
        timeZone: 'America/Sao_Paulo',
        encoding: Encoding.getByName('UTF-8'),
        connectTimeout: Duration(minutes: 10),
        queryTimeout: Duration(minutes: 5),
      ),
    );
  }

  static List<String> _readScript() {
    final file = File('script/migration.sql');
    final script = file.readAsStringSync();
    return script.split(';');
  }
}
