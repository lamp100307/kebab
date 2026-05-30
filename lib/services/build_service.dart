import 'dart:io' show File, Process;

import '../build_config.dart';
import '../config.dart';
import '../core/core.dart';
import '../exceptions/exceptions.dart';
import 'services.dart';

final class BuildService implements BaseService {
  @override
  final Config config;
  late final BuildConfig _buildConfig;

  BuildService(this.config);

  late final File _intermediateFile;

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

  ASTNode _getNodes(final List<Token> tokens) {
    final Parser parser = Parser(tokens);
    final ASTNode nodes = parser.parse();
    _debugPrint(nodes);
    return nodes;
  }

  String _getReadyCode(final ASTNode nodes) {
    final LLVMGenerator compiler = LLVMGenerator();
    compiler.addDependencies(nodes);
    final output = compiler.generate(nodes).trim();
    _debugPrint(output);
    return output;
  }

  void _compile() {
    final compileResult = Process.runSync('clang', [
      _intermediateFile.path,
      '-O${_buildConfig.mode.optimisationLevel}',
      '-o',
      _buildConfig.output.path,
    ]);

    if (compileResult.exitCode != 0) {
      print('Compilation failed:\n${compileResult.stderr}');
    }
  }

  void _analyseAndTrowsExceptions(final ASTNode nodes) {
    final SemanticAnalyser analyser = SemanticAnalyser(nodes);
    analyser.analyse();
    if (analyser.errors.isNotEmpty) {
      throw SemanticMultipleExceptions(analyser.errors);
    }
  }

  @override
  void execute(final BuildConfig buildConfig) {
    _buildConfig = buildConfig;
    _intermediateFile = File('${buildConfig.output.path}.ll');

    _debugPrint(
      'Building ${buildConfig.target.path} to ${buildConfig.output.path}',
    );

    final code = buildConfig.target.readAsStringSync();

    final tokens = _getTokens(code);
    final nodes = _getNodes(tokens);
    _analyseAndTrowsExceptions(nodes);
    final output = _getReadyCode(nodes);

    _intermediateFile.createSync(recursive: true);
    _intermediateFile.writeAsStringSync(output);

    _compile();

    if (!config.debug) _intermediateFile.deleteSync();
  }
}
