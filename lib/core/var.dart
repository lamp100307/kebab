import 'ast_nodes.dart' show KebabType;

class Var {
  final String name;
  final KebabType type;

  Var(this.name, this.type);

  @override
  String toString() => "Var(name: $name, type: $type)";
}

class Scope {
  final List<Var> vars = [];
  final Scope? master;

  Scope(this.master);

  void add(final Var var_) {
    vars.add(var_);
  }

  Var? get(final String name) {
    for (final Var var_ in vars) {
      if (var_.name == name) {
        return var_;
      }
    }
    return master?.get(name);
  }

  Var? getWithoutMaster(final String name) {
    for (final Var var_ in vars) {
      if (var_.name == name) {
        return var_;
      }
    }
    return null;
  }
}
