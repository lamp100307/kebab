import 'package:args/command_runner.dart' as runner;

import '../config.dart';

export 'runner.dart';

enum CommandType { run, build, info }

abstract class Command extends runner.Command<void> {
  final CommandType command;
  static Config? _configCache;

  Command(this.command);

  Config get config => _configCache ??= Config(command, debug: debug);

  bool get debug => globalResults?['debug'] as bool? ?? false;
}
