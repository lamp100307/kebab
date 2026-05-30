import '../build_config.dart';
import '../services/services.dart';
import 'commands.dart';

final class CommandBuild extends Command {
  @override
  final String name = 'build';
  @override
  final String description = 'Build the project';
  @override
  BaseService get service => BuildService(config);

  CommandBuild() : super(CommandType.build);
  @override
  void run() => service.execute(BuildConfig.init(argResults, config));
}
