enum KebabType { int, string, bool, none }

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

abstract class ValueNode {
  Object get value;
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

class BlockNode extends ASTNode {
  final List<ASTNode> statements;

  BlockNode(this.statements);

  @override
  String toString() => "BlockNode(statements: $statements)";
}

class IfNode extends ASTNode {
  final ASTNode condition;
  final ASTNode thenBlock;
  final ASTNode? elseBlock;

  IfNode(this.condition, this.thenBlock, this.elseBlock);

  @override
  String toString() =>
      "IfNode(condition: $condition, thenBlock: $thenBlock, elseBlock: $elseBlock)";
}

class ForNode extends ASTNode {
  final ASTNode? init;
  final ASTNode cond;
  final ASTNode? step;
  final ASTNode block;

  ForNode(this.init, this.cond, this.step, this.block);

  @override
  String toString() =>
      "ForNode(init: $init, cond: $cond, step: $step, block: $block)";
}

class WhileNode extends ASTNode {
  final ASTNode condition;
  final ASTNode block;

  WhileNode(this.condition, this.block);

  @override
  String toString() => "WhileNode(condition: $condition, block: $block)";
}

class LoopNode extends ASTNode {
  final ASTNode block;

  LoopNode(this.block);

  @override
  String toString() => "LoopNode()";
}

class BreakNode extends ASTNode {
  @override
  String toString() => "BreakNode()";
}

class ContinueNode extends ASTNode {
  @override
  String toString() => "ContinueNode()";
}

class ReturnNode extends ASTNode {
  final ASTNode? value;

  ReturnNode(this.value);

  @override
  String toString() => "ReturnNode()";
}

class Arg {
  final String name;
  final KebabType type;

  Arg(this.name, this.type);
}

class FuncDefNode extends ASTNode {
  final String name;
  final List<Arg> args;
  final ASTNode block;
  final KebabType? returnType;

  FuncDefNode(this.name, this.args, this.block, this.returnType);

  @override
  String toString() =>
      "FuncDefNode(name: $name, args: $args, block: $block, returnType: $returnType)";
}
