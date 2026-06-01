import 'ast_nodes.dart';
import 'var.dart' show Var;

class LLVMGenerator {
  final StringBuffer _globals = StringBuffer();
  final Map<int, String> _strings = {};
  final StringBuffer _code = StringBuffer();

  int _tmpId = 0;
  int _lblId = 0;
  int _strId = 0;

  final Map<String, String> _allocas = {};
  final Map<String, KebabType> _types = {};

  final List<String> _breakStack = [];
  final List<String> _continueStack = [];

  String addDependencies(final ASTNode program, final Map<String, Var> vars) {
    final dependencies = StringBuffer();

    bool hasPrint = false;
    bool needKPrintBool = false;
    bool needIntFmt = false;
    bool needStrFmt = false;

    void check(final ASTNode node) {
      switch (node) {
        case ProgramNode(statements: final stmts):
          for (final s in stmts) {
            check(s);
          }
        case BlockNode(statements: final stmts):
          for (final s in stmts) {
            check(s);
          } 
        case IfNode(condition: final c, thenBlock: final t, elseBlock: final e):
          check(c); check(t); if (e!= null) check(e);
        case WhileNode(condition: final c, block: final b):
          check(c); check(b);
        case ForNode(init: final i, cond: final c, step: final s, block: final b):
          if (i!= null) check(i); check(c); if (s!= null) check(s); check(b);
        case LoopNode(block: final b): check(b);
        case VarDeclNode(value: final v): check(v);
        case VarAssignNode(value: final v): check(v);
        case BOPNode(left: final l, right: final r): check(l); check(r);
        case CallNode(name: final name, args: final args):
          if (name == 'print') {
            hasPrint = true;
            if (args.isNotEmpty) {
              final arg = args.first;
              switch (arg) {
                case StringNode(): needStrFmt = true;
                case IntNode(): needIntFmt = true;
                case BoolNode(): needKPrintBool = true;
                case BOPNode(op: final op) when const ['==','!=','<','<=','>','>=','&&','||'].contains(op):
                  needKPrintBool = true;
                case BOPNode(left: final left, right: final right) when left is IntNode && right is IntNode:
                  needIntFmt = true;
                case BOPNode(left: final left, right: final right) when left is StringNode && right is StringNode:
                  needStrFmt = true;
                case VarRefNode(name: final n):
                  final t = vars[n]?.type;
                  if (t == KebabType.string) {
                    needStrFmt = true;
                  } else if (t == KebabType.bool) {
                    needKPrintBool = true;
                  }
                default: needIntFmt = true;
              }
              check(arg);
            }
          } else {
            for (final a in args) {
              check(a);
            }
          }
        case VarRefNode(): case IntNode(): case StringNode(): case BreakNode(): case ContinueNode(): break;
      }
    }

    check(program);

    if (hasPrint) {
      dependencies.writeln('declare i32 @printf(i8*,...)');
      if (needIntFmt) dependencies.writeln('@.str.int = private unnamed_addr constant [4 x i8] c"%d\\0A\\00"');
      if (needStrFmt) dependencies.writeln('@.str.str = private unnamed_addr constant [4 x i8] c"%s\\0A\\00"');
    }
    if (needKPrintBool) dependencies.writeln('declare void @kprintbool(i1)');
    return dependencies.toString();
  }

  String generateIr(final ASTNode program, final Map<String, Var> vars) {
    _globals.writeln(addDependencies(program, vars));
    
    _code.writeln('define i32 @main() {');
    _code.writeln('entry:');

    _gen(program);

    _code.writeln('  ret i32 0');
    _code.writeln('}');
    return '$_globals\n$_code';
  }

  String _tmp() => '%t${_tmpId++}';
  String _nextLbl(final String base) => '${base}_${_lblId++}';

  String _llvmType(final KebabType t) => switch (t) {
    KebabType.int => 'i32',
    KebabType.bool => 'i1',
    KebabType.string => 'i8*',
    KebabType.none => 'void',
  };

