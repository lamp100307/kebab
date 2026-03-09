part of 'exceptions.dart';

sealed class ParserException implements KebabException {
  @override
  final CodeLocation? location;

  const ParserException([this.location]);
}

final class ParserUnexpectedTokenException extends ParserException {
  final TokenType actualType;
  final TokenType? expectedType;
  final String? value;

  @override
  String get message =>
      "Unexpected token: $actualType$_getValueString $_getExpectedString";

  String get _getValueString => value != null ? '($value)' : '';
  String get _getExpectedString =>
      expectedType != null ? '(expected $expectedType$_getValueString)' : '';

  const ParserUnexpectedTokenException(
    this.actualType, [
    this.value,
    this.expectedType,
    super.location,
  ]);
}

sealed class ParserUnknownException extends ParserException {
  final String value;

  @override
  String get message => "Unknown object: $value";

  const ParserUnknownException(this.value, [super.location]);
}

final class ParserUnknownKeywordException extends ParserUnknownException {
  @override
  String get message => "Unknown keyword: $value";

  const ParserUnknownKeywordException(super.value, [super.location]);
}

final class ParserUnknownTypeException extends ParserUnknownException {
  @override
  String get message => "Unknown type: $value";

  const ParserUnknownTypeException(super.value, [super.location]);
}
