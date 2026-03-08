import 'dart:io' show File;

import 'package:kebab/commands/commands.dart';

// TODO: rewrite with ArgParser
final class Config {
  final CommandType command;
  final bool debug;
  final File inputFile;
  final File outputFile;

  Config(this.command, this.debug, this.inputFile, this.outputFile);

  Config.fromArgs(List<String> args)
    : assert(args.isNotEmpty),
      command = CommandType.fromString(args.first),
      debug = args.contains('--debug'),
      inputFile = File(args[1]),
      outputFile = File(args[2]);

  void executeCommand() => command.execute(this);
}
