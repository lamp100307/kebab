import 'token.dart';

class Lexer {
  int pos = 0;
  final String code;
  Lexer(this.code);

  List<Token> tokenize() {
    final tokens = <Token>[];
    while (pos < code.length) {
      final token = _getToken();
      if (token != null) {
        tokens.add(token);
      }
    }
    return tokens;
  }

  Token? _getToken() {
    _skipWhitespace();

    if (pos >= code.length) return null;

    final char = code[pos];

    if (char == '"') {
      return _readString();
    }
    if (_isLetter(char)) {
      return _readIdentifierOrKeyword();
    }
    if (_isDigit(char)) {
      return _readNumber();
    }

    // Operatiors and punctuation
    switch (char) {
      case '+':
      case '-':
      case '*':
      case '/':
      case '%':
      case '>':
      case '<':
      case '!':
        return _readOperator();

      case '=':
        pos++;
        if (pos < code.length && code[pos] == '=') {
          pos++;
          return Token(TokenType.op, '==');
        }
        return Token(TokenType.assign, '=');

      case '(':
        pos++;
        return Token(TokenType.lparen, '(');

      case ')':
        pos++;
        return Token(TokenType.rparen, ')');

      case '{':
        pos++;
        return Token(TokenType.lbrace, '{');

      case '}':
        pos++;
        return Token(TokenType.rbrace, '}');

      case ',':
        pos++;
        return Token(TokenType.comma, ',');

      case ':':
        pos++;
        return Token(TokenType.colon, ':');

      case ';':
        pos++;
        return Token(TokenType.semicolon, ';');

      default:
        throw Exception('Unexpected character: $char at position $pos');
    }
  }

  void _skipWhitespace() {
    while (pos < code.length && _isWhitespace(code[pos])) {
      pos++;
    }
  }

  Token _readString() {
    final quote = code[pos];
    pos++; // skip quote

    final start = pos;
    final buffer = StringBuffer();
    bool escaped = false;

    while (pos < code.length) {
      final char = code[pos];

      if (escaped) {
        // Process escaped characters
        switch (char) {
          case 'n':
            buffer.write('\n');
            break;
          case 't':
            buffer.write('\t');
            break;
          case 'r':
            buffer.write('\r');
            break;
          case '\\':
            buffer.write('\\');
            break;
          case '"':
            buffer.write('"');
            break;
          default:
            buffer.write('\\$char');
        }
        escaped = false;
        pos++;
        continue;
      }

      if (char == '\\') {
        escaped = true;
        pos++;
        continue;
      }

      if (char == quote) {
        pos++; // Skip closing quote
        return Token(TokenType.string, buffer.toString());
      }

      buffer.write(char);
      pos++;
    }

    throw Exception('Unterminated string literal starting at position $start');
  }

  Token _readIdentifierOrKeyword() {
    final start = pos;
    while (pos < code.length &&
        (_isLetterOrDigit(code[pos]) || code[pos] == '_')) {
      pos++;
    }
    final value = code.substring(start, pos);

    if (value == 'if' || value == 'else') {
      return Token(TokenType.keyword, value);
    }

    return Token(TokenType.id, value);
  }

  Token _readNumber() {
    final start = pos;
    while (pos < code.length && _isDigit(code[pos])) {
      pos++;
    }

    final value = code.substring(start, pos);
    return Token(TokenType.int, value);
  }

  Token _readOperator() {
    final char = code[pos];
    pos++;

    // Two character operators
    if (pos < code.length) {
      final nextChar = code[pos];
      if ((char == '>' && nextChar == '=') ||
          (char == '<' && nextChar == '=') ||
          (char == '!' && nextChar == '=') ||
          (char == '=' && nextChar == '=') ||
          (char == '+' && nextChar == '+') ||
          (char == '-' && nextChar == '-')) {
        pos++;
        return Token(TokenType.op, char + nextChar);
      }
    }

    return Token(TokenType.op, char);
  }

  bool _isLetter(final String char) {
    final codeUnit = char.codeUnitAt(0);
    return (codeUnit >= 65 && codeUnit <= 90) || // A-Z
        (codeUnit >= 97 && codeUnit <= 122); // a-z
  }

  bool _isDigit(final String char) {
    final codeUnit = char.codeUnitAt(0);
    return codeUnit >= 48 && codeUnit <= 57; // 0-9
  }

  bool _isLetterOrDigit(final String char) => _isLetter(char) || _isDigit(char);

  bool _isWhitespace(final String char) =>
      char == ' ' || char == '\t' || char == '\n' || char == '\r';
}
