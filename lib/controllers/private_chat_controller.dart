import 'dart:convert';
import 'dart:io';

import 'package:silent_signal/database/message_repository.dart';
import 'package:silent_signal/database/user_repository.dart';
import 'package:silent_signal/models/private_message.dart';
import 'package:silent_signal/models/sensitive_user.dart';
import 'package:silent_signal/models/user.dart';
import 'package:silent_signal/server/http_response_builder.dart';

class PrivateChatController {
  final userRepository = SensitiveUserRepository();
  final messageRepository = MessageRepository();
  static final broadcast = <String, WebSocket>{};

  Future<void> handleConnection(
    HttpRequest request,
    Map<String, dynamic> claims,
  ) async {
    final user = await userRepository.fetchByUsername(claims['username']);
    if (!WebSocketTransformer.isUpgradeRequest(request)) {
      HttpResponseBuilder.send(request.response).error(
        HttpStatus.badRequest,
        body: 'invalid websocket request',
      );
      return;
    }
    final socket = await WebSocketTransformer.upgrade(request);
    broadcast[user!.name] = socket;

    try {
      final messages = await messageRepository.fetchAllPrivateMessages(
        user.name,
      );
      socket.add(jsonEncode(
        messages
            .map(
              (message) => {
                'sender': {
                  'name': message.sender.name,
                  'picture': message.sender.picture,
                },
                'recipient': {
                  'name': message.recipient.name,
                  'picture': message.recipient.picture,
                },
                'type': message.type,
                'content': message.content,
                'created_at': message.createdAt!.toIso8601String(),
              },
            )
            .toList(),
      ));
      _updatePendingSituation(messages);

      socket.listen(
        (content) async {
          try {
            if (content is String) {
              final decodedMessage = jsonDecode(content);
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
          broadcast.remove(user.name);
        },
        onError: (error) {
          print(error);
          broadcast.remove(user.name);
        },
        cancelOnError: false,
      );
    } catch (e) {
      print(e);
      broadcast.remove(user.name);
      await socket.close();
    }
  }

  Future<String> _handleMessage(SensitiveUser sender, decodedMessage) async {
    try {
      final recipient = await userRepository.fetchByUsername(
        decodedMessage['recipient']!,
      );
      if (recipient == null) {
        throw ArgumentError('recipient not found');
      }

      String message = jsonEncode({
        'sender': {
          'name': sender.name,
          'picture': sender.picture,
        },
        'recipient': {
          'name': recipient.name,
          'picture': recipient.picture,
        },
        'type': decodedMessage['type'],
        'content': decodedMessage['content'],
        'created_at': DateTime.now().toIso8601String(),
      });

      final socket = broadcast[recipient.name];
      bool isPending = true;
      if (socket != null) {
        socket.add(message);
        isPending = false;
      }
      messageRepository.savePrivateMessage(
        PrivateMessage.dto(
          type: decodedMessage['type'],
          content: decodedMessage['content'],
          isPending: isPending,
          sender: User.id(id: sender.id),
          recipient: User.id(id: recipient.id),
          isTemporaryMessage: sender.temporaryMessageInterval != null,
        ),
      );
      return message;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _updatePendingSituation(List<PrivateMessage> messages) async {
    if (messages.isNotEmpty) {
      final ids = messages.map((message) => message.id!).toList();
      await messageRepository.updatePrivateMessagesPendingSituation(ids);
    }
  }
}
