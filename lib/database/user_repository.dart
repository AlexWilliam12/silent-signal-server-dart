import 'package:postgres/postgres.dart';
import 'package:silent_signal/consts/user_consts.dart';
import 'package:silent_signal/database/manager.dart';
import 'package:silent_signal/models/group.dart';
import 'package:silent_signal/models/sensitive_user.dart';
import 'package:silent_signal/models/user.dart';
import 'package:silent_signal/utils/decoder.dart';

class SensitiveUserRepository {
  Future<bool> create(
    String username,
    String password,
    String credentialsHash,
  ) async {
    Connection? conn;
    try {
      conn = await ConnectionManager.getConnection();
      return await conn.runTx((session) async {
        final result = await session.execute(
          CREATE_USER,
          parameters: [username, password, credentialsHash],
        );
        return result.affectedRows > 0;
      });
    } catch (e) {
      rethrow;
    } finally {
      if (conn != null) {
        await conn.close();
      }
    }
  }

  Future<SensitiveUser?> fetchData(String username) async {
    Connection? conn;
    try {
      conn = await ConnectionManager.getConnection();
      final result = await conn.execute(
        FETCH_USER_DATA_QUERY,
        parameters: [username],
      );
      final row = result.firstOrNull;
      if (row == null) {
        return null;
      }
      final user = SensitiveUser(
        id: row[0] as int,
        name: row[1] as String,
        password: row[2] as String,
        credentialsHash: row[3] as String,
        picture: row[4] as String?,
        createdAt: row[5] as DateTime,
      );
      final contacts = decodeBytes(row[6] as UndecodedBytes);
      if (contacts != null) {
        final list = contacts as List<Map<String, dynamic>>;
        for (var element in list) {
          user.contacts.add(
            User(
              name: element['name'],
              picture: element['picture'],
            ),
          );
        }
      }
      final createdGroups = decodeBytes(row[7] as UndecodedBytes);
      if (createdGroups != null) {
        final list = createdGroups as List<Map<String, dynamic>>;
        for (var element in list) {
          user.createdGroups.add(
            Group(
              id: element['id'],
              name: element['group_name'],
              description: element['description'],
              picture: element['group_picture'],
              creator: User(
                name: element['creator_name'],
                picture: element['creator_picture'],
              ),
              createdAt: element['created_at'],
            ),
          );
        }
      }
      final parcipateGroups = decodeBytes(row[8] as UndecodedBytes);
      if (parcipateGroups != null) {
        final list = parcipateGroups as List<Map<String, dynamic>>;
        for (var element in list) {
          user.parcipateGroups.add(
            Group(
              id: element['id'],
              name: element['group_name'],
              description: element['description'],
              picture: element['group_picture'],
              creator: User(
                name: element['creator_name'],
                picture: element['creator_picture'],
              ),
              createdAt: element['created_at'],
            ),
          );
        }
      }
      return user;
    } catch (e) {
      rethrow;
    } finally {
      if (conn != null) {
        await conn.close();
      }
    }
  }

  Future<SensitiveUser?> fetchByCredentials(
    String username,
    String password,
  ) async {
    Connection? conn;
    try {
      conn = await ConnectionManager.getConnection();
      var result = await conn.execute(
        FETCH_USER_BY_CREDENTIALS,
        parameters: [username, password],
      );
      final row = result.firstOrNull;
      if (row == null) {
        return null;
      }
      return SensitiveUser(
        id: row[0] as int,
        name: row[1] as String,
        password: row[2] as String,
        credentialsHash: row[3] as String,
        picture: row[4] as String?,
        createdAt: row[5] as DateTime,
      );
    } catch (e) {
      rethrow;
    } finally {
      if (conn != null) {
        await conn.close();
      }
    }
  }

  Future<SensitiveUser?> fetchByHash(String hash) async {
    Connection? conn;
    try {
      conn = await ConnectionManager.getConnection();
      var result = await conn.execute(
        FETCH_USER_BY_HASH,
        parameters: [hash],
      );
      final row = result.firstOrNull;
      if (row == null) {
        return null;
      }
      return SensitiveUser(
        id: row[0] as int,
        name: row[1] as String,
        password: row[2] as String,
        credentialsHash: row[3] as String,
        picture: row[4] as String?,
        createdAt: row[5] as DateTime,
      );
    } catch (e) {
      rethrow;
    } finally {
      if (conn != null) {
        await conn.close();
      }
    }
  }

  Future<SensitiveUser?> fetchByUsername(String username) async {
    Connection? conn;
    try {
      conn = await ConnectionManager.getConnection();
      var result = await conn.execute(
        FETCH_USER_BY_USERNAME,
        parameters: [username],
      );
      final row = result.firstOrNull;
      if (row == null) {
        return null;
      }
      return SensitiveUser(
        id: row[0] as int,
        name: row[1] as String,
        password: row[2] as String,
        credentialsHash: row[3] as String,
        picture: row[4] as String?,
        createdAt: row[5] as DateTime,
      );
    } catch (e) {
      rethrow;
    } finally {
      if (conn != null) {
        await conn.close();
      }
    }
  }

  Future<bool> update(SensitiveUser user) async {
    Connection? conn;
    try {
      conn = await ConnectionManager.getConnection();
      return await conn.runTx((session) async {
        final result = await session.execute(
          Sql.named(UPDATE_USER),
          parameters: {
            'id': user.id,
            'username': user.name,
            'password': user.password,
            'credentials_hash': user.credentialsHash,
            'picture': user.picture,
          },
        );
        return result.affectedRows > 0;
      });
    } catch (e) {
      rethrow;
    } finally {
      if (conn != null) {
        await conn.close();
      }
    }
  }

  Future<bool> delete(String username) async {
    Connection? conn;
    try {
      conn = await ConnectionManager.getConnection();
      return await conn.runTx((session) async {
        final result = await session.execute(
          DELETE_USER,
          parameters: [username],
        );
        return result.affectedRows > 0;
      });
    } catch (e) {
      rethrow;
    } finally {
      if (conn != null) {
        await conn.close();
      }
    }
  }

  Future<bool> saveContact(int userId, int contactId) async {
    Connection? conn;
    try {
      conn = await ConnectionManager.getConnection();
      return await conn.runTx((session) async {
        final result = await session.execute(
          SAVE_USE_CONTACT,
          parameters: [userId, contactId],
        );
        return result.affectedRows > 0;
      });
    } catch (e) {
      rethrow;
    } finally {
      if (conn != null) {
        await conn.close();
      }
    }
  }
}
