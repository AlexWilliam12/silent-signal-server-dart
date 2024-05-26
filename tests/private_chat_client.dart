import 'dart:io';

const token =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3MTY3ODM4MzgyOTMsInVzZXJuYW1lIjoiSm9lIn0=.1XGuKtIzFjRfiR1QclB5SrlSVv_eMhJ9R6FPHIyckPk=';

void main() {
  WebSocket.connect(
    'ws://192.168.0.117:8080/chat/private?contact=Rick',
    headers: {'Authorization': 'Bearer $token'},
  ).then((socket) {
    socket.add('Hi!');
    socket.listen(
      (message) {
        print(message);
      },
      onDone: () => print('Done!'),
      onError: (error) => print(error),
      cancelOnError: true,
    );
  }).catchError(
    (error) {
      print(error);
    },
  );
}
