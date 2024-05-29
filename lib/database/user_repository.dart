import 'package:postgres/postgres.dart';
import 'package:silent_signal/consts/user_consts.dart';
import 'package:silent_signal/database/manager.dart';
import 'package:silent_signal/models/group.dart';
import 'package:silent_signal/models/sensitive_user.dart';
import 'package:silent_signal/models/user.dart';

class SensitiveUserRepository {
  Future<bool> create(SensitiveUser user) async {
    Connection? conn;
    try {
      conn = await ConnectionManager.getConnection();
      return await conn.runTx((session) async {
        final result = await session.execute(
          CREATE_USER,
          parameters: [user.name, user.password, user.credentialsHash],
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
      final user = SensitiveUser.model(
        id: row[0] as int,
        name: row[1] as String,
        password: row[2] as String,
        credentialsHash: row[3] as String,
        picture: row[4] as String?,
        createdAt: row[5] as DateTime,
      );
      if (row[6] != null) {
        final list = row[6] as List<dynamic>;
        for (final element in list) {
          user.contacts.add(
            User.dto(
              name: element['name'],
              picture: element['picture'],
            ),
          );
        }
      }
      if (row[7] != null) {
        final list = row[7] as List<dynamic>;
        for (final element in list) {
          user.createdGroups.add(
            Group.model(
              id: element['id'] as int,
              name: element['group_name'] as String,
              description: element['description'] as String?,
              picture: element['group_picture'] as String?,
              creator: User.id(id: null),
              createdAt: DateTime.parse(element['created_at']),
            ),
          );
        }
      }
      if (row[8] != null) {
        final list = row[8] as List<dynamic>;
        for (final element in list) {
          user.parcipateGroups.add(
            Group.model(
              id: element['id'],
              name: element['group_name'],
              description: element['description'],
              picture: element['group_picture'],
              creator: User.dto(
                name: element['creator_name'],
                picture: element['creator_picture'],
              ),
              createdAt: DateTime.parse(element['created_at']),
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
      final result = await conn.execute(
        FETCH_USER_BY_CREDENTIALS,
        parameters: [username, password],
      );
      final row = result.firstOrNull;
      if (row == null) {
        return null;
      }
      return SensitiveUser.model(
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

  Future<SensitiveUser?> fetchByHash(String credentialsHash) async {
    Connection? conn;
    try {
      conn = await ConnectionManager.getConnection();
      final result = await conn.execute(
        FETCH_USER_BY_HASH,
        parameters: [credentialsHash],
      );
      final row = result.firstOrNull;
      if (row == null) {
        return null;
      }
      return SensitiveUser.model(
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
      final result = await conn.execute(
        FETCH_USER_BY_USERNAME,
        parameters: [username],
      );
      final row = result.firstOrNull;
      if (row == null) {
        return null;
      }
      final user = SensitiveUser.model(
        id: row[0] as int,
        name: row[1] as String,
        password: row[2] as String,
        credentialsHash: row[3] as String,
        picture: row[4] as String?,
        createdAt: row[5] as DateTime,
      );
      user.temporaryMessageInterval = row[6] as String?;
      return user;
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

  Future<bool> delete(int userId) async {
    Connection? conn;
    try {
      conn = await ConnectionManager.getConnection();
      return await conn.runTx((session) async {
        final result = await session.execute(
          DELETE_USER,
          parameters: [userId],
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

  Future<bool> updateTemporaryMessages(String username, String? time) async {
    Connection? conn;
    try {
      conn = await ConnectionManager.getConnection();
      return await conn.runTx((session) async {
        final result = await session.execute(
          Sql.named(ENABLE_TEMPORARY_MESSAGES),
          parameters: {
            'username': username,
            'interval': time,
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
}
