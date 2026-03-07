enum TokenType { id, num, op, lParen, rParen, comma }

class Token {
  TokenType type;
  String value;
  Token(this.type, this.value);

  @override
  String toString() => "$type: $value";
}
