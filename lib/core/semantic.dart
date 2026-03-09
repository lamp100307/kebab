import 'dart:io';

import 'ast_node.dart';

class SemanticAnalyser {
  final List<ASTNode> nodes;
  final Map<String, KebabType> variables = {}; // символ-таблица
  final List<String> errors = [];

  SemanticAnalyser(this.nodes);

  void analyse() {
    for (var node in nodes) {
      analyseNode(node);
    }

    if (errors.isNotEmpty) {
      for (var error in errors) {
        print('Semantic error: $error');
      }
      exit(1);
    }
  }

  void analyseNode(ASTNode node) {
    switch (node) {
      case VarDeclNode(name: final name, type: final type, value: final value):
        analyseVarDecl(name, type, value);
        break;

      case VarAssignNode(name: final name, value: final value):
        analyseVarAssign(name, value);
        break;

      case OpNode(left: final left, op: final op, right: final right):
        analyseOp(left, op, right);
        break;

      case FuncCallNode(name: final name, args: final args):
        analyseFuncCall(name, args);
        break;

      case IntNode():
      case VarRefNode():
        // leaf nodes are handled in expressions
        break;

      default:
        errors.add('Unknown node type: ${node.runtimeType}');
    }
  }

  void analyseVarDecl(String name, KebabType? type, ASTNode? value) {
    // Проверка на повторное объявление
    if (variables.containsKey(name)) {
      errors.add('Variable "$name" already declared');
      return;
    }

    if (value != null) {
      final valueType = astNodeToType(value);

      if (type != null) {
        // Проверка соответствия типов
        if (!areTypesCompatible(type, valueType)) {
          errors.add('Type mismatch: cannot assign $valueType to $type');
        }
        variables[name] = type;
      } else {
        // Вывод типа
        variables[name] = valueType;
      }
    } else {
      if (type == null) {
        errors.add('Variable "$name" must have type or initializer');
      } else {
        variables[name] = type;
      }
    }
  }

  void analyseVarAssign(String name, ASTNode value) {
    if (!variables.containsKey(name)) {
      errors.add('Variable "$name" not declared');
      return;
    }

    final varType = variables[name]!;
    final valueType = astNodeToType(value);

    if (!areTypesCompatible(varType, valueType)) {
      errors.add('Type mismatch: cannot assign $valueType to $varType');
    }
  }

  KebabType analyseOp(ASTNode left, String op, ASTNode right) {
    final leftType = astNodeToType(left);
    final rightType = astNodeToType(right);

    // Проверка на числовые типы для арифметики
    if (op == '+' || op == '-' || op == '*' || op == '/') {
      if (leftType is! NumType && leftType is! FloatType) {
        errors.add('Left operand of $op must be numeric, got $leftType');
      }
      if (rightType is! NumType && rightType is! FloatType) {
        errors.add('Right operand of $op must be numeric, got $rightType');
      }
    }

    return typeFromTwo(leftType, rightType);
  }

  KebabType analyseFuncCall(String name, List<ASTNode> args) {
    // TODO: implement function call analysis
    // For now, assume it returns i32
    return I32();
  }

  KebabType astNodeToType(ASTNode node) {
    switch (node) {
      case IntNode():
        return I32(); // default int literal is i32

      case StrNode():
        return Str();

      case OpNode(left: final left, right: final right):
        final leftType = astNodeToType(left);
        final rightType = astNodeToType(right);
        return typeFromTwo(leftType, rightType);

      case VarRefNode(name: final name):
        if (!variables.containsKey(name)) {
          errors.add('Variable "$name" not declared');
          return I32(); // fallback
        }
        return variables[name]!;

      case FuncCallNode():
        return I32(); // TODO: get actual return type

      case VarDeclNode(value: final value):
        if (value != null) {
          return astNodeToType(value);
        }
        return I32(); // fallback

      default:
        errors.add('Cannot get type from ${node.runtimeType}');
        return I32(); // fallback
    }
  }

  bool areTypesCompatible(KebabType target, KebabType source) {
    // Same type
    if (target.runtimeType == source.runtimeType) return true;

    // Numeric promotion
    if (target is NumType && source is NumType) {
      return true; // все числа совместимы (с потерей точности)
    }

    if (target is FloatType && source is NumType) {
      return true; // int может быть приведен к float
    }

    return false;
  }

  KebabType typeFromTwo(KebabType type1, KebabType type2) {
    // Если один из типов Float, результат Float
    if (type1 is FloatType || type2 is FloatType) {
      if (type1 is F64 || type2 is F64) return F64();
      return F32();
    }

    // Оба числа
    if (type1 is NumType && type2 is NumType) {
      return biggerNumType(type1, type2);
    }

    // Если типы несовместимы, возвращаем type1 как fallback
    errors.add('Incompatible types: $type1 and $type2');
    return type1;
  }

  KebabType biggerNumType(NumType type1, NumType type2) {
    // Приоритет типов (чем больше число, тем выше приоритет)
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
