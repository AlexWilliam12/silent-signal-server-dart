import 'package:postgres/postgres.dart';
import 'package:silent_signal/consts/message_consts.dart';
import 'package:silent_signal/database/manager.dart';
import 'package:silent_signal/models/group.dart';
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
        final sender = row[4] as Map<String, dynamic>;
        final recipient = row[5] as Map<String, dynamic>;
        list.add(
          PrivateMessage.model(
            id: row[0] as int,
            type: row[1] as String,
            content: row[2] as String,
            isPending: row[3] as bool,
            createdAt: row[6] as DateTime,
            sender: User.dto(
              name: sender['name'],
              picture: sender['picture'],
            ),
            recipient: User.dto(
              name: recipient['name'],
              picture: recipient['picture'],
            ),
            isTemporaryMessage: row[7] as bool,
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

  Future<List<GroupMessage>> fetchAllGroupMessages(String groupName) async {
    Connection? conn;
    try {
      conn = await ConnectionManager.getConnection();
      final result = await conn.execute(
        FETCH_ALL_GROUP_MESSAGES,
        parameters: [groupName],
      );
      final list = <GroupMessage>[];
      for (final row in result) {
        final sender = row[3] as Map<String, dynamic>;
        final group = row[4] as Map<String, dynamic>;
        list.add(
          GroupMessage.model(
            id: row[0] as int,
            type: row[1] as String,
            content: row[2] as String,
            sender: User.dto(
              name: sender['name'],
              picture: sender['picture'],
            ),
            group: Group.dto(
              name: group['name'],
              description: group['description'],
              picture: group['picture'],
              creator: User.dto(
                name: group['creator']['name'],
                picture: group['creator']['picture'],
              ),
            ),
            createdAt: row[5] as DateTime,
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
            message.isTemporaryMessage,
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

  Future<int> saveGroupMessage(GroupMessage message) async {
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
        return result.first[0] as int;
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

  Future<void> updatePrivateMessagesPendingSituation(List<int> ids) async {
    Connection? conn;
    try {
      final placeholder = List.generate(
        ids.length,
        (index) => '@p$index',
      ).join(',');
      Map<String, dynamic> values = {
        for (var i = 0; i < ids.length; i++) 'p$i': ids[i],
      };
      conn = await ConnectionManager.getConnection();
      await conn.runTx((session) async {
        await session.execute(
          Sql.named('''
              UPDATE private_messages SET
                is_pending = FALSE
              WHERE id IN ($placeholder) AND is_pending = TRUE
            '''),
          parameters: values,
        );
      });
    } catch (e) {
      rethrow;
    } finally {
      if (conn != null) {
        await conn.close();
      }
    }
  }

  Future<void> updateGroupMessagesPendingSituationOnStart(
    List<int> ids,
    int userId,
    int groupId,
  ) async {
    Connection? conn;
    try {
      conn = await ConnectionManager.getConnection();
      await conn.runTx((session) async {
        for (final id in ids) {
          await session.execute(
            INSERT_MESSAGE_SEEN_BY,
            parameters: [id, userId, groupId],
          );
        }
      });
    } catch (e) {
      rethrow;
    } finally {
      if (conn != null) {
        await conn.close();
      }
    }
  }

  Future<void> updateGroupMessagesPendingSituationAfter(
    int groupMessageId,
    int userId,
    int groupId,
  ) async {
    Connection? conn;
    try {
      conn = await ConnectionManager.getConnection();
      await conn.runTx((session) async {
        await session.execute(
          INSERT_MESSAGE_SEEN_BY,
          parameters: [groupMessageId, userId, groupId],
        );
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
