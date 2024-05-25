import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

const charset = 'abcdefghijklmnopqrstuvwxyz0123456789';

String generateCredentialsHash(String username, String password) {
  final random = Random.secure();
  final salt = List.generate(
    16,
    (_) => charset[random.nextInt(charset.length)],
  ).join();
  final data = username + password + salt;
  final digest = sha256.convert(utf8.encode(data));
  return digest.toString();
}
