import 'dart:convert';
import 'dart:io';

void main() async {
  print('Enter your token:');
  final token = stdin.readLineSync();
  if (token == null) {
    throw ArgumentError('token cannot be null');
  }

  print('Group name:');
  final group = stdin.readLineSync();
  if (group == null) {
    throw ArgumentError('group cannot be null');
  }
  print('\n');

  try {
    final socket = await WebSocket.connect(
      'ws://192.168.0.117:8080/chat/group',
      headers: {'Authorization': 'Bearer $token'},
    );

    socket.listen(
      (message) {
        print(jsonDecode(message));
      },
      onDone: () {
        print('Connection closed by the server');
      },
      onError: (error) async {
        print(error);
        await socket.close();
      },
      cancelOnError: true,
    );

    await _sendMessage(socket, group);
  } catch (e) {
    print(e);
  }
}

Future<void> _sendMessage(WebSocket socket, String group) async {
  await for (var input in stdin
      .transform(
        utf8.decoder,
      )
      .transform(
        LineSplitter(),
      )) {
    if (input.isNotEmpty) {
      socket.add(
        jsonEncode(
          {
            'group': group,
            'type': 'text',
            'content': input,
          },
        ),
      );
    }
  }
}
