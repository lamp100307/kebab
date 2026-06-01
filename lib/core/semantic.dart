import '../exceptions/exceptions.dart';
import 'ast_nodes.dart';
import 'var.dart';

class SemanticAnalyser {
  final ASTNode nodes;
  final List<SemanticException> errors = [];
  final Map<String, Var> vars = {};

  SemanticAnalyser(this.nodes);

  void addVar(final Var var_, final Scope scope) {
    vars.addEntries({var_.name: var_}.entries);
    scope.add(var_);
  }

  void analyse() {
    final Scope globalScope = Scope(null);
    _analyseNode(nodes, globalScope);
  }

  void _analyseNode(final ASTNode node, final Scope scope) {
    switch (node) {
      case ProgramNode(statements: final stmts):
        for (final s in stmts) {
          _analyseNode(s, scope);
        }
      case IntNode() || StringNode() || BoolNode() || BreakNode() || ContinueNode():
        return;
      case BOPNode(left: final left, right: final right):
        _analyseNode(left, scope);
        _analyseNode(right, scope);
        getNodeType(node, scope);
      case VarDeclNode(name: final name, type: final type, value: final value):
        if (scope.getWithoutMaster(name) != null) {
          errors.add(SemanticVarAlreadyDefinedException(name));
        }
        if (type != null && type != getNodeType(value, scope)) {
          errors.add(
            SemanticTypeMismatchException(type, getNodeType(value, scope)),
          );
        }
        final type_ = type ?? getNodeType(value, scope);
        addVar(Var(name, type_), scope);
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
        final scope_ = Scope(scope);
        for (final statement in statements) {
          _analyseNode(statement, scope_);
        }
      case IfNode(
        condition: final condition,
        thenBlock: final thenBlock,
        elseBlock: final elseBlock,
      ):
        if (getNodeType(condition, scope) != KebabType.bool) {
          errors.add(
            SemanticTypeMismatchException(
              KebabType.bool,
              getNodeType(condition, scope),
            ),
          );
        }
        _analyseNode(condition, scope);
        _analyseNode(thenBlock, scope);
        if (elseBlock != null) {
          _analyseNode(elseBlock, scope);
        }
        return;
      case ForNode(
        init: final init,
        cond: final cond,
        step: final step,
        block: final block,
      ):
        if (getNodeType(cond, scope) != KebabType.bool) {
          errors.add(
            SemanticTypeMismatchException(
              KebabType.bool,
              getNodeType(cond, scope),
            ),
          );
        }
        if (init != null) {
          _analyseNode(init, scope);
        }
        _analyseNode(cond, scope);
        if (step != null) {
          _analyseNode(step, scope);
        }
        _analyseNode(block, scope);
        return;
      case WhileNode(condition: final condition, block: final block):
        if (getNodeType(condition, scope) != KebabType.bool) {
          errors.add(
            SemanticTypeMismatchException(
              KebabType.bool,
              getNodeType(condition, scope),
            ),
          );
        }
        _analyseNode(condition, scope);
        _analyseNode(block, scope);
        return;
      case LoopNode(block: final block):
        _analyseNode(block, scope);
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
      case BoolNode():
        return KebabType.bool;
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
