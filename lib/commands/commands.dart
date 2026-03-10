import 'dart:io' show File;

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

import 'package:kebab/config.dart';
import 'package:kebab/project.dart';
import 'command_type.dart';

export 'runner.dart';
export 'command_type.dart';

abstract interface class ICommand {
  final Config config;

  const ICommand(this.config);

  void execute();
}

abstract class KebabCommand extends Command<void> {
  bool get debug => globalResults?['debug'] as bool? ?? false;

  File? get inputFile {
    final path = argResults?.rest.isNotEmpty ?? false
        ? argResults!.rest[0] // kebab run input.keb (position)
        : argResults?['input']; // kebab run -i input.keb (named)

    if (path == null) return null;
    return File(path).absolute;
  }

  File? get outputFile {
    String? path = (argResults?.rest.length ?? 0) > 1
        ? argResults!.rest[1] // kebab run input.keb output.file (position)
        : argResults?['output']; // kebab run -i input.keb -o output.file (named)

    // dir: output/ => file: output/input
    final inputFileName = p.basenameWithoutExtension(inputFile?.path ?? '');

    if (path != null && path.endsWith('/')) {
      // is directory
      path += inputFileName;
    } else {
      path ??= inputFileName;
    }

    return File(path).absolute;
  }

  Config _initConfig(final CommandType command) => Config(
    command,
    inputFile,
    outputFile,
    project: KebabProject.fromToml(),
    debug: debug,
  );
}

class BuildCommand extends KebabCommand {
  @override
  final String name = 'build';
  @override
  final String description = 'Build the project';

  BuildCommand() {
    argParser
      ..addOption('input', abbr: 'i', help: 'Input file path')
      ..addOption('output', abbr: 'o', help: 'Output file path')
      ..addFlag('release', abbr: 'r', help: 'Build in release mode');
  }

  @override
  void run() {
    final config = _initConfig(CommandType.build);
    config.executeCommand();
  }
}

class RunCommand extends KebabCommand {
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
    final config = _initConfig(CommandType.run);
    config.executeCommand();
  }
}
