import 'dart:io' show File;

import 'package:args/args.dart' show ArgResults;
import 'package:kebab/config.dart';
import 'package:kebab/exceptions/exceptions.dart';
import 'package:path/path.dart' as p;

enum BuildProfile { release, debug }

final class BuildConfig {
  final File target;
  final File output;
  final BuildProfile mode;

  BuildConfig(this.target, this.output, {this.mode = BuildProfile.debug});

  factory BuildConfig.init(final ArgResults? argResults, final Config config) {
    if (config.debug) print("BuildConfig.init: argResults=$argResults");
    final input = _resolveInputFile(argResults, config);
    final output = _resolveOutputFile(argResults, config, input);
    if (config.debug) print("BuildConfig.init: target=$input, output=$output");
    return BuildConfig(input, output);
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
