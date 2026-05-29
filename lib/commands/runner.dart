import 'package:args/command_runner.dart' as runner;

import './build.dart';
import './run.dart';

class CommandRunner extends runner.CommandRunner<void> {
  CommandRunner() : super('kebab', 'Kebab CLI tool') {
    addCommand(CommandBuild());
    addCommand(CommandRun());

    argParser.addFlag('debug', abbr: 'd', help: 'Enable debug mode');
  }
}
