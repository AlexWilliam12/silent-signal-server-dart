import 'package:postgres/postgres.dart';
import 'package:silent_signal/consts/group_consts.dart';
import 'package:silent_signal/database/manager.dart';
import 'package:silent_signal/models/group.dart';
import 'package:silent_signal/models/user.dart';
import 'package:silent_signal/utils/decoder.dart';

class GroupRepository {
  Future<bool> create(
    String groupName,
    String description,
    int creatorId,
  ) async {
    Connection? conn;
    try {
      conn = await ConnectionManager.getConnection();
      return await conn.runTx((session) async {
        final result = await session.execute(
          CREATE_GROUP,
          parameters: [groupName, description, creatorId],
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

  Future<List<Group>> fetchGroups() async {
    Connection? conn;
    try {
      conn = await ConnectionManager.getConnection();
      var result = await conn.execute(FETCH_GROUPS);
      List<Group> groups = [];
      for (var row in result) {
        final creator = decodeBytes(
          row[4] as UndecodedBytes,
        ) as Map<String, dynamic>;
        groups.add(
          Group(
            id: row[0] as int,
            groupName: row[1] as String,
            description: row[2] as String?,
            picture: row[3] as String?,
            creator: User(
              name: creator['name'],
              picture: creator['picture'],
            ),
            createdAt: row[5] as DateTime,
          ),
        );
      }
      return groups;
    } catch (e) {
      rethrow;
    } finally {
      if (conn != null) {
        await conn.close();
      }
    }
  }

  Future<Group?> fetchByGroupName(String groupName) async {
    Connection? conn;
    try {
      conn = await ConnectionManager.getConnection();
      var result = await conn.execute(
        FETCH_GROUP_BY_NAME,
        parameters: [groupName],
      );
      final row = result.firstOrNull;
      if (row == null) {
        return null;
      }
      final creator = decodeBytes(
        row[4] as UndecodedBytes,
      ) as Map<String, dynamic>;
      return Group(
        id: row[0] as int,
        groupName: row[1] as String,
        description: row[2] as String?,
        picture: row[3] as String?,
        creator: User(
          name: creator['name'],
          picture: creator['picture'],
        ),
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

  Future<bool> update(Group group, int creatorId) async {
    Connection? conn;
    try {
      conn = await ConnectionManager.getConnection();
      return await conn.runTx((session) async {
        final result = await session.execute(
          UPDATE_GROUP,
          parameters: {
            'id': group.id,
            'group_name': group.groupName,
            'description': group.description,
            'picture': group.picture,
            'creator_id': creatorId,
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

  Future<bool> delete(String groupName) async {
    Connection? conn;
    try {
      conn = await ConnectionManager.getConnection();
      return await conn.runTx((session) async {
        final result = await session.execute(
          DELETE_GROUP,
          parameters: [groupName],
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
