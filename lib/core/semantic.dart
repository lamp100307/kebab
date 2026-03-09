import 'package:kebab/exceptions/exceptions.dart';

import 'ast_node.dart';

class SemanticAnalyser {
  final List<ASTNode> nodes;
  final Map<String, KebabType> variables = {}; // symbol-table
  final List<SemanticException> errors = [];

  SemanticAnalyser(this.nodes);

  void analyse() {
    for (var node in nodes) {
      _analyseNode(node);
    }
  }

  void _analyseNode(final ASTNode node) {
    switch (node) {
      case VarDeclNode(name: final name, type: final type, value: final value):
        _analyseVarDecl(name, type, value);
        break;

      case VarAssignNode(name: final name, value: final value):
        _analyseVarAssign(name, value);
        break;

      case OpNode(left: final left, op: final op, right: final right):
        _analyseOp(left, op, right);
        break;

      case FuncCallNode(name: final name, args: final args):
        _analyseFuncCall(name, args);
        break;

      case IfNode(condition: final cond, thenBlock: final then, elseBlock: final elseBlock):
        _analyseIfNode(cond, then, elseBlock);
        break;

      case BlockNode(statements: final statements):
        for (var statement in statements) {
          _analyseNode(statement);
        }
        break;

      case ForNode(init: final init, condition: final condition, update: final update, block: final block): 
        if (init != null) {
          _analyseNode(init);
        }
        _analyseNode(condition);
        if (update != null) {
          _analyseNode(update);
        }
        _analyseNode(block);
      case IntNode():
      case VarRefNode():
        // leaf nodes are handled in expressions
        break;

      default:
        errors.add(SemanticUnknownNodeType(node.runtimeType.toString()));
    }
  }

  void _analyseIfNode(
    final ASTNode cond,
    final ASTNode then,
    final ASTNode? else_
  ) {
    _analyseNode(cond);
    _analyseNode(then);
    if (else_ != null) {
      _analyseNode(else_);
    }
  }

  void _analyseVarDecl(
    final String name,
    final KebabType? type,
    final ASTNode? value,
  ) {
    // checking for a repeat declaration
    if (variables.containsKey(name)) {
      errors.add(SemanticVarAlreadyDefinedException(name));
      return;
    }

    if (value != null) {
      final valueType = _astNodeToType(value);

      if (type != null) {
        // checking for typing compatible
        if (!_areTypesCompatible(type, valueType)) {
          errors.add(SemanticTypeMismatchException(type, valueType));
        }
        variables[name] = type;
      } else {
        // type output
        variables[name] = valueType;
      }
    } else {
      if (type == null) {
        errors.add(
          SemanticVarInitException(
            'Variable "$name" must have type or initializer',
          ),
        );
      } else {
        variables[name] = type;
      }
    }
  }

  void _analyseVarAssign(final String name, final ASTNode value) {
    if (!variables.containsKey(name)) {
      errors.add(SemanticVarNotDefinedException(name));
      return;
    }

    final varType = variables[name]!;
    final valueType = _astNodeToType(value);

    if (!_areTypesCompatible(varType, valueType)) {
      errors.add(SemanticTypeMismatchException(varType, valueType));
    }
  }

  KebabType _analyseOp(
    final ASTNode left,
    final String op,
    final ASTNode right,
  ) {
    
    final leftType = _astNodeToType(left);
    final rightType = _astNodeToType(right);

    // checking for numeric types for arithmetic
    if (op == '+' || op == '-' || op == '*' || op == '/') {
      if (leftType is! NumType && leftType is! FloatType) {
        errors.add(SemanticOpUnexpexctedTypeException(leftType, op, Side.left));
      }
      if (rightType is! NumType && rightType is! FloatType) {
        errors.add(
          SemanticOpUnexpexctedTypeException(rightType, op, Side.right),
        );
      }
    }

    return _typeFromTwo(leftType, rightType);
  }

  // TODO: implement function call analysis
  // For now, assume it returns i32
  KebabType _analyseFuncCall(final String name, final List<ASTNode> args) {
    for (final arg in args) {
      _analyseNode(arg);
    }
    return I32();
  }

  KebabType _astNodeToType(final ASTNode node) {
    switch (node) {
      case IntNode():
        return I32(); // default int literal is i32

      case StrNode():
        return Str();

      case OpNode(left: final left, right: final right):
        final leftType = _astNodeToType(left);
        final rightType = _astNodeToType(right);
        return _typeFromTwo(leftType, rightType);

      case VarRefNode(name: final name):
        if (!variables.containsKey(name)) {
          errors.add(SemanticVarNotDefinedException(name));
          return I32(); // fallback
        }
        return variables[name]!;

      case FuncCallNode():
        return I32(); // TODO: get actual return type

      case VarDeclNode(value: final value):
        if (value != null) {
          return _astNodeToType(value);
        }
        return I32(); // fallback

      default:
        errors.add(SemanticUnknownNodeType(node.runtimeType.toString()));
        return I32(); // fallback
    }
  }

  bool _areTypesCompatible(final KebabType target, final KebabType source) {
    // Ssame type
    if (target.runtimeType == source.runtimeType) return true;

    // numeric promotion
    if (target is NumType && source is NumType) {
      return true; // all numbers are compatible (with loss of precision)
    }

    if (target is FloatType && source is NumType) {
      return true; // int can be promoted to float
    }

    return false;
  }

  KebabType _typeFromTwo(final KebabType type1, final KebabType type2) {
    // if either type is Float, result is Float
    if (type1 is FloatType || type2 is FloatType) {
      if (type1 is F64 || type2 is F64) return F64();
      return F32();
    }

    // both numbers
    if (type1 is NumType && type2 is NumType) {
      return _biggerNumType(type1, type2);
    }

    // if types are incompatible, return type1 as fallback
    errors.add(SemanticIncompatibleException(type1, type2));
    return type1;
  }

  KebabType _biggerNumType(final NumType type1, final NumType type2) {
    // Type promotion priority (higher number = higher priority)
    const priority = {
      I8: 1,
      U8: 2,
      I16: 3,
      U16: 4,
      I32: 5,
      U32: 6,
      I64: 7,
      U64: 8,
    };

    final p1 = priority[type1.runtimeType] ?? 0;
    final p2 = priority[type2.runtimeType] ?? 0;

    return p1 >= p2 ? type1 : type2;
  }
}
