enum TokenType { id, key, num, str, op, lParen, rParen, lBrace, rBrace, comma, colon, semicolon, assign }

base class Token {
  TokenType type;
  String value;
  Token(this.type, this.value);

  @override
  String toString() => "$type: $value";
}
