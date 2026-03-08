import 'ast_node.dart';

class Compiler {
  List<ASTNode> nodes = [];
  String code = "";
  Map<String, String> vars = {};

  Compiler(this.nodes);

  String compile() {
    code += "int main() {\n";
    for (var node in nodes) {
      compileNode(node);
    }
    code += "return 0;\n}\n";
    return code;
  }

  void compileNode(ASTNode node) {
    switch (node) {
      case OpNode(left: final left, op: final op, right: final right):
        code += "$left $op $right";
        break;
      case IntNode(value: final value):
        code += "$value";
        break;
      case StrNode(value: final value):
        code += "\"$value\"";
        break;
      case FuncCallNode(name: final name, args: final args):
        switch (name) {
          case "print":
            compilePrint(args);
        }
        break;
      case VarRefNode(name: final name):
        vars.containsKey(name)
            ? code += name
            : throw Exception("Variable not declared $name");
        break;

      case VarDeclNode(name: final name, type: final type, value: final value):
        if (value == null && type == null) {
          throw Exception("Variable $name must have a type or a value");
        }
        if (type == null) {
          code += "auto $name";
          vars[name] = typeFromNode(value!); // ! unreachable
        } else {
          vars[name] = type.toCType();
          code += "${type.toCType()} $name";
        }
        if (value != null) {
          code += " = ";
          compileNode(value);
        }
        code += ";\n";
        break;
      case VarAssignNode(name: final name, value: final value):
        code += "$name = ";
        compileNode(value);
        code += ";\n";
        break;
      default:
        break;
    }
  }

  void compilePrint(List<ASTNode> args) {
    String fmt = "\"";
    for (var arg in args) {
      switch (arg) {
        case IntNode():
          fmt += "%d";
          break;
        case StrNode():
          fmt += "%s";
          break;
        case OpNode():
          fmt += "%d";
          break;
        case VarRefNode(name: final name):
          final type = vars.containsKey(name)
              ? vars[name]!
              : throw Exception("Variable not declared $name");
          fmt += getFmt(type);
          break;
        default:
          break;
      }
    }
    fmt += "\"";
    code += "printf($fmt, ";
    for (int i = 0; i < args.length; i++) {
      compileNode(args[i]);
      if (!(i == args.length - 1)) code += ", ";
    }
    code += ");\n";
  }

  void addDependencies() {
    for (var n in nodes) {
      if (n is FuncCallNode) {
        switch (n.name) {
          case "print":
            code += "#include <stdio.h>\n";
            break;
          default:
            break;
        }
      } else if (n is VarDeclNode) {
        switch (n.type) {
          case NumType():
            code += "#include <stdint.h>\n";
            break;
          case Str():
            code += "#include <string.h>";
            break;
          default:
            break;
        }
      }
    }
  }

  String typeFromNode(ASTNode node) {
    switch (node) {
      case IntNode():
        return "int32_t";
      case StrNode():
        return "string";
      case OpNode():
        return "int32_t";
      case VarRefNode(name: final name):
        if (vars.containsKey(name)) {
          return vars[name]!;
        } else {
          throw Exception("Variable not declared $name");
        }
      default:
        throw Exception("Unknown type");
    }
  }

  String getFmt(String type) {
    switch (type) {
      case "int8_t":
      case "int16_t":
      case "int32_t":
      case "int64_t":
      case "uint8_t":
      case "uint16_t":
      case "uint32_t":
      case "uint64_t":
      case "bool":
        return "%d";
      case "char":
        return "%c";
      case "float":
        return "%f";
      case "double":
        return "%lf";
      case "string":
        return "%s";

      default:
        throw Exception("Unknown type $type");
    }
  }
}
