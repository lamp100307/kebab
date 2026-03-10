import 'ast_node.dart';

class Compiler {
  final List<ASTNode> nodes;
  String code = "";
  Map<String, String> vars = {};

  Compiler(this.nodes);

  String compile() {
    code += "int main() {\n";
    for (var node in nodes) {
      _compileNode(node);
    }
    code += "return 0;\n}\n";
    return code;
  }

  void _compileNode(final ASTNode node, [final bool noSemicolon = false]) {
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
            _compilePrint(args);
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
          vars[name] = _typeFromNode(value!); // ! unreachable
        } else {
          vars[name] = type.toCType();
          code += "${type.toCType()} $name";
        }
        if (value != null) {
          code += " = ";
          _compileNode(value);
        }
        code += noSemicolon ? "\n" : ";\n";
        break;
      case VarAssignNode(name: final name, value: final value):
        code += "$name = ";
        _compileNode(value);
        code += noSemicolon ? "\n" : ";\n";
        break;
      case IfNode(
        condition: final condition,
        thenBlock: final thenBlock,
        elifs: final elifs,
        elseBlock: final elseBlock,
      ):
        code += "if (";
        _compileNode(condition);
        code += ")";

        _compileNode(thenBlock);

        for (var elif in elifs) {
          code += " else if (";
          _compileNode(elif.condition);
          code += ")";
          _compileNode(elif.block);
        }

        if (elseBlock != null) {
          code += " else ";
          _compileNode(elseBlock);
        }
        break;

      case ElifNode(condition: final condition, block: final block):
        code += " else if (";
        _compileNode(condition);
        code += ")";
        _compileNode(block);
        break;

      case BlockNode(statements: final statements):
        code += "{\n";
        for (var statement in statements) {
          _compileNode(statement);
        }
        code += "}\n";
        break;
      case ForNode(
        init: final init,
        condition: final condition,
        update: final update,
        block: final block,
      ):
        code += "for (";
        if (init != null) {
          _compileNode(init, true);
        }
        code += "; ";
        _compileNode(condition, true);
        code += "; ";
        if (update != null) {
          _compileNode(update, true);
        }
        code += ")";
        _compileNode(block);
        break;
      case BreakNode():
        code += "break";
        code += noSemicolon ? "" : ";";
        break;
      case ContinueNode():
        code += "continue";
        code += noSemicolon ? "" : ";";
        break;
      case WhileNode(condition: final condition, block: final block):
        code += "while (";
        _compileNode(condition, true);
        code += ")";
        if (block is BlockNode) {
          _compileNode(block);
        } else {
          code += "{\n";
          _compileNode(block);
          code += "}\n";
        }
        break;
      default:
        break;
    }
  }

  void _compilePrint(final List<ASTNode> args) {
    String fmt = "\"";
    for (var arg in args) {
      switch (arg) {
        case IntNode(value: final v):
          if (v >= 0 && v <= 65_535) {
            fmt += "%hu"; // uint16_t / unsigned short
          } else if (v >= -32_768 && v <= 32_767) {
            fmt += "%hd"; // int16_t / short (исправлено: %h → %hd)
          } else if (v >= 0 && v <= 4_294_967_295) {
            fmt += "%u"; // uint32_t / unsigned int
          } else if (v >= -2_147_483_648 && v <= 2_147_483_647) {
            fmt += "%d"; // int32_t / int
          } else if (BigInt.from(v) >= BigInt.zero &&
              BigInt.from(v) <= BigInt.parse('0xFFFFFFFFFFFFFFFF')) {
            fmt += "%llu"; // uint64_t / unsigned long long
          } else if (v >= -9_223_372_036_854_775_808 &&
              v <= 9_223_372_036_854_775_807) {
            fmt += "%lld"; // int64_t / long long
          }
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
          fmt += _getFmt(type);
          break;
        default:
          break;
      }
    }
    fmt += "\"";
    code += "printf($fmt, ";
    for (int i = 0; i < args.length; i++) {
      _compileNode(args[i]);
      if (!(i == args.length - 1)) code += ", ";
    }
    code += ");\n";
  }

  void addDependencies() {
    for (final n in nodes) {
      _analyseDependency(n);
    }
  }

  void _analyseDependency(final ASTNode node) {
    switch (node) {
      case FuncCallNode(name: final name, args: final args):
        for (final arg in args) {
          _analyseDependency(arg);
        }
        switch (name) {
          case "print":
            code += "#include <stdio.h>\n";
            break;
          default:
            break;
        }
      case VarDeclNode(type: final type):
        switch (type) {
          case NumType():
            code += "#include <stdint.h>\n";
            break;
          case Str():
            code += "#include <string.h>";
            break;
          default:
            break;
        }

      case IfNode(
        condition: final condition,
        thenBlock: final thenBlock,
        elifs: final elifs,
        elseBlock: final elseBlock,
      ):
        _analyseDependency(condition);
        _analyseDependency(thenBlock);
        for (final elif in elifs) {
          _analyseDependency(elif);
        }
        if (elseBlock != null) {
          _analyseDependency(elseBlock);
        }
        break;
      case ForNode(
        init: final init,
        condition: final condition,
        update: final update,
        block: final block,
      ):
        if (init != null) {
          _analyseDependency(init);
        }
        _analyseDependency(condition);
        if (update != null) {
          _analyseDependency(update);
        }
        _analyseDependency(block);
        break;
      default:
        break;
    }
  }

  String _typeFromNode(final ASTNode node) {
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

  String _getFmt(final String type) {
    switch (type) {
      case "int8_t":
      case "int16_t":
      case "int32_t":
      case "uint8_t":
      case "uint16_t":
      case "uint32_t":
      case "bool":
        return "%d";
      case "int64_t":
        return "%lld";
      case "uint64_t":
        return "%llu";
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