  KebabType _infer(final ASTNode n) => switch (n) {
    IntNode() => KebabType.int,
    StringNode() => KebabType.string,
    BoolNode() => KebabType.bool,
    BOPNode(op: final op) when const ['==','!=','<','<=','>','>=','&&','||'].contains(op) => KebabType.bool,
    BOPNode(left: final l, right: final r) => switch ((l, r)) {
      (IntNode(), IntNode()) => KebabType.int,
      (StringNode(), StringNode()) => KebabType.string,
      _ => KebabType.bool,
    },
    VarRefNode(name: final name) => _types[name] ?? KebabType.int,
    _ => KebabType.int,
  };

  String _escape(final String s) => s
      .replaceAll('\\', '\\5C')
      .replaceAll('"', '\\22')
      .replaceAll('\n', '\\0A');

  String _gen(final ASTNode node) {
    switch (node) {
      case ProgramNode(statements: final stmts):
        for (final s in stmts) {
          _gen(s);
        }
        return '';

      case BlockNode(statements: final stmts):
        for (final s in stmts) {
          _gen(s);
        }
        return '';

      case IntNode(value: final v):
        return v.toString();

      case StringNode(value: final v):
        if (!_strings.containsValue(v)) {
          final id = _strId++;
          _globals.writeln('@.s$id = private unnamed_addr constant [${v.length + 1} x i8] c"${_escape(v)}\\00"');
          _strings[id] = v;
        }
        final id = _strings.keys.firstWhere((final k) => _strings[k] == v);
        final r = _tmp();
        _code.writeln('  $r = getelementptr inbounds [${v.length + 1} x i8], [${v.length + 1} x i8]* @.s$id, i32 0, i32 0');
        return r;

      case BoolNode(value: final v):
        return v ? 'true' : 'false';

      case VarDeclNode(name: final n, type: final t, value: final v):
        final kt = t ?? _infer(v);
        final lt = _llvmType(kt);
        final ptr = '%$n';
        _allocas[n] = ptr;
        _types[n] = kt;
        _code.writeln('  $ptr = alloca $lt');
        final val = _gen(v);
        _code.writeln('  store $lt $val, $lt* $ptr');
        return '';

      case VarAssignNode(name: final n, value: final v):
        final ptr = _allocas[n]!;
        final lt = _llvmType(_types[n]!);
        final val = _gen(v);
        _code.writeln('  store $lt $val, $lt* $ptr');
        return '';

      case VarRefNode(name: final n):
        final ptr = _allocas[n]!;
        final lt = _llvmType(_types[n]!);
        final r = _tmp();
        _code.writeln('  $r = load $lt, $lt* $ptr');
        return r;

      case BOPNode(left: final l, op: final o, right: final r):
        final lv = _gen(l);
        final rv = _gen(r);
        final res = _tmp();
        switch ((l, r)) {
          case (IntNode(), IntNode()): 
            switch (o) {
            case '+': _code.writeln('  $res = add nsw i32 $lv, $rv');
            case '-': _code.writeln('  $res = sub nsw i32 $lv, $rv');
            case '*': _code.writeln('  $res = mul nsw i32 $lv, $rv');
            case '/': _code.writeln('  $res = sdiv i32 $lv, $rv');
            case '%': _code.writeln('  $res = srem i32 $lv, $rv');
            case '==': _code.writeln('  $res = icmp eq i32 $lv, $rv');
            case '!=': _code.writeln('  $res = icmp ne i32 $lv, $rv');
            case '<': _code.writeln('  $res = icmp slt i32 $lv, $rv');
            case '<=': _code.writeln('  $res = icmp sle i32 $lv, $rv');
            case '>': _code.writeln('  $res = icmp sgt i32 $lv, $rv');
            case '>=': _code.writeln('  $res = icmp sge i32 $lv, $rv');
            case '&&': _code.writeln('  $res = and i1 $lv, $rv');
            case '||': _code.writeln('  $res = or i1 $lv, $rv');
            default: throw 'unknown op $o';
          }
          case (StringNode(value: final lv), StringNode(value: final rv)) when o == '+':
            final id = _strId++;
            _globals.writeln('@.s$id = private unnamed_addr constant [${lv.length + rv.length + 1} x i8] c"$lv$rv\\00"');
            _code.writeln('  $res = getelementptr inbounds [${lv.length + rv.length + 1} x i8], [${lv.length + rv.length + 1} x i8]* @.s$id, i32 0, i32 0');
            break;
        }
        return res;

      case CallNode(name: final n, args: final a):
        if (n == 'print' && a.isNotEmpty) {
          final arg = a.first;
          final val = _gen(arg);
          final kt = _infer(arg);
          if (kt == KebabType.string) {
            _code.writeln('  call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.str, i32 0, i32 0), i8* $val)');
          } else if (kt == KebabType.bool) {
            _code.writeln('  call void @kprintbool(i1 $val)');
          } else {
            _code.writeln('  call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.int, i32 0, i32 0), i32 $val)');
          }
        }
        return '';

      case IfNode(condition: final c, thenBlock: final t, elseBlock: final e):
        final cond = _gen(c);
        final thenL = _nextLbl('if.then');
        final elseL = _nextLbl('if.else');
        final endL = _nextLbl('if.end');
        _code.writeln('  br i1 $cond, label %$thenL, label %${e != null ? elseL : endL}');
        _code.writeln('$thenL:');
        _gen(t);
        _code.writeln('  br label %$endL');
        if (e != null) {
          _code.writeln('$elseL:');
          _gen(e);
          _code.writeln('  br label %$endL');
        }
        _code.writeln('$endL:');
        return '';

      case WhileNode(condition: final c, block: final b):
        final condL = _nextLbl('while.cond');
        final bodyL = _nextLbl('while.body');
        final endL = _nextLbl('while.end');
        _breakStack.add(endL);
        _continueStack.add(condL);
        _code.writeln('  br label %$condL');
        _code.writeln('$condL:');
        final cond = _gen(c);
        _code.writeln('  br i1 $cond, label %$bodyL, label %$endL');
        _code.writeln('$bodyL:');
        _gen(b);
        _code.writeln('  br label %$condL');
        _code.writeln('$endL:');
        _breakStack.removeLast();
        _continueStack.removeLast();
        return '';

      case ForNode(init: final i, cond: final c, step: final s, block: final b):
        if (i != null) _gen(i);
        final condL = _nextLbl('for.cond');
        final bodyL = _nextLbl('for.body');
        final stepL = _nextLbl('for.step');
        final endL = _nextLbl('for.end');
        _breakStack.add(endL);
        _continueStack.add(stepL);
        _code.writeln('  br label %$condL');
        _code.writeln('$condL:');
        final cond = _gen(c);
        _code.writeln('  br i1 $cond, label %$bodyL, label %$endL');
        _code.writeln('$bodyL:');
        _gen(b);
        _code.writeln('  br label %$stepL');
        _code.writeln('$stepL:');
        if (s != null) _gen(s);
        _code.writeln('  br label %$condL');
        _code.writeln('$endL:');
        _breakStack.removeLast();
        _continueStack.removeLast();
        return '';

      case LoopNode(block: final b):
        final bodyL = _nextLbl('loop');
        final endL = _nextLbl('loop.end');
        _breakStack.add(endL);
        _continueStack.add(bodyL);
        _code.writeln('  br label %$bodyL');
        _code.writeln('$bodyL:');
        _gen(b);
        _code.writeln('  br label %$bodyL');
        _code.writeln('$endL:');
        _breakStack.removeLast();
        _continueStack.removeLast();
        return '';

      case BreakNode():
        _code.writeln('  br label %${_breakStack.last}');
        return '';

      case ContinueNode():
        _code.writeln('  br label %${_continueStack.last}');
        return '';
    }
    return '';
  }
}
