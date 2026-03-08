import 'dart:io' show exit;

import 'package:args/command_runner.dart' show UsageException;
import 'package:kebab/commands/commands.dart';

void main(List<String> args) async {
  final runner = CommandRunner();
  try {
    await runner.run(args);
  } on UsageException catch (e, _) {
    print(e);
    exit(1);
  }
}
