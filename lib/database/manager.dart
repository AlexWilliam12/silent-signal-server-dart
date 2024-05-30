import 'dart:convert';
import 'dart:io';

import 'package:postgres/postgres.dart';
import 'package:silent_signal/configs/environment.dart';

class ConnectionManager {
  static Future<void> executePreloaders() async {
    Connection? conn;
    try {
      conn = await ConnectionManager.getConnection();
      await Future.wait([
        ConnectionManager._loadMigrations(conn),
        ConnectionManager._loadFunctions(conn),
      ])
          .then((value) async => await conn!.close())
          .catchError((error) => throw Exception(error));
    } catch (e) {
      throw Exception(e);
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

  static Future<void> _loadMigrations(Connection conn) async {
    try {
      final file = File('script/migration.sql');
      final script = file.readAsStringSync();
      final queries = script.split(';');
      for (final query in queries) {
        await conn.execute(query);
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> _loadFunctions(Connection conn) async {
    try {
      final directory = Directory('script');
      final files = directory.listSync();
      for (final file in files) {
        if (file is File && !file.path.contains('migration.sql')) {
          final query = file.readAsStringSync();
          await conn.execute(query);
        }
      }
    } catch (e) {
      rethrow;
    }
  }
}
