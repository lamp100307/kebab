import 'dart:io' show Process;

import 'package:kebab/commands/build.dart';
import 'commands.dart';

final class CommandRun extends KebabCommand {
  @override
  final String name = 'run';
  @override
  final String description = 'Run the application';

  CommandRun() : super(CommandType.run) {
    argParser
      ..addOption('input', abbr: 'i', help: 'Input file path')
      ..addOption('output', abbr: 'o', help: 'Output file path');
  }

  @override
  void run() {
    CommandBuild().build(config);
    final runResult = Process.runSync(config.outputFile.path, []);

    if (runResult.exitCode == 0) {
      print(runResult.stdout);
    } else {
      print('Execution failed:\n${runResult.stderr}');
    }
  }
}
