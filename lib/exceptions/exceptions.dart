import 'package:kebab/core/core.dart';

part 'lexer_exceptions.dart';
part 'semantic_exceptions.dart';
part 'parser_exceptions.dart';

class CodeLocation {
  final int line;
  final int column;
  final String? lineContent;
  final String? fileName;

  const CodeLocation({
    required this.line,
    required this.column,
    this.lineContent,
    this.fileName,
  });

  @override
  String toString() {
    var location = '${fileName ?? 'unknown'}:$line:$column';
    if (lineContent != null) {
      location += '\n$lineContent';
      location += '\n${' ' * (column - 1)}^';
    }
    return location;
  }
}

class KebabException implements Exception {
  final CodeLocation? location;

  String get message =>
      "Exception occurred ${location != null ? 'at $location' : ''}";

  const KebabException([this.location]);
}
