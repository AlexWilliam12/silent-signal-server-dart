import 'dart:convert';

import 'package:postgres/postgres.dart';

dynamic decodeBytes(UndecodedBytes bytes) {
  final decode = utf8.decode(bytes.bytes);
  return decode.isNotEmpty ? jsonDecode(decode) : null;
}
