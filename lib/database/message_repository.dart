import 'dart:convert';

import 'package:postgres/postgres.dart';
import 'package:silent_signal/consts/message_consts.dart';
import 'package:silent_signal/database/manager.dart';
import 'package:silent_signal/models/group_message.dart';
import 'package:silent_signal/models/private_message.dart';
import 'package:silent_signal/models/user.dart';

class MessageRepository {
  Future<List<PrivateMessage>> fetchAllPrivateMessages(String username) async {
    Connection? conn;
    try {
      conn = await ConnectionManager.getConnection();
      final result = await conn.execute(
        FETCH_ALL_PRIVATE_MESSAGES,
        parameters: [username],
      );
      final list = <PrivateMessage>[];
      for (final row in result) {
        final sender = jsonDecode(row[6] as String);
        final recipient = jsonDecode(row[7] as String);
        list.add(
          PrivateMessage(
            id: row[0] as int,
            type: row[1] as String,
            content: row[2] as String,
            isPending: row[3] as bool,
            createdAt: row[4] as DateTime,
            sender: User(
              name: sender['name'],
              picture: sender['picture'],
            ),
            recipient: User(
              name: recipient['name'],
              picture: recipient['picture'],
            ),
          ),
        );
      }
      return list;
    } catch (e) {
      rethrow;
    } finally {
      if (conn != null) {
        await conn.close();
      }
    }
  }

  Future<bool> savePrivateMessage(PrivateMessage message) async {
    Connection? conn;
    try {
      conn = await ConnectionManager.getConnection();
      return await conn.runTx((session) async {
        final result = await session.execute(
          SAVE_PRIVATE_MESSAGE,
          parameters: [
            message.type,
            message.content,
            message.sender.id!,
            message.recipient.id!,
            message.isPending,
          ],
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

  Future<bool> saveGroupMessage(GroupMessage message) async {
    Connection? conn;
    try {
      conn = await ConnectionManager.getConnection();
      return await conn.runTx((session) async {
        final result = await session.execute(
          SAVE_GROUP_MESSAGE,
          parameters: [
            message.type,
            message.content,
            message.sender.id!,
            message.group.id,
          ],
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

  Future<bool> deletePrivateMessage(int messageId) async {
    Connection? conn;
    try {
      conn = await ConnectionManager.getConnection();
      return await conn.runTx((session) async {
        final result = await session.execute(
          DELETE_PRIVATE_MESSAGE,
          parameters: [messageId],
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

  Future<bool> deleteGroupMessage(int messageId) async {
    Connection? conn;
    try {
      conn = await ConnectionManager.getConnection();
      return await conn.runTx((session) async {
        final result = await session.execute(
          DELETE_GROUP_MESSAGE,
          parameters: [messageId],
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
