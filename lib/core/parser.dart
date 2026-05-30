import 'ast_nodes.dart';
import 'token.dart';

class Parser {
  List<Token> tokens;
  int pos = 0;

  Map<String, int> opPrecedence = {
    '+': 1,
    '-': 1,
    '*': 2,
    '/': 2,
    '%': 2,
    '>': 3,
    '<': 3,
    '==': 4,
    '!=': 4,
    '>=': 4,
    '<=': 4,
  };

  Parser(this.tokens);

  ASTNode parse() {
    final List<ASTNode> result = [];
    while (_peek() != null) {
      result.add(_parseExpression());
    }
    return ProgramNode(result);
  }

  Token? _peek() {
    if (pos >= tokens.length) return null;
    return tokens[pos];
  }

  Token? _next() {
    if (pos >= tokens.length) return null;
    return tokens[pos++];
  }

  bool _check(final TokenType type) {
    if (pos >= tokens.length) return false;
    return tokens[pos].type == type;
  }

  Token _expect(final TokenType type) {
    final token = _next();
    if (token == null) {
      throw Exception('Unexpected end of input');
    } else if (token.type != type) {
      throw Exception('Unexpected token: $token, expected: $type');
    }
    return token;
  }

  ASTNode _parseExpression({final int minPrecedence = 0}) {
    ASTNode left = _parseAtom();

    while (_peek() != null) {
      final op = _peek();
      if (op != null &&
          op.type == TokenType.op &&
          opPrecedence[op.value] != null &&
          opPrecedence[op.value]! >= minPrecedence) {
        _next();
        final right = _parseExpression(
          minPrecedence: opPrecedence[op.value]! + 1,
        );
        left = BOPNode(left, op.value, right);
      } else {
        break;
      }
    }
    return left;
  }

  ASTNode _parseAtom() {
    switch (_peek()) {
      case null:
        throw Exception('Unexpected end of input');
      case Token(type: TokenType.int, value: final value):
        _next();
        return IntNode(int.parse(value));
      case Token(type: TokenType.string, value: final value):
        _next();
        return StringNode(value);
      case Token(type: TokenType.id, value: final value):
        _next();
        if (_check(TokenType.lparen)) {
          _next();
          final args = <ASTNode>[];
          if (!_check(TokenType.rparen)) {
            args.add(_parseExpression());
            while (_check(TokenType.comma)) {
              _next();
              args.add(_parseExpression());
            }
          }
          _expect(TokenType.rparen);
          return CallNode(value, args);
        }
        if (_check(TokenType.colon)) {
          _next();
          if (_check(TokenType.assign)) {
            _next();
            return VarDeclNode(value, null, _parseExpression());
          } else {
            final type = _parseType();
            _next();
            _expect(TokenType.assign);
            return VarDeclNode(value, type, _parseExpression());
          }
        }
        if (_check(TokenType.assign)) {
          _next();
          return VarAssignNode(value, _parseExpression());
        }
        return VarRefNode(value);
      case Token(type: TokenType.lparen):
        _next();
        final expr = _parseExpression();
        _expect(TokenType.rparen);
        return expr;
      case Token(type: TokenType.lbrace):
        _next();
        final List<ASTNode> stmts = [];
        while (!_check(TokenType.rbrace)) {
          stmts.add(_parseExpression());
        }
        _expect(TokenType.rbrace);
        return BlockNode(stmts);
      case Token(type: TokenType.keyword, value: final value):
        switch (value) {
          case 'if':
            _next();
            final condition = _parseExpression();
            print(_peek());
            if (!_check(TokenType.lbrace) && !_check(TokenType.doubleArrow)) {
              throw Exception('If body will be in {} or =>');
            }
            if (_check(TokenType.doubleArrow)) {
              _next();
            }
            final thenStmt = _parseExpression();
            ASTNode? elseStmt;
            if (_check(TokenType.keyword) && _peek()!.value == 'else') {
              _next();
              if (!_check(TokenType.lbrace) && !_check(TokenType.doubleArrow)) {
                throw Exception('Else body will be in {} or =>');
              }
              if (_check(TokenType.doubleArrow)) {
                _next();
              }
              elseStmt = _parseExpression();
            }
            return IfNode(condition, thenStmt, elseStmt);
          case 'for':
            _next();
            final init = _check(TokenType.semicolon)
                ? null
                : _parseExpression();
            _expect(TokenType.semicolon);
            final condition = _parseExpression();
            _expect(TokenType.semicolon);
            final update = _check(TokenType.lbrace) ? null : _parseExpression();
            if (!_check(TokenType.lbrace) && !_check(TokenType.doubleArrow)) {
              throw Exception('For body will be in {} or =>');
            }
            if (_check(TokenType.doubleArrow)) {
              _next();
            }
            final body = _parseExpression();
            return ForNode(init, condition, update, body);
          case 'while':
            _next();
            final cond = _parseExpression();
            if (!_check(TokenType.lbrace) && !_check(TokenType.doubleArrow)) {
              throw Exception('While body will be in {} or =>');
            }
            if (_check(TokenType.doubleArrow)) {
              _next();
            }
            final body = _parseExpression();
            return WhileNode(cond, body);
          case 'loop':
            _next();
            if (!_check(TokenType.lbrace) && !_check(TokenType.doubleArrow)) {
              throw Exception('Loop body will be in {} or =>');
            }
            if (_check(TokenType.doubleArrow)) {
              _next();
            }
            final body = _parseExpression();
            return LoopNode(body);
          case 'break':
            _next();
            return BreakNode();
          case 'continue':
            _next();
            return ContinueNode();
          case _:
            throw Exception('Unexpected keyword: ${_peek()}');
        }
      case _:
        throw Exception('Unexpected token: ${_peek()}');
    }
  }

  KebabType _parseType() {
    switch (_peek()) {
      case null:
        throw Exception('Unexpected end of input');
      case Token(type: TokenType.id, value: final value):
        switch (value) {
          case 'int':
            return KebabType.int;
          case 'String':
            return KebabType.string;
          case _:
            throw Exception('Unexpected type: ${_peek()}');
        }
      case _:
        throw Exception('Unexpected token: ${_peek()}');
    }
  }
}
