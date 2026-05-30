import 'ast_nodes.dart' show KebabType;

class Var {
  final String name;
  final KebabType type;

  Var(this.name, this.type);
}

class Scope {
  final List<Var> vars = [];

  void add(final Var var_) {
    vars.add(var_);
  }

  Var? get(final String name) {
    for (final Var var_ in vars) {
      if (var_.name == name) {
        return var_;
      }
    }
    return null;
  }
}
