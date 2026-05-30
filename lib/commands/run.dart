import '../build_config.dart';
import '../services/services.dart';
import 'commands.dart';

final class CommandRun extends Command {
  @override
  final String name = 'run';
  @override
  final String description = 'Run the application';
  @override
  BaseService get service => RunService(config);

  CommandRun() : super(CommandType.run);

  @override
  void run() => service.execute(BuildConfig.init(argResults, config));
}
