enum TokenType {
  int,
  string,
  id,
  op,
  lparen,
  rparen,
  comma,
  colon,
  semicolon,
  assign,
}

base class Token {
  TokenType type;
  String value;
  Token(this.type, this.value);

  @override
  String toString() => "$type: $value";
}
