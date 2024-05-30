import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:silent_signal/configs/environment.dart';

final secret = Environment.getProperty('SECRET_KEY')!;

String generateJWT(String username) {
  try {
    String header =
        base64Url.encode(utf8.encode('{"alg":"HS256","typ":"JWT"}'));
    int expiration = DateTime.now()
            .add(Duration(
              hours: 24,
            ))
            .microsecondsSinceEpoch ~/
        1000;
    String payload = base64Url.encode(utf8.encode(json.encode({
      'exp': expiration,
      'username': username,
    })));
    String signature = base64Url.encode(Hmac(
      sha256,
      utf8.encode(secret),
    ).convert('$header.$payload'.codeUnits).bytes);
    return '$header.$payload.$signature';
  } catch (e) {
    rethrow;
  }
}

bool validateJWT(String token) {
  try {
    final parts = token.split('.');
    if (parts.length != 3) {
      return false;
    }

    final signature = base64Url.encode(Hmac(
      sha256,
      utf8.encode(secret),
    ).convert('${parts[0]}.${parts[1]}'.codeUnits).bytes);

    if (parts[2] != signature) {
      return false;
    }

    final payload = json.decode(
      utf8.decode(
        base64Url.decode(
          base64Url.normalize(parts[1]),
        ),
      ),
    );

    if (payload.containsKey('exp')) {
      final expiration = payload['exp'] * 1000;
      if (DateTime.now().millisecondsSinceEpoch > expiration) {
        return false;
      }
    }
    return true;
  } catch (e) {
    rethrow;
  }
}

Map<String, dynamic> getClaims(String token) {
  try {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('Invalid token');
    }

    final payload = json.decode(
      utf8.decode(
        base64Url.decode(
          base64Url.normalize(parts[1]),
        ),
      ),
    );
    return payload;
  } catch (e) {
    rethrow;
  }
}
