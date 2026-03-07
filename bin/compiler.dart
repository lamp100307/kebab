import 'package:kebab/ast_node.dart';

class Compiler {
  List<ASTNode> nodes = [];
  String code = "";

  Compiler(this.nodes);

  String compile() {
    code += "int main() {\n";
    for (var node in nodes) {
      compile_node(node);
    }
    code += "return 0;\n}\n";
    return code;
  }

  void compile_node(ASTNode node) {
    switch (node) {
        case OpNode(left: final left, op: final op, right: final right):
          code += "$left $op $right";
          break;
        case IntNode(value: final value):
          code += "$value";
          break;
        case FuncCallNode(name: final name, args: final args):
          switch (name) {
            case "print": compile_print(args);
          }
        default:
          break;
      }
  }

  void compile_print(List<ASTNode> args) {
    String fmt = "\"";
    for (var arg in args) {
      switch (arg) {
        case IntNode():
          fmt += "%d";
          break;
        case OpNode():
          fmt += "%d";
          break;
        default:
          break;
      }
    }
    fmt += "\"";
    code += "printf($fmt, ";
    for (int i = 0; i < args.length; i++) {
      compile_node(args[i]);
      if (!(i == args.length - 1)) code += ", ";
    }
    code += ");\n";
  }


  void add_dependencies() {
    for (var n in nodes) {
      if (n is FuncCallNode) {
        switch (n.name) {
          case "print":
            code += "#include <stdio.h>\n";
            break;
          default:
            break;
        }
      }
    }
  }
}
