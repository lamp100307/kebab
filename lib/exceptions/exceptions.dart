import '../core/core.dart';
import 'code_location.dart';

part 'lexer_exceptions.dart';
part 'semantic_exceptions.dart';
part 'parser_exceptions.dart';
part 'file_exceptions.dart';

class KebabException implements Exception {
  final CodeLocation? location;

  @override
  String toString() => "$message\n$location";

  String get message =>
      "Exception occurred ${location != null ? 'at $location' : ''}";

  const KebabException([this.location]);
}

mixin PathMixin {
  String get path;
}

mixin OriginalExceptionMixin {
  Object? get originalException;
}
