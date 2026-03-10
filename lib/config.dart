import 'dart:io' show File;
import 'package:kebab/exceptions/exceptions.dart';
import 'package:path/path.dart' as p;

import 'package:kebab/commands/commands.dart' show CommandType;
import 'package:kebab/project.dart';

final class Config {
  final CommandType command;
  final bool debug;
  final File inputFile;
  late final File outputFile;
  final KebabProject? project;

  Config._(
    this.command,
    this.inputFile,
    this.outputFile, {
    this.project,
    required this.debug,
  });

  factory Config(
    final CommandType command,
    final File? inputFile,
    final File? outputFile, {
    final KebabProject? project,
    final bool? debug,
  }) {
    final resolvedDebug = debug ?? project?.debug ?? false;

    final resolvedInput = _resolveInputFile(
      project: project,
      providedFile: inputFile,
    );

    final resolvedOutput = _resolveOutputFile(
      project: project,
      providedFile: outputFile,
      inputFile: resolvedInput,
    );

    return Config._(
      command,
      resolvedInput,
      resolvedOutput,
      project: project,
      debug: resolvedDebug,
    );
  }

  static File _resolveInputFile({
    required final KebabProject? project,
    required final File? providedFile,
  }) {
    if (providedFile != null) {
      if (providedFile.existsSync()) return providedFile;
      throw FileInputNotProvidedExceprion();
    }

    if (project != null) {
      final defaultFile = File(
        '${project.rootDir.path}/${project.projectName}.keb',
      );
      if (defaultFile.existsSync()) return defaultFile;
      throw FileInputNotProvidedExceprion();
    }

    throw FileInputNotProvidedExceprion();
  }

  static File _resolveOutputFile({
    required final KebabProject? project,
    required final File? providedFile,
    required final File inputFile,
  }) {
    if (providedFile != null) return providedFile;
    return File(p.withoutExtension(inputFile.path));
  }

  void executeCommand() => command.execute(this);
}
