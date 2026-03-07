enum TokenType { id, key, num, op, lParen, rParen, comma, colon, assign }

class Token {
  TokenType type;
  String value;
  Token(this.type, this.value);

  @override
  String toString() => "$type: $value";
}
