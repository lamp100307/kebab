part of 'exceptions.dart';

sealed class LexerException implements KebabException {
  @override
  final CodeLocation? location;

  const LexerException([this.location]);
}

final class LexerUnexpectedCharacterException extends LexerException {
  final String char;

  @override
  String get message => 'Unexpected character: $char';

  const LexerUnexpectedCharacterException(this.char, [super.location]);
}
