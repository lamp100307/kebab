import 'package:kebab/exceptions/exceptions.dart';

import 'ast_node.dart';
import 'token.dart';

class Parser {
  List<ASTNode> nodes = [];
  List<Token> tokens;
  int pos = 0;

  static const Map<String, int> opPrecedence = {"+": 1, "-": 1, "*": 2, "/": 2};

  Parser(this.tokens);

  Token? _peek() => pos < tokens.length ? tokens[pos] : null;

  Token _consume(final TokenType type) {
    final token = _peek();
    if (token != null && token.type == type) {
      pos++;
      return token;
    }
    throw ParserUnexpectedTokenException(type, token!.value, token.type);
  }

  Token _consumeWithValue(final TokenType type, final String value) {
    final token = _peek();
    if (token != null && token.type == type && token.value == value) {
      pos++;
      return token;
    }
    throw ParserUnexpectedTokenException(type, token!.value, token.type);
  }

  bool _expect(final TokenType type) {
    final token = _peek();
    return token != null && token.type == type;
  }

  bool _expectWithValue(final TokenType type, final String value) {
    final token = _peek();
    return token != null && token.type == type && token.value == value;
  }

  List<ASTNode> parse() {
    while (pos < tokens.length) {
      nodes.add(_parseExpr(0));
    }
    return nodes;
  }

  ASTNode _parseExpr(final int minPrec) {
    var left = _parseAtom();
    while (pos < tokens.length) {
      final Token op = _peek()!;
      final int prec = opPrecedence[op.value] ?? 0;
      if (prec == 0 || prec < minPrec) break;
      pos++;
      final right = _parseExpr(prec + 1);
      left = OpNode(left, op.value, right);
    }
    return left;
  }

  ASTNode _parseAtom() {
    final Token token = _peek()!;
    switch (token.type) {
      case TokenType.num:
        pos++;
        return IntNode(int.parse(token.value));
      case TokenType.str:
        pos++;
        return StrNode(token.value);
      case TokenType.id:
        pos++;
        if (_expectWithValue(TokenType.lParen, '(')) {
          pos++;
          if (!_expectWithValue(TokenType.rParen, ')')) {
            final List<ASTNode> args = [];
            while (!_expectWithValue(TokenType.rParen, ')')) {
              if (_expectWithValue(TokenType.comma, ',')) {
                _consume(TokenType.comma);
              }
              args.add(_parseExpr(0));
            }
            pos++;
            return FuncCallNode(token.value, args);
          } else {
            pos++;
            return FuncCallNode(token.value, []);
          }
        } else {
          if (_expectWithValue(TokenType.assign, '=')) {
            pos++;
            return VarAssignNode(token.value, _parseExpr(0));
          }
          return VarRefNode(token.value);
        }
      case TokenType.lParen:
        pos++;
        final expr = _parseExpr(0);
        _consumeWithValue(TokenType.rParen, ')');
        return expr;
      case TokenType.key:
        switch (token.value) {
          case "let":
            pos++;
            final name = _consume(TokenType.id).value;
            KebabType? type;
            if (_expect(TokenType.colon)) {
              pos++;
              type = _parseKebabType(_consume(TokenType.id).value);
            }
            ASTNode? value;
            if (_expectWithValue(TokenType.assign, '=')) {
              pos++;
              value = _parseExpr(0);
            }
            return VarDeclNode(name, type, value);
          default:
            throw ParserUnknownKeywordException(token.value);
        }
      default:
        throw ParserUnexpectedTokenException(token.type, token.value);
    }
  }

  KebabType _parseKebabType(final String rawType) {
    switch (rawType) {
      case "i8":
        return I8();
      case "i16":
        return I16();
      case "i32":
        return I32();
      case "i64":
        return I64();
      case "u8":
        return U8();
      case "u16":
        return U16();
      case "u32":
        return U32();
      case "u64":
        return U64();
      case "f32":
        return F32();
      case "f64":
        return F64();
      case "char":
        return Char();
      case "str":
        return Str();
      case "bool":
        return Bool();
      default:
        throw ParserUnknownTypeException(rawType);
    }
  }
}
