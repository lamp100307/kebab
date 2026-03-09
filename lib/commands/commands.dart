export 'runner.dart';

import 'dart:io' show File;

import 'package:args/command_runner.dart' as runner;
import 'package:kebab/config.dart';

import 'build.dart';
import 'run.dart';

abstract interface class ICommand {
  final Config config;

  const ICommand(this.config);

  void execute();
}

enum CommandType {
  run,
  build;

  static CommandType fromString(final String value) {
    switch (value) {
      case 'run':
        return CommandType.run;
      case 'build':
        return CommandType.build;
      default:
        throw ArgumentError('Invalid command type: $value');
    }
  }

  void execute(final Config config) {
    switch (this) {
      case CommandType.run:
        return CommandRun(config).execute();
      case CommandType.build:
        return CommandBuild(config).execute();
    }
  }
}

abstract class Command extends runner.Command<void> {
  bool get debug => globalResults?['debug'] as bool? ?? false;

  File get inputFile {
    // kebab run input.keb (position)
    if (argResults?.rest.isNotEmpty ?? false) {
      return File(argResults!.rest.first);
    }

    // kebab run -i input.keb (named)
    final path = argResults?['input'] as String?;

    if (path == null) throw ArgumentError('Input file is required');
    return File(path);
  }

  File get outputFile {
    // kebab run input.keb output.file (position)
    if ((argResults?.rest.length ?? 0) > 1) {
      return File(argResults!.rest[1]);
    }

    // kebab run -i input.keb -o output.file (named)
    final path = argResults?['output'] as String?;

    return File(path ?? inputFile.path.split('.').first);
  }
}

class RunCommand extends Command {
  @override
  final String name = 'run';
  @override
  final String description = 'Run the application';

  RunCommand() {
    argParser
      ..addOption('input', abbr: 'i', help: 'Input file path')
      ..addOption('output', abbr: 'o', help: 'Output file path');
  }

  @override
  void run() {
    final config = Config(CommandType.run, debug, inputFile, outputFile);
    config.executeCommand();
  }
}

class BuildCommand extends Command {
  @override
  final String name = 'build';
  @override
  final String description = 'Build the project';

  BuildCommand() {
    argParser
      ..addOption('input', abbr: 'i', help: 'Input file path')
      ..addOption('output', abbr: 'o', help: 'Output file path')
      ..addFlag(
        'release',
        abbr: 'r',
        help: 'Build in release mode',
      );
  }

  @override
  void run() {
    final config = Config(CommandType.build, debug, inputFile, outputFile);
    config.executeCommand();
  }
}
