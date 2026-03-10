import 'dart:io' show Process;

import 'package:kebab/commands/build.dart';
import 'package:kebab/config.dart';
import 'commands.dart';

final class CommandRun implements ICommand {
  @override
  final Config config;

  const CommandRun(this.config);

  @override
  void execute() {
    CommandBuild(config).execute();

    final runResult = Process.runSync(config.outputFile.path, []);

    if (runResult.exitCode == 0) {
      print(runResult.stdout);
    } else {
      print('Execution failed:\n${runResult.stderr}');
    }
  }
}
