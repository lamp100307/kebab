import 'package:kebab/exceptions/exceptions.dart'
    show LexerUnexpectedCharacterException;

import 'token.dart';

class Lexer {
  static const keywords = [
    'let',
    'if',
    'else',
    'for',
    'break',
    'continue',
    'while',
    'loop',
  ];

  final String input;

  const Lexer(this.input);

  List<Token> tokenize() {
    int pos = 0;
    final List<Token> tokens = [];
    while (pos < input.length) {
      final String c = input[pos];
      switch (c) {
        case '0' || '1' || '2' || '3' || '4' || '5' || '6' || '7' || '8' || '9':
          String num = '';
          while (pos < input.length && input[pos].codeUnitAt(0) ^ 48 <= 9) {
            num += input[pos];
            pos += 1;
          }
          tokens.add(Token(TokenType.num, num));
          break;
        case '+' || '-' || '*' || '<' || '>' || '!' || '&' || '|' || '%':
          if (c == '<' && pos + 1 < input.length && input[pos + 1] == '=') {
            tokens.add(Token(TokenType.op, '<='));
            pos += 2;
          } else if (c == '>' &&
              pos + 1 < input.length &&
              input[pos + 1] == '=') {
            tokens.add(Token(TokenType.op, '>='));
            pos += 2;
          } else if (c == '=' &&
              pos + 1 < input.length &&
              input[pos + 1] == '=') {
            tokens.add(Token(TokenType.op, '=='));
            pos += 2;
          } else if (c == '!' &&
              pos + 1 < input.length &&
              input[pos + 1] == '=') {
            tokens.add(Token(TokenType.op, '!='));
            pos += 2;
          } else if (c == '&' &&
              pos + 1 < input.length &&
              input[pos + 1] == '&') {
            tokens.add(Token(TokenType.op, '&&'));
            pos += 2;
          } else if (c == '|' &&
              pos + 1 < input.length &&
              input[pos + 1] == '|') {
            tokens.add(Token(TokenType.op, '||'));
            pos += 2;
          } else {
            tokens.add(Token(TokenType.op, c));
            pos += 1;
          }
          break;
        case '/':
          if (pos + 1 < input.length && input[pos + 1] == '/') {
            pos += 2;
            while (pos < input.length && input[pos] != '\n') {
              pos += 1;
            }
          } else {
            tokens.add(Token(TokenType.op, c));
            pos += 1;
          }
          break;
        case '\n' || '\r' || '\t' || ' ':
          pos += 1;
          break;
        case '(':
          tokens.add(Token(TokenType.lParen, c));
          pos += 1;
          break;
        case ')':
          tokens.add(Token(TokenType.rParen, c));
          pos += 1;
          break;
        case '{':
          tokens.add(Token(TokenType.lBrace, c));
          pos += 1;
          break;
        case '}':
          tokens.add(Token(TokenType.rBrace, c));
          pos += 1;
          break;
        case ',':
          tokens.add(Token(TokenType.comma, c));
          pos += 1;
          break;
        case ':':
          tokens.add(Token(TokenType.colon, c));
          pos += 1;
          break;
        case ';':
          tokens.add(Token(TokenType.semicolon, c));
          pos += 1;
          break;
        case '=':
          if (pos + 1 < input.length && input[pos + 1] == '=') {
            tokens.add(Token(TokenType.op, '=='));
            pos += 2;
          } else {
            tokens.add(Token(TokenType.assign, c));
            pos += 1;
          }
          break;
        case '"':
          String str = '';
          pos += 1;
          while (pos < input.length && input[pos] != '"') {
            str += input[pos];
            pos += 1;
          }
          pos += 1;
          tokens.add(Token(TokenType.str, str));
          break;
        default:
          if (_isLetter(c)) {
            String id = '';
            while (pos < input.length && _isAlphaNumeric(input[pos])) {
              id += input[pos];
              pos += 1;
            }
            if (keywords.contains(id)) {
              tokens.add(Token(TokenType.key, id));
              break;
            }
            tokens.add(Token(TokenType.id, id));
          } else {
            throw LexerUnexpectedCharacterException(c);
          }
      }
    }

    return tokens;
  }

  bool _isAlphaNumeric(final String c) =>
      c.codeUnitAt(0) >= 'a'.codeUnitAt(0) &&
          c.codeUnitAt(0) <= 'z'.codeUnitAt(0) ||
      c.codeUnitAt(0) >= 'A'.codeUnitAt(0) &&
          c.codeUnitAt(0) <= 'Z'.codeUnitAt(0) ||
      c.codeUnitAt(0) >= '0'.codeUnitAt(0) &&
          c.codeUnitAt(0) <= '9'.codeUnitAt(0);

  bool _isLetter(final String c) {
    final int code = c.codeUnitAt(0);
    return (code >= 65 && code <= 90) || (code >= 97 && code <= 122);
  }
}
