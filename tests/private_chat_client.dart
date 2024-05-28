import 'dart:io';

const token =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3MTY5MTgxNTc0NzIsInVzZXJuYW1lIjoiSm9lIn0=.UVwlyb85pRZN14iVW9fOR3vY10pWUbmfSsv0mTMLq8s=';

void main() {
  final uri = Uri.http('192.168.0.117:8080', '/chat/private', {
    'recipient': 'Rick',
    'type': 'text',
  });
  var url = uri.toString().replaceFirst('http://', 'ws://');

  WebSocket.connect(url, headers: {'Authorization': 'Bearer $token'}).then(
    (socket) {
      socket.add('Hi!');
      Map<String, dynamic> query = Map.from(uri.queryParameters);
      query['type'] = 'other';
      uri.replace(queryParameters: query);
      url = uri.toString().replaceFirst('http://', 'ws://');
      socket.add('Hi!');

      socket.listen(
        (message) {
          print(message);
        },
        onDone: () => print('Done!'),
        onError: (error) => print(error),
        cancelOnError: true,
      );
    },
  ).catchError(
    (error) {
      print(error);
    },
  );
}
