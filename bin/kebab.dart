import 'dart:io' show exit;

import 'package:args/command_runner.dart' show UsageException;

import 'package:kebab/commands/commands.dart' show CommandRunner;
import 'package:kebab/exceptions/exceptions.dart' show KebabException;

void main(final List<String> args) async {
  final runner = CommandRunner();
  try {
    await runner.run(args);
  } on KebabException catch (e) {
    print("KebabException: ${e.message}");
    exit(1);
  } on UsageException catch (e) {
    print("UsageException: ${e.message}");
    exit(2);
  }
}
