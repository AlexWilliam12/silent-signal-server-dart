import 'package:postgres/postgres.dart';
import 'package:silent_signal/models/group.dart';
import 'package:silent_signal/models/user.dart';

class SensitiveUser {
  int? id;
  String name;
  String password;
  String credentialsHash;
  String? picture;
  DateTime? createdAt;
  Interval? temporaryMessageInterval;
  final List<Group> createdGroups = [];
  final List<Group> parcipateGroups = [];
  final List<User> contacts = [];

  SensitiveUser.dto({
    required this.name,
    required this.password,
    required this.credentialsHash,
  });

  SensitiveUser.model({
    required this.id,
    required this.name,
    required this.password,
    required this.credentialsHash,
    required this.picture,
    required this.createdAt,
    required this.temporaryMessageInterval,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'credentials_hash': credentialsHash,
      'picture': picture,
      'created_at': createdAt!.toIso8601String(),
      'time': temporaryMessageInterval?.toString(),
      'created_groups': createdGroups,
      'parcipate_groups': parcipateGroups,
      'contacts': contacts,
    };
  }
}
