part of 'exceptions.dart';

sealed class SemanticException extends KebabException {
  const SemanticException([super.location]);
}

final class SemanticMultipleExceptions extends SemanticException {
  final List<SemanticException> exceptions;

  @override
  String get message =>
      "Semantic exceptions:\n${exceptions.map((final e) => e.toString()).join('\n')}";
  @override
  String toString() => message;

  const SemanticMultipleExceptions(this.exceptions);
}

final class SemanticIncompatibleException extends SemanticException {
  final KebabType type1;
  final KebabType type2;

  @override
  String get message => 'Incompatible types: $type1 and $type2';

  const SemanticIncompatibleException(this.type1, this.type2, [super.location]);
}

final class SemanticUnknownNodeType extends SemanticException {
  final String nodeType;

  @override
  String get message => 'Unknown node type: $nodeType';

  const SemanticUnknownNodeType(this.nodeType, [super.location]);
}

enum Side { left, right }

final class SemanticOpUnexpexctedTypeException extends SemanticException {
  final KebabType type;
  final String op;
  final Side side;

  @override
  String get message =>
      '${side == Side.left ? 'Left' : 'Right'} operand of $op must be numeric, got $type';

  const SemanticOpUnexpexctedTypeException(
    this.type,
    this.op,
    this.side, [
    super.location,
  ]);
}

final class SemanticTypeMismatchException extends SemanticException {
  final KebabType type1;
  final KebabType type2;

  @override
  String get message => 'Type mismatch: $type1 and $type2';

  const SemanticTypeMismatchException(this.type1, this.type2, [super.location]);
}

final class SemanticVarInitException extends SemanticException {
  @override
  final String message;

  const SemanticVarInitException(this.message, [super.location]);
}

// Defind
sealed class SemanticVarDefinedException extends SemanticException {
  final String varName;

  const SemanticVarDefinedException(this.varName, [super.location]);
}

final class SemanticVarNotDefinedException extends SemanticVarDefinedException {
  @override
  String get message => 'Variable "$varName" not declared';

  const SemanticVarNotDefinedException(super.varName, [super.location]);
}

final class SemanticVarAlreadyDefinedException
    extends SemanticVarDefinedException {
  @override
  String get message => 'Variable "$varName" already declared';

  const SemanticVarAlreadyDefinedException(super.varName, [super.location]);
}

final class SemanticUnimplementedException extends SemanticException {
  const SemanticUnimplementedException([super.location]);

  @override
  String get message => 'Unimplemented';
}