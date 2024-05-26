import 'package:silent_signal/models/group.dart';
import 'package:silent_signal/models/user.dart';

class SensitiveUser {
  late int id;
  late String name;
  late String password;
  late String credentialsHash;
  late String? picture;
  late DateTime createdAt;
  final List<Group> createdGroups = [];
  final List<Group> parcipateGroups = [];
  final List<User> contacts = [];

  SensitiveUser({
    required this.id,
    required this.name,
    required this.password,
    required this.credentialsHash,
    required this.picture,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'password': password,
      'credentials_hash': credentialsHash,
      'picture': picture,
      'created_at': createdAt.toIso8601String(),
      'created_groups': createdGroups,
      'parcipate_groups': parcipateGroups,
      'contacts': contacts,
    };
  }
}
