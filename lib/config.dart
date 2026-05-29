import 'commands/commands.dart' show CommandType;

final class Config {
  final CommandType command;
  final bool debug;

  Config(this.command, {this.debug = false});
}
