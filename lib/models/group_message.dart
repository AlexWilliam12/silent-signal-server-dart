import 'package:silent_signal/models/group.dart';
import 'package:silent_signal/models/user.dart';

class GroupMessage {
  int? id;
  String type;
  String content;
  User sender;
  Group group;
  DateTime? createdAt;

  GroupMessage.dto({
    required this.type,
    required this.content,
    required this.sender,
    required this.group,
  });

  GroupMessage.model({
    required this.id,
    required this.type,
    required this.content,
    required this.sender,
    required this.group,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'content': content,
      'sender': sender,
      'group': group,
      'created_at': createdAt!.toIso8601String(),
    };
  }
}
