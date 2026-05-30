import 'dart:io' show File;

import 'package:args/args.dart' show ArgResults;
import 'package:path/path.dart' as p;

import 'config.dart';
import 'exceptions/exceptions.dart';

enum BuildProfile {
  release(2),
  debug(0);

  final int optimisationLevel;

  const BuildProfile(this.optimisationLevel);

  factory BuildProfile.fromString(final String str) => switch (str) {
    'release' => BuildProfile.release,
    'debug' => BuildProfile.debug,
    // TODO: make this a custom exception
    _ => throw UnimplementedError('Unknown build profile: $str'),
  };

  factory BuildProfile.fromBool(final bool? isRelease) =>
      isRelease ?? false ? BuildProfile.release : BuildProfile.debug;
}

final class BuildConfig {
  final File target;
  final File output;
  final BuildProfile mode;

  BuildConfig(this.target, this.output, {this.mode = BuildProfile.debug});

  factory BuildConfig.init(final ArgResults? argResults, final Config config) {
    if (config.debug) print("BuildConfig.init: argResults=$argResults");
    final input = _resolveInputFile(argResults, config);
    final output = _resolveOutputFile(argResults, config, input);
    final mode = BuildProfile.fromBool(argResults?['release']);
    if (config.debug) {
      print("BuildConfig.init: target=$input, output=$output, mode=$mode");
    }
    return BuildConfig(input, output, mode: mode);
  }

  static File _resolveInputFile(
    final ArgResults? argResults,
    final Config config,
  ) {
    final path = argResults?.rest.isNotEmpty ?? false
        ? argResults!.rest[0] // kebab run input.keb (position)
        : argResults?['input']; // kebab run -i input.keb (named)

    if (path == null) throw FileInputNotProvidedException();
    final providedFile = File(path).absolute;

    if (providedFile.existsSync()) return providedFile;
    throw FileInputNotExistsException(providedFile.path);
  }

  static File _resolveOutputFile(
    final ArgResults? argResults,
    final Config config,
    final File inputFile,
  ) {
    String stripExt(final String path) =>
        p.join(p.dirname(path), p.basenameWithoutExtension(path));

    final rawPath = (argResults?.rest.length ?? 0) > 1
        ? argResults!.rest[1]
        : argResults?['output'];

    // If no output path is provided, use the input file's directory and basename
    if (rawPath == null) return File(stripExt(inputFile.path));

    final isDir =
        rawPath.endsWith(p.separator) || rawPath == '.' || rawPath == '..';

    // Else if the output path is a directory, use the input file's basename; otherwise, use the raw path
    if (isDir) return File(stripExt(p.join(rawPath, inputFile.path)));

    // Else the output path is not a directory, use the raw path as-is
    return File(stripExt(p.join(rawPath)));
  }
}
