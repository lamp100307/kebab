import 'package:args/command_runner.dart' as runner;

import '../build_config.dart';
import '../config.dart';
import '../services/services.dart';

export 'runner.dart';

enum CommandType { run, build }

abstract class Command extends runner.Command<void> {
  final CommandType command;
  Config? _configCache;
  BaseService get service;

  Command(this.command) {
    argParser
      ..addOption('input', abbr: 'i', help: 'Input file path')
      ..addOption('output', abbr: 'o', help: 'Output file path')
      ..addFlag('release', abbr: 'r', help: 'Build in release mode');
  }

  Config get config => _configCache ??= Config(command, debug: debug);

  bool get debug => globalResults?['debug'] as bool? ?? false;

  @override
  void run() => service.execute(BuildConfig.init(argResults, config));
}
