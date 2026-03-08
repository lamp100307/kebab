import 'dart:io' show File;

import 'package:kebab/commands/commands.dart';

final class Config {
  final CommandType command;
  final bool debug;
  final File inputFile;
  final File outputFile;

  Config(this.command, this.debug, this.inputFile, this.outputFile);

  void executeCommand() => command.execute(this);
}
