abstract base class ASTNode {}

abstract interface class KebabType {
  String toCType();
}

sealed class NumType implements KebabType {}

sealed class FloatType implements KebabType {}

class I8 implements NumType {
  @override
  String toCType() => "int8_t";
}

class I16 implements NumType {
  @override
  String toCType() => "int16_t";
}

class I32 implements NumType {
  @override
  String toCType() => "int32_t";
}

class I64 implements NumType {
  @override
  String toCType() => "int64_t";
}

class U8 implements NumType {
  @override
  String toCType() => "uint8_t";
}

class U16 implements NumType {
  @override
  String toCType() => "uint16_t";
}

class U32 implements NumType {
  @override
  String toCType() => "uint32_t";
}

class U64 implements NumType {
  @override
  String toCType() => "uint64_t";
}

class F32 implements FloatType {
  @override
  String toCType() => "float";
}

class F64 implements FloatType {
  @override
  String toCType() => "double";
}

class Char implements KebabType {
  @override
  String toCType() => "char";
}

class Str implements KebabType {
  @override
  String toCType() => "string";
}

class Bool implements NumType {
  @override
  String toCType() => "bool";
}

final class IntNode extends ASTNode {
  final int value;

  IntNode(this.value);

  @override
  String toString() => value.toString();
}

final class StrNode extends ASTNode {
  final String value;

  StrNode(this.value);

  @override
  String toString() => "\"$value\"";
}

final class OpNode extends ASTNode {
  final ASTNode left;
  final String op;
  final ASTNode right;

  OpNode(this.left, this.op, this.right);

  @override
  String toString() => "$left $op $right";
}

final class FuncCallNode extends ASTNode {
  final String name;
  final List<ASTNode> args;

  FuncCallNode(this.name, this.args);

  @override
  String toString() => "$name(${args.join(', ')})";
}

final class VarDeclNode extends ASTNode {
  final String name;
  final KebabType? type;
  final ASTNode? value;

  VarDeclNode(this.name, this.type, this.value);

  @override
  String toString() => "$name: $type = $value;";
}

final class VarRefNode extends ASTNode {
  final String name;

  VarRefNode(this.name);

  @override
  String toString() => name;
}

final class VarAssignNode extends ASTNode {
  final String name;
  final ASTNode value;

  VarAssignNode(this.name, this.value);
}
