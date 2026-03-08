import 'dart:io' show File, Process;

import 'package:kebab/config.dart';
import 'package:kebab/core/core.dart';
import 'commands.dart';

final class CommandBuild implements Command {
  @override
  final Config config;
  final File intermediateFile;

  CommandBuild(this.config)
    : intermediateFile = File('${config.outputFile.path}.inter');

  void _debugPrint(Object item) {
    if (config.debug) {
      if (item is Iterable) {
        for (var it in item) {
          print(it.toString());
        }
      } else {
        print(item.toString());
      }
    }
  }

  List<Token> _getTokens(String code) {
    final lexer = Lexer(code);
    final tokens = lexer.tokenize();
    _debugPrint(tokens);
    return tokens;
  }

  List<ASTNode> _getNodes(List<Token> tokens) {
    final Parser parser = Parser(tokens);
    final List<ASTNode> nodes = parser.parse();
    _debugPrint(nodes);
    return nodes;
  }

  String _getReadyCode(List<ASTNode> nodes) {
    final Compiler compiler = Compiler(nodes);
    compiler.addDependencies();
    final output = compiler.compile();
    _debugPrint(output);
    return output;
  }

  void _compile() {
    final compileResult = Process.runSync('tcc', [
      intermediateFile.toString(),
      '-o',
      config.outputFile.toString(),
    ]);

    if (compileResult.exitCode != 0) {
      print('❌ Compilation failed:\n${compileResult.stderr}');
    }

    intermediateFile.deleteSync();
  }

  @override
  void execute() {
    final code = config.inputFile.readAsStringSync();

    final tokens = _getTokens(code);
    final nodes = _getNodes(tokens);
    SemanticAnalyser(nodes).analyse();
    final output = _getReadyCode(nodes);

    intermediateFile.writeAsStringSync(output);

    _compile();
  }
}
