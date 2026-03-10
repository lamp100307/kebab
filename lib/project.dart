import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:toml/toml.dart';

final class VersionString {
  final String major;
  final String minor;
  final String patch;

  @override
  String toString() => '$major.$minor.$patch';

  const VersionString(this.major, this.minor, this.patch);

  factory VersionString.fromString(final String value) {
    final parts = value.split('.');
    if (parts.length != 3) {
      throw FormatException('Version must have format x.y.z, got: $value');
    }

    return VersionString(parts[0], parts[1], parts[2]);
  }
}

final class KebabProject {
  final String projectName;
  final File configFile;
  final Directory rootDir;
  final VersionString? kebabVersion;
  final bool debug;

  const KebabProject({
    required this.projectName,
    required this.configFile,
    required this.rootDir,
    required this.kebabVersion,
    required this.debug,
  });

  static KebabProject? fromToml() {
    final File? configFile = _findConfigFile();

    if (configFile == null) {
      return null;
    }

    late final Map<String, dynamic>? toml;
    try {
      toml = TomlDocument.parse(configFile.readAsStringSync()).toMap();
    } catch (e) {
      return null;
    }

    final projectInToml = toml['project'] as Map<String, dynamic>?;

    final rootDir = configFile.parent;
    final projectName = projectInToml?['name'] ?? p.basename(rootDir.path);
    final debug = projectInToml?['debug'] as bool? ?? false;
    final kebabVersion = projectInToml?['kebab_version'] as VersionString?;

    if (kebabVersion == null && toml.isNotEmpty) {
      throw FormatException('kebab_version is required in oven.toml');
    }

    return KebabProject(
      projectName: projectName,
      configFile: configFile,
      rootDir: rootDir,
      kebabVersion: kebabVersion,
      debug: debug,
    );
  }

  static File? _findConfigFile() {
    var dir = Directory.current;

    while (true) {
      final file = File(p.join(dir.path, 'oven.toml'));
      if (file.existsSync()) return file;

      final parent = dir.parent;
      if (parent.path == dir.path) break;
      dir = parent;
    }

    return null;
  }
}
