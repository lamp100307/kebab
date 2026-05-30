enum KebabType { int, string, none }

// Basic class for AST nodes
abstract class ASTNode {
  @override
  String toString();
}

// Program (list of statements)
class ProgramNode extends ASTNode {
  final List<ASTNode> statements;

  ProgramNode(this.statements);

  @override
  String toString() => "ProgramNode(statements: $statements)";
}

class IntNode extends ASTNode {
  final int value;

  IntNode(this.value);

  @override
  String toString() => "IntNode(value: $value)";
}

class StringNode extends ASTNode {
  final String value;

  StringNode(this.value);

  @override
  String toString() => "StringNode(value: $value)";
}

class BOPNode extends ASTNode {
  final ASTNode left;
  final String op;
  final ASTNode right;

  BOPNode(this.left, this.op, this.right);

  @override
  String toString() => "BOPNode(left: $left, op: $op, right: $right)";
}

class VarDeclNode extends ASTNode {
  final String name;
  final KebabType? type;
  final ASTNode value;

  VarDeclNode(this.name, this.type, this.value);

  @override
  String toString() => "VarDeclNode(name: $name, type: $type, value: $value)";
}

class VarAssignNode extends ASTNode {
  final String name;
  final ASTNode value;

  VarAssignNode(this.name, this.value);

  @override
  String toString() => "VarAssignNode(name: $name, value: $value)";
}

class VarRefNode extends ASTNode {
  final String name;

  VarRefNode(this.name);

  @override
  String toString() => "VarRefNode(name: $name)";
}

class CallNode extends ASTNode {
  final String name;
  final List<ASTNode> args;

  CallNode(this.name, this.args);

  @override
  String toString() => "CallNode(name: $name, args: $args)";
}
