import 'dart:io' show exit;

import 'package:kebab/commands/commands.dart';
import 'package:kebab/exceptions/exceptions.dart';

void main(final List<String> args) async {
  final runner = CommandRunner();
  try {
    await runner.run(args);
  } on KebabException catch (e) {
    print(e.message);
    exit(1);
  }
}
