import 'package:silent_signal/models/user.dart';

class PrivateMessage {
  late int id;
  late String type;
  late String content;
  late bool isPending;
  late DateTime createdAt;
  late User sender;
  late User recipient;

  PrivateMessage({
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
      'created_at': createdAt.toIso8601String(),
      'sender': sender,
      'recipient': recipient,
    };
  }
}
