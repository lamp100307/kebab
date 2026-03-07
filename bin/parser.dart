import 'package:kebab/token.dart';
import 'package:kebab/ast_node.dart';

class Parser {
  List<ASTNode> nodes = [];
  List<Token> tokens;
  int pos = 0;

  static const Map<String, int> opPrecedence = {"+": 1, "-": 1, "*": 2, "/": 2};

  Parser(this.tokens);

  Token? peek() => pos < tokens.length ? tokens[pos] : null;

  Token consume(TokenType type) {
    final token = peek();
    if (token != null && token.type == type) {
      pos++;
      return token;
    }
    throw Exception("Expected $type but got ${token?.type} at $pos");
  }

  Token consumeWithValue(TokenType type, String value) {
    final token = peek();
    if (token != null && token.type == type && token.value == value) {
      pos++;
      return token;
    }
    throw Exception("Expected $type($value) but got ${token?.type}(${token?.value}) at $pos");
  }

  bool expect(TokenType type) {
    final token = peek();
    return token != null && token.type == type;
  }

  bool expectWithValue(TokenType type, String value) {
    final token = peek();
    return token != null && token.type == type && token.value == value;
  }

  List<ASTNode> parse() {
    while (pos < tokens.length) {
      nodes.add(parseExpr(0));
    }
    return nodes;
  }

  ASTNode parseExpr(int minPrec) {
    var left = parseAtom();
    while (pos < tokens.length) {
      final Token op = peek()!;
      final int prec = opPrecedence[op.value] ?? 0;
      if (prec == 0 || prec < minPrec) break;
      pos++;
      final right = parseExpr(prec + 1);
      left = OpNode(left, op.value, right);
    }
    return left;
  }

  ASTNode parseAtom() {
    final Token token = peek()!;
    switch (token.type) {
      case TokenType.num:
        pos++;
        return IntNode(int.parse(token.value));
      case TokenType.id:
        pos++;
        if (expectWithValue(TokenType.lParen, '(')) {
          pos++;
          if (!expectWithValue(TokenType.rParen, ')')) {
            final List<ASTNode> args = [];
            while (!expectWithValue(TokenType.rParen, ')')) {
              if (expectWithValue(TokenType.comma, ',')) consume(TokenType.comma);
              args.add(parseExpr(0));
            }
            pos++;
            return FuncCallNode(token.value, args);
          } else {
            pos++;
            return FuncCallNode(token.value, []);
          }
        } else {
          if (expectWithValue(TokenType.assign, '=')) {
            pos++;
            return VarAssignNode(token.value, parseExpr(0));
          }
          return VarRefNode(token.value);
        }
      case TokenType.lParen:
        pos++;
        final expr = parseExpr(0);
        consumeWithValue(TokenType.rParen, ')');
        return expr;
      case TokenType.key:
        switch (token.value) {
          case "let":
            pos++;
            final name = consume(TokenType.id).value;
            KebabType? type;
            if (expect(TokenType.colon)) {
              pos++;
              type = parseKebabType(consume(TokenType.id).value);
            }
            ASTNode? value;
            if (expectWithValue(TokenType.assign, '=')) {
              pos++;
              value = parseExpr(0);
            }
            return VarDeclNode(name, type, value);
          default:
            throw UnsupportedError("Unsupported keyword ${token.value}");
        }
      default:
        throw Exception("Unexpected token ${token.type} at $pos");
    }
  }

  KebabType parseKebabType(String rawType) {
    switch (rawType) {
      case "i8": return KebabType.i8;
      case "i16": return KebabType.i16;
      case "i32": return KebabType.i32;
      case "i64": return KebabType.i64;
      case "u1": return KebabType.u1;
      case "u8": return KebabType.u8;
      case "u16": return KebabType.u16;
      case "u32": return KebabType.u32;
      case "u64": return KebabType.u64;
      case "f32": return KebabType.f32;
      case "f64": return KebabType.f64;
      case "char": return KebabType.char;
      case "str": return KebabType.str;
      default: throw Exception("Unknown kebab type");
    }
  }
}
