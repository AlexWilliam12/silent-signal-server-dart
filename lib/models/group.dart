import 'package:silent_signal/models/group_message.dart';
import 'package:silent_signal/models/user.dart';

class Group {
  int? id;
  String name;
  String? description;
  String? picture;
  User creator;
  DateTime? createdAt;
  final List<User> members = [];
  final List<GroupMessage> messages = [];

  Group.dto({
    required this.name,
    required this.description,
    required this.picture,
    required this.creator,
  });

  Group.model({
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
      'created_at': createdAt!.toIso8601String(),
      'members': members,
      'messages': messages,
    };
  }
}
