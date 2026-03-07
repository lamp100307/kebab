import 'package:kebab/token.dart';

class Lexer {
  static const keywords = ['let'];
  static List<Token> tokenize(String input) {
    int pos = 0;
    final List<Token> tokens = [];
    while (pos < input.length) {
      final String c = input[pos];
      switch (c) {
        case '0':
        case '1':
        case '2':
        case '3':
        case '4':
        case '5':
        case '6':
        case '7':
        case '8':
        case '9':
          String num = '';
          while (pos < input.length && input[pos].codeUnitAt(0) ^ 48 <= 9) {
            num += input[pos];
            pos += 1;
          }
          tokens.add(Token(TokenType.num, num));
          break;
        case '+':
        case '-':
        case '*':
          tokens.add(Token(TokenType.op, c));
          pos += 1;
          break;
        case '/':
          if (input[pos++] == '/') {
            while (pos < input.length && input[pos] != '\n') {
              pos += 1;
            }
          } else {
            tokens.add(Token(TokenType.op, c));
          }

        case '\n':
        case '\r':
        case '\t':
        case ' ':
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
        case ',':
          tokens.add(Token(TokenType.comma, c));
          pos += 1;
          break;
        case ':':
          tokens.add(Token(TokenType.colon, c));
          pos += 1;
          break;
        case '=':
          tokens.add(Token(TokenType.assign, c));
          pos += 1;
          break;
        default:
          bool isAlphaNumeric(String c) =>
              c.codeUnitAt(0) >= 'a'.codeUnitAt(0) &&
                  c.codeUnitAt(0) <= 'z'.codeUnitAt(0) ||
              c.codeUnitAt(0) >= 'A'.codeUnitAt(0) &&
                  c.codeUnitAt(0) <= 'Z'.codeUnitAt(0) ||
              c.codeUnitAt(0) >= '0'.codeUnitAt(0) &&
                  c.codeUnitAt(0) <= '9'.codeUnitAt(0);

          bool isLetter(String c) {
            final int code = c.codeUnitAt(0);
            return (code >= 65 && code <= 90) ||    
                  (code >= 97 && code <= 122);   
          }

          if (isLetter(c)) {
            String id = '';
            while (pos < input.length && isAlphaNumeric(input[pos])) {
              id += input[pos];
              pos += 1;
            }
            if (keywords.contains(id)) {
              tokens.add(Token(TokenType.key, id));
              break;
            }
            tokens.add(Token(TokenType.id, id));
          } else {
            //! For lynx20wz. After you make new error system, place here normal exception.
            throw Exception('Unknown character: $c');
          }
      }
    }

    return tokens;
  }
}
