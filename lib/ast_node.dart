abstract class ASTNode {}

sealed class KebabType {
  String toCType();
}

sealed class NumType extends KebabType {}
sealed class FloatType extends KebabType {}

class I8 extends NumType {
  @override
  String toCType() => "int8_t";
}
class I16 extends NumType {
  @override
  String toCType() => "int16_t";
}
class I32 extends NumType {
  @override
  String toCType() => "int32_t";
}
class I64 extends NumType {
  @override
  String toCType() => "int64_t";
}

class U8 extends NumType {
  @override
  String toCType() => "uint8_t";
}
class U16 extends NumType {
  @override
  String toCType() => "uint16_t";
}
class U32 extends NumType {
  @override
  String toCType() => "uint32_t";
}
class U64 extends NumType {
  @override
  String toCType() => "uint64_t";
}

class F32 extends FloatType {
  @override
  String toCType() => "float";
}
class F64 extends FloatType {
  @override
  String toCType() => "double";
}

class Char extends KebabType {
  @override
  String toCType() => "char";
}
class Str extends KebabType {
  @override
  String toCType() => "string";
}

class Bool extends NumType {
  @override
  String toCType() => "bool";
}

class IntNode extends ASTNode {
  final int value;

  IntNode(this.value);

  @override
  String toString() => value.toString();
}

class StrNode extends ASTNode {
  final String value;

  StrNode(this.value);

  @override
  String toString() => "\"$value\"";
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
