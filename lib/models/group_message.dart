import 'package:silent_signal/models/group.dart';
import 'package:silent_signal/models/user.dart';

class GroupMessage {
  late int id;
  late String type;
  late String content;
  late User sender;
  late Group group;
  late DateTime createdAt;

  GroupMessage({
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
      'created_at': createdAt.toIso8601String(),
    };
  }
}
