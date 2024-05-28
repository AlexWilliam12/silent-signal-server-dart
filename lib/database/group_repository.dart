import 'dart:convert';

import 'package:postgres/postgres.dart';
import 'package:silent_signal/consts/group_consts.dart';
import 'package:silent_signal/database/manager.dart';
import 'package:silent_signal/models/group.dart';
import 'package:silent_signal/models/user.dart';

class GroupRepository {
  Future<bool> create(Group group) async {
    Connection? conn;
    try {
      conn = await ConnectionManager.getConnection();
      return await conn.runTx((session) async {
        final result = await session.execute(
          CREATE_GROUP,
          parameters: [group.name, group.description, group.creator.id!],
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
      final result = await conn.execute(FETCH_GROUPS);
      List<Group> groups = [];
      for (final row in result) {
        final creator = jsonDecode(row[4].toString());
        groups.add(
          Group.model(
            id: row[0] as int,
            name: row[1] as String,
            description: row[2] as String?,
            picture: row[3] as String?,
            creator: User.dto(
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
      final result = await conn.execute(
        FETCH_GROUP_BY_NAME,
        parameters: [groupName],
      );
      final row = result.firstOrNull;
      if (row == null) {
        return null;
      }
      final creator = jsonDecode(row[4].toString());
      return Group.model(
        id: row[0] as int,
        name: row[1] as String,
        description: row[2] as String?,
        picture: row[3] as String?,
        creator: User.dto(
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

  Future<Group?> fetchByGroupNameAndCreator(
    String groupName,
    int creatorId,
  ) async {
    Connection? conn;
    try {
      conn = await ConnectionManager.getConnection();
      final result = await conn.execute(
        FETCH_GROUP_BY_NAME_AND_CREATOR,
        parameters: [groupName, creatorId],
      );
      final row = result.firstOrNull;
      if (row == null) {
        return null;
      }
      final creator = jsonDecode(row[4].toString());
      return Group.model(
        id: row[0] as int,
        name: row[1] as String,
        description: row[2] as String?,
        picture: row[3] as String?,
        creator: User.dto(
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

  Future<bool> update(Group group) async {
    Connection? conn;
    try {
      conn = await ConnectionManager.getConnection();
      return await conn.runTx((session) async {
        final result = await session.execute(
          UPDATE_GROUP,
          parameters: {
            'id': group.id,
            'group_name': group.name,
            'description': group.description,
            'picture': group.picture,
            'creator_id': group.creator.id!,
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

  Future<bool> delete(int groupId) async {
    Connection? conn;
    try {
      conn = await ConnectionManager.getConnection();
      return await conn.runTx((session) async {
        final result = await session.execute(
          DELETE_GROUP,
          parameters: [groupId],
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
