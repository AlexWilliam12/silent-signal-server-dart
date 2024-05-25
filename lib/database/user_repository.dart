import 'package:postgres/postgres.dart';
import 'package:silent_signal/consts/user_consts.dart';
import 'package:silent_signal/database/manager.dart';
import 'package:silent_signal/models/sensitive_user.dart';

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

  // Future<SensitiveUser?> fetchData(String username) async {
  //   Connection? conn;
  //   try {
  //     conn = await ConnectionManager.getConnection();
  //     final result = await conn.execute(
  //       FETCH_USER_DATA_QUERY,
  //       parameters: [username],
  //     );
  //     final row = result.firstOrNull;
  //     if (row == null) {
  //       return null;
  //     }
  //     final user = SensitiveUser(
  //       id: row[0] as int,
  //       username: row[1] as String,
  //       password: row[2] as String,
  //       credentialsHash: row[3] as String,
  //       picture: row[4] as String?,
  //       createdAt: row[5] as DateTime,
  //     );
  //     final contacts = decodeBytes(row[6] as UndecodedBytes);
  //     if (contacts != null) {
  //       final list = contacts as List<Map<String, dynamic>>;
  //       for (var element in list) {
  //         user.contacts.add(
  //           User(
  //             name: element['name'],
  //             picture: element['picture'],
  //           ),
  //         );
  //       }
  //     }
  //     final messages = decodeBytes(row[7] as UndecodedBytes);
  //     if (messages != null) {
  //       var list = messages as List<Map<String, dynamic>>;
  //       for (var element in list) {
  //         user.messages.add(
  //           PrivateMessage(
  //             id: int.parse(element['id']),
  //             type: element['type'],
  //             content: element['content'],
  //             isPending: element['is_pending'],
  //             createdAt: createdAt,
  //             sender: sender,
  //             recipient: recipient,
  //           ),
  //         );
  //       }
  //     }
  //     return user;
  //   } finally {
  //     if (conn != null) {
  //       await conn.close();
  //     }
  //   }
  // }

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
        username: row[1] as String,
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
        username: row[1] as String,
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
        username: row[1] as String,
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
            'username': user.username,
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
