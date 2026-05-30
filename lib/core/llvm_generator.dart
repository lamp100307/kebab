import 'ast_nodes.dart';

class LLVMGenerator {
  final StringBuffer _ir = StringBuffer();
  int _nextRegister = 1;
  int _nextLabel = 1;
  final Map<String, String> _variables = {}; // name -> LLVM register (alloca)
  final List<String> _stringLiterals = [];
  final List<Map<String, String>> _variableScopes = []; // Scopes of variables

  String addDependencies(final ASTNode node) {
    String result = '';
    bool hasPrint = false;
    
    void traverse(ASTNode n) {
      if (n is ProgramNode) {
        for (final statement in n.statements) {
          traverse(statement);
        }
      } else if (n is CallNode && n.name == 'print' && !hasPrint) {
        result += 'declare i32 @printf(i8*, ...)\n';
        hasPrint = true;
      } else if (n is BlockNode) {
        for (final statement in n.statements) {
          traverse(statement);
        }
      } else if (n is IfNode) {
        traverse(n.condition);
        traverse(n.thenBlock);
        if (n.elseBlock != null) traverse(n.elseBlock!);
      } else if (n is BOPNode) {
        traverse(n.left);
        traverse(n.right);
      } else if (n is ForNode) {
        traverse(n.cond);
        traverse(n.block);
        if (n.step != null) traverse(n.step!);
        if (n.init != null) traverse(n.init!);
      }
    }
    
    traverse(node);
    return result;
  }

  String generate(final ASTNode node) {
    _ir.clear();
    _nextRegister = 1;
    _nextLabel = 1;
    _variables.clear();
    _stringLiterals.clear();
    _variableScopes.clear();

    _ir.writeln('; ModuleID = "kebab"');
    _ir.writeln('target triple = "x86_64-pc-linux-gnu"');
    _ir.writeln(addDependencies(node));
    _ir.writeln();
    _ir.writeln();

    _generateNode(node);

    return _ir.toString();
  }

  String _newRegister() => '%${_nextRegister++}';
  String _newLabel() => 'label${_nextLabel++}';

  void _pushScope() {
    _variableScopes.add(Map.from(_variables));
  }

  void _popScope() {
    if (_variableScopes.isNotEmpty) {
      final previousScope = _variableScopes.removeLast();
      _variables.clear();
      _variables.addAll(previousScope);
    }
  }

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
    } else if (node is BlockNode) {
      _generateBlock(node);
    } else if (node is IfNode) {
      _generateIf(node);
    } else if (node is ForNode) {
      _generateFor(node);
    } else {
      throw Exception('Unknown statement: ${node.runtimeType}');
    }
  }

  void _generateBlock(final BlockNode node) {
    _pushScope();
    for (final statement in node.statements) {
      _generateStatement(statement);
    }
    _popScope();
  }

  void _generateIf(final IfNode node) {
    // Gen condition
    final condReg = _generateCondition(node.condition);
    
    final thenLabel = _newLabel();
    final elseLabel = _newLabel();
    final endLabel = _newLabel();
    
    // Conditional jump
    _ir.writeln('  br i1 $condReg, label %$thenLabel, label %${node.elseBlock != null ? elseLabel : endLabel}');
    
    // Then block
    _ir.writeln('$thenLabel:');
    _pushScope();
    _generateStatement(node.thenBlock);
    _popScope();
    _ir.writeln('  br label %$endLabel');
    
    // Else block (if have)
    if (node.elseBlock != null) {
      _ir.writeln('$elseLabel:');
      _pushScope();
      _generateStatement(node.elseBlock!);
      _popScope();
      _ir.writeln('  br label %$endLabel');
    }
    
    // End of if
    _ir.writeln('$endLabel:');
  }

  String _generateCondition(final ASTNode node) {
    if (node is BOPNode) {
      return _generateComparison(node);
    } else {
      final value = _generateExpr(node);
      final result = _newRegister();
      _ir.writeln('  $result = icmp ne i32 $value, 0');
      return result;
    }
  }

  void _generateFor(final ForNode node) {
    final condLabel = _newLabel();
    final bodyLabel = _newLabel();
    final stepLabel = _newLabel();
    final endLabel = _newLabel();

    _pushScope();
    if (node.init != null) {
      _generateStatement(node.init!);
    }

    _ir.writeln('  br label %$condLabel');

    _ir.writeln('$condLabel:');
    final condReg = _generateCondition(node.cond);
    _ir.writeln('  br i1 $condReg, label %$bodyLabel, label %$endLabel');

    _ir.writeln('$bodyLabel:');
    _generateStatement(node.block);
    _ir.writeln('  br label %$stepLabel');

    _ir.writeln('$stepLabel:');
    if (node.step != null) {
      _generateStatement(node.step!);
    }
    _ir.writeln('  br label %$condLabel');

    _ir.writeln('$endLabel:');
    _popScope();
  }

  String _generateComparison(final BOPNode node) {
    final left = _generateExpr(node.left);
    final right = _generateExpr(node.right);
    final result = _newRegister();
    
    switch (node.op) {
      case '==':
        _ir.writeln('  $result = icmp eq i32 $left, $right');
        break;
      case '!=':
        _ir.writeln('  $result = icmp ne i32 $left, $right');
        break;
      case '<':
        _ir.writeln('  $result = icmp slt i32 $left, $right');
        break;
      case '<=':
        _ir.writeln('  $result = icmp sle i32 $left, $right');
        break;
      case '>':
        _ir.writeln('  $result = icmp sgt i32 $left, $right');
        break;
      case '>=':
        _ir.writeln('  $result = icmp sge i32 $left, $right');
        break;
      default:
        throw Exception('Unknown comparison operator: ${node.op}');
    }
    
    return result;
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
      if (_isComparisonOperator(node.op)) {
        final cond = _generateComparison(node);
        final result = _newRegister();
        _ir.writeln('  $result = zext i1 $cond to i32');
        return result;
      }
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

  bool _isComparisonOperator(String op) {
    return op == '==' || op == '!=' || op == '<' || op == '<=' || op == '>' || op == '>=';
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