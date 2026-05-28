import 'dart:io' show File;

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

import 'package:kebab/config.dart';
import 'package:kebab/project.dart';

export 'runner.dart';

enum CommandType { run, build }

abstract class KebabCommand extends Command<void> {
  final CommandType command;
  static Config? _configCache;

  KebabCommand(this.command);

  Config get config => _configCache ??= Config(
    command,
    inputFile,
    outputFile,
    project: KebabProject.fromToml(),
    debug: debug,
  );

  bool get debug => globalResults?['debug'] as bool? ?? false;

  File? get inputFile {
    final path = argResults?.rest.isNotEmpty ?? false
        ? argResults!.rest[0] // kebab run input.keb (position)
        : argResults?['input']; // kebab run -i input.keb (named)

    if (path == null) return null;
    // Checking the existence of file further in Config._resolveInputFile
    return File(path).absolute;
  }

  /// Resolves the output file path
  ///
  /// Returns:
  ///
  /// The output file path is resolved from the input file path and the output path argument
  File? get outputFile {
    String stripExt(final String path) =>
        p.join(p.dirname(path), p.basenameWithoutExtension(path));

    final input = inputFile;

    // Because if there is no input file, there will be no output file
    if (input == null) return null;

    final rawPath = (argResults?.rest.length ?? 0) > 1
        ? argResults!.rest[1]
        : argResults?['output'];

    // If no output path is provided, use the input file's directory and basename
    if (rawPath == null) return File(stripExt(input.path));

    final isDir =
        rawPath.endsWith(p.separator) || rawPath == '.' || rawPath == '..';

    // Else if the output path is a directory, use the input file's basename; otherwise, use the raw path
    if (isDir) return File(stripExt(p.join(rawPath, input.path)));

    // Else the output path is not a directory, use the raw path as-is
    return File(stripExt(p.join(rawPath)));
  }
}
