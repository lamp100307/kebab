import 'dart:io' show File, Process;

import 'package:kebab/config.dart';
import 'package:kebab/core/core.dart';
import 'package:kebab/exceptions/exceptions.dart';
import 'commands.dart';

final class CommandBuild implements ICommand {
  @override
  final Config config;
  final File intermediateFile;

  CommandBuild(this.config)
    : intermediateFile = File('${config.outputFile.path}.cpp');

  void _debugPrint(final Object item) {
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

  List<Token> _getTokens(final String code) {
    final lexer = Lexer(code);
    final tokens = lexer.tokenize();
    _debugPrint(tokens);
    return tokens;
  }

  List<ASTNode> _getNodes(final List<Token> tokens) {
    final Parser parser = Parser(tokens);
    final List<ASTNode> nodes = parser.parse();
    _debugPrint(nodes);
    return nodes;
  }

  String _getReadyCode(final List<ASTNode> nodes) {
    final Compiler compiler = Compiler(nodes);
    compiler.addDependencies();
    final output = compiler.compile();
    _debugPrint(output);
    return output;
  }

  void _compile() {
    final compileResult = Process.runSync('g++', [
      intermediateFile.path,
      '-o',
      config.outputFile.path,
    ]);

    if (compileResult.exitCode != 0) {
      print('Compilation failed:\n${compileResult.stderr}');
    }

    if (!config.debug) {
      intermediateFile.deleteSync();
    }
  }

  void _analyseAndTrowsExceptions(final List<ASTNode> nodes) {
    final SemanticAnalyser analyser = SemanticAnalyser(nodes);
    analyser.analyse();
    if (analyser.errors.isNotEmpty) {
      throw SemanticMultipleExceptions(analyser.errors);
    }
  }

  @override
  void execute() {
    var code = config.inputFile.readAsStringSync();

    code = Preprocessor(code).preprocess();
    final tokens = _getTokens(code);
    final nodes = _getNodes(tokens);
    _analyseAndTrowsExceptions(nodes);
    final output = _getReadyCode(nodes);

    intermediateFile.createSync(recursive: true);
    intermediateFile.writeAsStringSync(output);

    _compile();
  }
}
