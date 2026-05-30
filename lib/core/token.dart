enum TokenType {
  int,
  string,
  id,
  keyword,
  op,
  lparen,
  rparen,
  lbrace,
  rbrace,
  comma,
  colon,
  semicolon,
  assign,
  doubleArrow,
}

base class Token {
  TokenType type;
  String value;
  Token(this.type, this.value);

  @override
  String toString() => "$type: $value";
}
