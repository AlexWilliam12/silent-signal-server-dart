import 'package:silent_signal/models/user.dart';

class PrivateMessage {
  int? id;
  String type;
  String content;
  bool isPending;
  DateTime? createdAt;
  User sender;
  User recipient;

  PrivateMessage.dto({
    required this.type,
    required this.content,
    required this.isPending,
    required this.sender,
    required this.recipient,
  });

  PrivateMessage.model({
    required this.id,
    required this.type,
    required this.content,
    required this.isPending,
    required this.createdAt,
    required this.sender,
    required this.recipient,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'content': content,
      'is_pending': isPending,
      'created_at': createdAt!.toIso8601String(),
      'sender': sender,
      'recipient': recipient,
    };
  }
}
