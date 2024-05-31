import 'dart:convert';
import 'dart:io';

import 'package:silent_signal/database/group_repository.dart';
import 'package:silent_signal/database/message_repository.dart';
import 'package:silent_signal/database/user_repository.dart';
import 'package:silent_signal/models/group_message.dart';
import 'package:silent_signal/models/sensitive_user.dart';
import 'package:silent_signal/models/user.dart';
import 'package:silent_signal/server/http_response_builder.dart';

class GroupChatController {
  final groupRepository = GroupRepository();
  final userRepository = SensitiveUserRepository();
  final messageRepository = MessageRepository();
  static final broadcast = <String, List<Map<String, WebSocket>>>{};

  Future<void> handleConnection(
    HttpRequest request,
    Map<String, dynamic> claims,
  ) async {
    final user = await userRepository.fetchData(claims['username']);
    if (!WebSocketTransformer.isUpgradeRequest(request)) {
      HttpResponseBuilder.send(request.response).error(
        HttpStatus.badRequest,
        body: 'invalid websocket request',
      );
      return;
    }
    final socket = await WebSocketTransformer.upgrade(request);

    var selectedGroup = '';
    try {
      for (final group in user!.parcipateGroups) {
        if (broadcast.containsKey(group.name)) {
          final groupBroadcast = broadcast[group.name]!;
          groupBroadcast.add({user.name: socket});
        } else {
          broadcast[group.name] = [
            {user.name: socket}
          ];
        }
        final messages = await messageRepository.fetchAllGroupMessages(
          group.name,
        );
        socket.add(jsonEncode(
          messages
              .map(
                (message) => {
                  'sender': {
                    'name': message.sender.name,
                    'picture': message.sender.picture,
                  },
                  'group': {
                    'name': message.group.name,
                    'picture': message.group.picture,
                  },
                  'type': message.type,
                  'content': message.content,
                  'created_at': message.createdAt!.toIso8601String(),
                },
              )
              .toList(),
        ));
        _updatePendingSituation(group.messages, user.id!, group.id!);
      }

      socket.listen(
        (content) async {
          try {
            if (content is String) {
              final decodedMessage = jsonDecode(content);
              selectedGroup = decodedMessage['group'];
              final message = await _handleMessage(user, decodedMessage);
              socket.add(message);
            } else {
              socket.add('invalid input type');
              await socket.close();
            }
          } catch (e) {
            print(e);
            socket.add(e.toString());
            await socket.close();
          }
        },
        onDone: () {
          final groupBroadcast = broadcast[selectedGroup];
          if (groupBroadcast != null) {
            groupBroadcast.removeWhere(
              (element) => element.containsKey(user.name),
            );
          }
        },
        onError: (error) {
          print(error);
          final groupBroadcast = broadcast[selectedGroup];
          if (groupBroadcast != null) {
            groupBroadcast.removeWhere(
              (element) => element.containsKey(user.name),
            );
          }
        },
        cancelOnError: false,
      );
    } catch (e) {
      print(e);
      final groupBroadcast = broadcast[selectedGroup];
      if (groupBroadcast != null) {
        groupBroadcast.removeWhere(
          (element) => element.containsKey(user!.name),
        );
      }
      await socket.close();
    }
  }

  Future<String> _handleMessage(SensitiveUser user, decodedMessage) async {
    final group = await groupRepository.fetchByGroupName(
      decodedMessage['group'],
    );

    String message = jsonEncode({
      'sender': {
        'name': user.name,
        'picture': user.picture,
      },
      'group': {
        'name': group!.name,
        'picture': group.picture,
      },
      'type': decodedMessage['type'],
      'content': decodedMessage['content'],
      'created_at': DateTime.now().toIso8601String(),
    });

    final groupBroadcast = broadcast[decodedMessage['group']];
    final seenBy = <User>[];
    if (groupBroadcast != null) {
      for (final members in groupBroadcast) {
        for (final entry in members.entries) {
          if (entry.key != user.name) {
            entry.value.add(message);
            seenBy.add(User.dto(name: entry.key, picture: null));
          }
        }
      }
    }
    final groupMessageId = await messageRepository.saveGroupMessage(
      GroupMessage.dto(
        type: decodedMessage['type'],
        content: decodedMessage['content'],
        sender: User.id(id: user.id),
        group: group,
      ),
    );
    messageRepository.updateGroupMessagesPendingSituationAfter(
      groupMessageId,
      user.id!,
      group.id!,
    );
    return message;
  }

  Future<void> _updatePendingSituation(
    List<GroupMessage> messages,
    int userId,
    int groupId,
  ) async {
    if (messages.isNotEmpty) {
      final ids = messages.map((message) => message.id!).toList();
      await messageRepository.updateGroupMessagesPendingSituationOnStart(
        ids,
        userId,
        groupId,
      );
    }
  }
}
