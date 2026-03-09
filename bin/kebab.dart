import 'dart:io' show exit;

import 'package:kebab/commands/commands.dart';

void main(final List<String> args) async {
  final runner = CommandRunner();
  try {
    await runner.run(args);
  } catch (e) {
    print(e);
    exit(1);
  }
}
