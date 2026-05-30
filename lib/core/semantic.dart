import '../exceptions/exceptions.dart';
import 'ast_nodes.dart';
import 'var.dart';

class SemanticAnalyser {
  final ASTNode nodes;
  final List<SemanticException> errors = [];

  SemanticAnalyser(this.nodes);

  void analyse() {
    final Scope globalScope = Scope();
    switch (nodes) {
      case ProgramNode(statements: final statements):
        for (final node in statements) {
          analyseNode(node, globalScope);
        }
        return;
      default:
        return;
    }
  }

  void analyseNode(final ASTNode node, final Scope scope) {
    switch (node) {
      case IntNode():
      case BreakNode():
      case ContinueNode():
      case StringNode():
        return;
      case BOPNode(left: final left, right: final right):
        analyseNode(left, scope);
        analyseNode(right, scope);
        getNodeType(node, scope);
      case VarDeclNode(name: final name, type: final type, value: final value):
        if (scope.get(name) != null) {
          errors.add(SemanticVarAlreadyDefinedException(name));
        }
        if (type != null && type != getNodeType(value, scope)) {
          errors.add(
            SemanticTypeMismatchException(type, getNodeType(value, scope)),
          );
        }
        final type_ = type ?? getNodeType(value, scope);
        scope.add(Var(name, type_));
        return;
      case VarAssignNode(name: final name, value: final value):
        if (scope.get(name) == null) {
          errors.add(SemanticVarNotDefinedException(name));
        } else if (getNodeType(value, scope) != scope.get(name)!.type) {
          errors.add(
            SemanticTypeMismatchException(
              scope.get(name)!.type,
              getNodeType(value, scope),
            ),
          );
        }
        return;
      case VarRefNode(name: final name):
        if (scope.get(name) == null) {
          errors.add(SemanticVarNotDefinedException(name));
        }
        return;
      case CallNode(name: final name):
        if (name != 'print') {
          errors.add(SemanticUnimplementedException());
        }
      case BlockNode(statements: final statements):
        for (final statement in statements) {
          analyseNode(statement, scope);
        }
      case IfNode(
        condition: final condition,
        thenBlock: final thenBlock,
        elseBlock: final elseBlock,
      ):
        analyseNode(condition, scope);
        analyseNode(thenBlock, scope);
        if (elseBlock != null) {
          analyseNode(elseBlock, scope);
        }
        if (getNodeType(condition, scope) != KebabType.bool) {
          errors.add(
            SemanticTypeMismatchException(
              KebabType.bool,
              getNodeType(condition, scope),
            ),
          );
        }
        return;
      case ForNode(
        init: final init,
        cond: final cond,
        step: final step,
        block: final block,
      ):
        if (init != null) {
          analyseNode(init, scope);
        }
        analyseNode(cond, scope);
        if (step != null) {
          analyseNode(step, scope);
        }
        analyseNode(block, scope);
        if (getNodeType(cond, scope) != KebabType.bool) {
          errors.add(
            SemanticTypeMismatchException(
              KebabType.bool,
              getNodeType(cond, scope),
            ),
          );
        }
        return;
      case WhileNode(condition: final condition, block: final block):
        analyseNode(condition, scope);
        analyseNode(block, scope);
        if (getNodeType(condition, scope) != KebabType.bool) {
          errors.add(
            SemanticTypeMismatchException(
              KebabType.bool,
              getNodeType(condition, scope),
            ),
          );
        }
        return;
      case LoopNode(block: final block):
        analyseNode(block, scope);
        return;
      case _:
        return;
    }
  }

  KebabType getNodeType(final ASTNode node, final Scope scope) {
    switch (node) {
      case IntNode():
        return KebabType.int;
      case StringNode():
        return KebabType.string;
      case BOPNode(left: final left, op: final op, right: final right):
        if (['>', '>=', '<', '<=', '==', '!='].contains(op)) {
          return KebabType.bool;
        }
        return typeFromTwo(getNodeType(left, scope), getNodeType(right, scope));
      case VarDeclNode():
        return KebabType.none;
      case VarAssignNode():
        return KebabType.none;
      case VarRefNode(name: final name):
        return scope.get(name)!.type;
      case CallNode():
        return KebabType.none; // TODO
      default:
        return KebabType.none;
    }
  }

  KebabType typeFromTwo(final KebabType first, final KebabType second) {
    switch ((first, second)) {
      case (KebabType.int, KebabType.int):
        return KebabType.int;
      case (KebabType.string, KebabType.string):
        return KebabType.string;
      default:
        errors.add(SemanticIncompatibleException(first, second));
        return KebabType.none;
    }
  }
}
