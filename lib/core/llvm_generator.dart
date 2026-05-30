import 'ast_nodes.dart';

class LLVMGenerator {
  final StringBuffer _ir = StringBuffer();
  int _nextRegister = 1;
  final Map<String, String> _variables = {}; // name -> LLVM register (alloca)
  final List<String> _stringLiterals = [];

  String addDependencies(final ASTNode node) {
    String result = '';
    bool hasPrint = false;
    switch (node) {
      case ProgramNode(statements: final statements):
        for (final statement in statements) {
          switch (statement) {
            case CallNode(name: final name):
              if (name == 'print' && !hasPrint) {
                result += 'declare i32 @printf(i8*, ...)\n';
                hasPrint = true;
              }
            default:
              break;
          }
        }
      default:
        break;
    }
    return result;
  }

  String generate(final ASTNode node) {
    _ir.clear();
    _nextRegister = 1;
    _variables.clear();
    _stringLiterals.clear();

    _ir.writeln('; ModuleID = "kebab"');
    _ir.writeln('target triple = "x86_64-pc-linux-gnu"');
    _ir.writeln(addDependencies(node));
    _ir.writeln();
    _ir.writeln();
    _ir.writeln();

    _generateNode(node);

    return _ir.toString();
  }

  String _newRegister() => '%${_nextRegister++}';

  void _generateNode(final ASTNode node) {
    if (node is ProgramNode) {
      _generateProgram(node);
    } else {
      throw Exception('Unknown AST node: ${node.runtimeType}');
    }
  }

  void _generateProgram(final ProgramNode program) {
    _ir.writeln('define i32 @main() {');
    _ir.writeln('entry:');

    for (final statement in program.statements) {
      _generateStatement(statement);
    }

    _ir.writeln('  ret i32 0');
    _ir.writeln('}');
    _ir.writeln();

    _addStringLiterals();
  }

  void _generateStatement(final ASTNode node) {
    if (node is VarDeclNode) {
      _generateVarDecl(node);
    } else if (node is VarAssignNode) {
      _generateVarAssign(node);
    } else if (node is CallNode) {
      _generateCall(node);
    } else if (node is BOPNode) {
      _generateExpr(node);
    } else {
      throw Exception('Unknown statement: ${node.runtimeType}');
    }
  }

  void _generateVarDecl(final VarDeclNode node) {
    final varReg = _newRegister();
    _variables[node.name] = varReg;
    _ir.writeln('  $varReg = alloca i32, align 4');

    final valueReg = _generateExpr(node.value);
    _ir.writeln('  store i32 $valueReg, i32* $varReg, align 4');
  }

  void _generateVarAssign(final VarAssignNode node) {
    if (!_variables.containsKey(node.name)) {
      throw Exception('Variable "${node.name}" not declared');
    }
    final valueReg = _generateExpr(node.value);
    final varReg = _variables[node.name];
    _ir.writeln('  store i32 $valueReg, i32* $varReg, align 4');
  }

  String _generateExpr(final ASTNode node) {
    if (node is IntNode) {
      return node.value.toString();
    } else if (node is StringNode) {
      return _getStringLiteralPtr(node.value);
    } else if (node is BOPNode) {
      return _generateBinaryOp(node);
    } else if (node is VarRefNode) {
      return _generateVarRef(node);
    } else if (node is CallNode) {
      _generateCall(node);
      return '0';
    } else {
      throw Exception('Unknown expression: ${node.runtimeType}');
    }
  }

  String _generateBinaryOp(final BOPNode node) {
    final left = _generateExpr(node.left);
    final right = _generateExpr(node.right);
    final result = _newRegister();

    switch (node.op) {
      case '+':
        _ir.writeln('  $result = add i32 $left, $right');
        break;
      case '-':
        _ir.writeln('  $result = sub i32 $left, $right');
        break;
      case '*':
        _ir.writeln('  $result = mul i32 $left, $right');
        break;
      case '/':
        _ir.writeln('  $result = sdiv i32 $left, $right');
        break;
      default:
        throw Exception('Unknown operator: ${node.op}');
    }

    return result;
  }

  String _generateVarRef(final VarRefNode node) {
    if (!_variables.containsKey(node.name)) {
      throw Exception('Variable "${node.name}" not declared');
    }
    final varReg = _variables[node.name];
    final tempReg = _newRegister();
    _ir.writeln('  $tempReg = load i32, i32* $varReg, align 4');
    return tempReg;
  }

  void _generateCall(final CallNode node) {
    if (node.name == 'print') {
      _generatePrintCall(node);
    } else {
      _ir.writeln('  ; TODO: Implement call to ${node.name}');
    }
  }

  void _generatePrintCall(final CallNode node) {
    if (node.args.isEmpty) {
      throw Exception('print requires at least one argument');
    }

    final arg = node.args.first;

    if (arg is StringNode) {
      final formatString = _getOrAddStringLiteral("%s\n");
      final strPtr = _getStringLiteralPtr(arg.value);
      final tempReg = _newRegister();
      _ir.writeln(
        '  $tempReg = call i32 (i8*, ...) @printf(i8* $formatString, i8* $strPtr)',
      );
    } else {
      final formatString = _getOrAddStringLiteral("%d\n");
      final value = _generateExpr(arg);
      final tempReg = _newRegister();
      _ir.writeln(
        '  $tempReg = call i32 (i8*, ...) @printf(i8* $formatString, i32 $value)',
      );
    }
  }

  String _getOrAddStringLiteral(final String value) {
    int index = _stringLiterals.indexOf(value);
    if (index == -1) {
      index = _stringLiterals.length;
      _stringLiterals.add(value);
    }
    return _getStringLiteralPtrByIndex(index, value);
  }

  String _getStringLiteralPtr(final String value) {
    int index = _stringLiterals.indexOf(value);
    if (index == -1) {
      index = _stringLiterals.length;
      _stringLiterals.add(value);
    }
    return _getStringLiteralPtrByIndex(index, value);
  }

  String _getStringLiteralPtrByIndex(final int index, final String value) {
    if (index == 0) {
      return 'getelementptr inbounds ([${value.length + 1} x i8], [${value.length + 1} x i8]* @.str, i32 0, i32 0)';
    } else {
      return 'getelementptr inbounds ([${value.length + 1} x i8], [${value.length + 1} x i8]* @.str$index, i32 0, i32 0)';
    }
  }

  void _addStringLiterals() {
    if (_stringLiterals.isEmpty) return;

    for (int i = 0; i < _stringLiterals.length; i++) {
      final str = _stringLiterals[i];
      final escaped = _escapeString(str);
      if (i == 0) {
        _ir.writeln(
          '@.str = private unnamed_addr constant [${str.length + 1} x i8] c"$escaped\\00", align 1',
        );
      } else {
        _ir.writeln(
          '@.str$i = private unnamed_addr constant [${str.length + 1} x i8] c"$escaped\\00", align 1',
        );
      }
    }
  }

  String _escapeString(final String str) => str
      .replaceAll('\\', '\\\\')
      .replaceAll('"', '\\"')
      .replaceAll('\n', '\\0A')
      .replaceAll('\r', '\\0D')
      .replaceAll('\t', '\\09');
}
