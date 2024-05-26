import 'package:silent_signal/models/group_message.dart';
import 'package:silent_signal/models/user.dart';

class Group {
  late int id;
  late String name;
  late String? description;
  late String? picture;
  late User creator;
  late DateTime createdAt;
  final List<User> members = [];
  final List<GroupMessage> messages = [];

  Group({
    required this.id,
    required this.name,
    required this.description,
    required this.picture,
    required this.creator,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'picture': picture,
      'creator': creator,
      'created_at': createdAt.toIso8601String(),
      'members': members,
      'messages': messages,
    };
  }
}
