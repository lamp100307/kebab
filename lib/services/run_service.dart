import 'dart:io' show Process;

import '../build_config.dart';
import '../config.dart';
import 'services.dart';

final class RunService implements BaseService {
  @override
  final Config config;

  const RunService(this.config);

  @override
  void execute(final BuildConfig buildConfig) {
    BuildService(config).execute(buildConfig);
    final runResult = Process.runSync(buildConfig.output.path, []);

    if (runResult.exitCode == 0) {
      print(runResult.stdout);
    } else {
      print('Execution failed:\n${runResult.stderr}');
    }
  }
}
