import 'package:args/command_runner.dart' as runner;

import 'commands.dart';

class CommandRunner extends runner.CommandRunner<void> {
  CommandRunner() : super('kebab', 'Kebab CLI tool') {
    addCommand(RunCommand());
    addCommand(BuildCommand());
    argParser.addFlag(
      'debug',
      abbr: 'd',
      help: 'Enable debug mode',
    );
  }
}
