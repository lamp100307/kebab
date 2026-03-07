abstract class ASTNode {}

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
