import 'package:kebab/config.dart';

import 'build.dart';
import 'run.dart';

abstract interface class Command {
  final Config config;

  const Command(this.config);

  void execute();
}

enum CommandType {
  run,
  build;

  static CommandType fromString(String value) {
    switch (value) {
      case 'run':
        return CommandType.run;
      case 'build':
        return CommandType.build;
      default:
        throw ArgumentError('Invalid command type: $value');
    }
  }

  void execute(Config config) {
    switch (this) {
      case CommandType.run:
        return CommandRun(config).execute();
      case CommandType.build:
        return CommandBuild(config).execute();
    }
  }
}
