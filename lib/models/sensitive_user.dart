import 'package:silent_signal/models/group.dart';
import 'package:silent_signal/models/private_message.dart';
import 'package:silent_signal/models/user.dart';

class SensitiveUser {
  late int id;
  late String username;
  late String password;
  late String credentialsHash;
  late String? picture;
  late DateTime createdAt;
  final List<PrivateMessage> messages = [];
  final List<Group> createdGroups = [];
  final List<Group> parcipateGroups = [];
  final List<User> contacts = [];

  SensitiveUser({
    required this.id,
    required this.username,
    required this.password,
    required this.credentialsHash,
    required this.picture,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'credentials_hash': credentialsHash,
      'picture': picture,
      'created_at': createdAt.toIso8601String(),
      'messages': messages,
      'created_groups': createdGroups,
      'parcipate_groups': parcipateGroups,
      'contacts': contacts,
    };
  }
}
