import 'package:silent_signal/configs/initializer.dart';
import 'package:silent_signal/server/server.dart';

void main() async {
  await Initializer.initEnv();
  await Initializer.initPreloaders();

  final server = Server();
  await server.start();
}
