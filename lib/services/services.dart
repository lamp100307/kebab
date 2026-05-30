import '../build_config.dart';
import '../config.dart';

export 'build_service.dart';
export 'run_service.dart';

abstract interface class BaseService {
  final Config config;

  BaseService(this.config);

  void execute(final BuildConfig buildConfig);
}
