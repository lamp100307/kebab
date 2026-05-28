import 'dart:io' show File, Process;

import 'package:kebab/config.dart';
import 'package:kebab/core/core.dart';
import 'package:kebab/exceptions/exceptions.dart';
import 'commands.dart';

final class CommandBuild extends KebabCommand {
  @override
  final String name = 'build';
  @override
  final String description = 'Build the project';

  late final File intermediateFile;

  CommandBuild() : super(CommandType.build) {
    argParser
      ..addOption('input', abbr: 'i', help: 'Input file path')
      ..addOption('output', abbr: 'o', help: 'Output file path')
      ..addFlag('release', abbr: 'r', help: 'Build in release mode');
  }

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
    final compileResult = Process.runSync('tcc', [
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

  void build(final Config config) {
    _debugPrint(
      'Building ${config.inputFile.path} to ${config.outputFile.path}',
    );

    final code = config.inputFile.readAsStringSync();
    intermediateFile = File('${config.outputFile.path}.c');

    final tokens = _getTokens(code);
    final nodes = _getNodes(tokens);
    _analyseAndTrowsExceptions(nodes);
    final output = _getReadyCode(nodes);

    intermediateFile.createSync(recursive: true);
    intermediateFile.writeAsStringSync(output);

    _compile();
  }

  // It need to we can call [build] with a custom config
  @override
  void run() => build(config);
}
