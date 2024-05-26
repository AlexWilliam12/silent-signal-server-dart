import 'dart:convert';

import 'package:postgres/postgres.dart';

dynamic decodeBytes(UndecodedBytes bytes) {
  final decode = bytes.asString.trim();
  return decode.isNotEmpty && !decode.contains('r') ? jsonDecode(decode) : null;
}
