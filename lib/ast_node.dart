abstract class ASTNode {}

enum KebabType {
  i8,
  i16,
  i32,
  i64,
  //unsigned
  u1,
  u8,
  u16,
  u32,
  u64,

  //float
  f32,
  f64,

  //string
  char,
  str;

  String toCType() {
    switch (this) {
      case KebabType.i8: return "int8_t";
      case KebabType.i16: return "int16_t";
      case KebabType.i32: return "int32_t";
      case KebabType.i64: return "int64_t";
      case KebabType.u1: return "bool";
      case KebabType.u8: return "uint8_t";
      case KebabType.u16: return "uint16_t";
      case KebabType.u32: return "uint32_t";
      case KebabType.u64: return "uint64_t";
      case KebabType.f32: return "float";
      case KebabType.f64: return "double";
      case KebabType.char: return "char";
      case KebabType.str: return "string";
    }
  }
}

class IntNode extends ASTNode {
  final int value;

  IntNode(this.value);

  @override
  String toString() => value.toString();
}

class OpNode extends ASTNode {
  final ASTNode left;
  final String op;
  final ASTNode right;

  OpNode(this.left, this.op, this.right);

  @override
  String toString() => "$left $op $right";
}

class FuncCallNode extends ASTNode {
  final String name;
  final List<ASTNode> args;

  FuncCallNode(this.name, this.args);

  @override
  String toString() => "$name(${args.join(', ')})";
}

class VarDeclNode extends ASTNode {
  final String name;
  final KebabType? type;
  final ASTNode? value;

  VarDeclNode(this.name, this.type, this.value);

  @override
  String toString() => "$name: $type = $value;";
}

class VarRefNode extends ASTNode {
  final String name;

  VarRefNode(this.name);

  @override
  String toString() => name;
}

class VarAssignNode extends ASTNode {
  final String name;
  final ASTNode value;

  VarAssignNode(this.name, this.value);
}
