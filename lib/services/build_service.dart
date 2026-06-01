import 'dart:io' show Directory, File, Process, Platform;

import 'package:path/path.dart' as p;

import '../build_config.dart';
import '../config.dart';
import '../core/core.dart';
import '../exceptions/exceptions.dart';
import 'services.dart';
import 'debug_print.dart';

final class BuildService with DebugPrint implements BaseService {
  @override
  final Config config;
  late final BuildConfig _buildConfig;

  BuildService(this.config);

  late final File _intermediateFile;

  List<Token> _getTokens(final String code) {
    final lexer = Lexer(code);
    final tokens = lexer.tokenize();
    debugPrint(tokens);
    return tokens;
  }

  ASTNode _getNodes(final List<Token> tokens) {
    final Parser parser = Parser(tokens);
    final ASTNode nodes = parser.parse();
    debugPrint(nodes);
    return nodes;
  }

  String _getReadyCode(final ASTNode nodes, final Map<String, Var> vars) {
    final LLVMGenerator compiler = LLVMGenerator();
    final output = compiler.generateIr(nodes, vars).trim();
    debugPrint(output);
    return output;
  }

  void _compile() {
    final exePath = Platform.resolvedExecutable;
    final exeDir = p.dirname(exePath);
    final compileResult = Process.runSync('clang', [
      _intermediateFile.path,
      p.join(exeDir, 'runtime/runtime.o'),
      '-O${_buildConfig.mode.optimisationLevel}',
      '-o',
      _buildConfig.output.path,
    ]);

    if (compileResult.exitCode != 0) {
      print('Compilation failed:\n${compileResult.stderr}');
    }
  }

  Map<String, Var> _analyseAndTrowsExceptions(final ASTNode nodes) {
    final SemanticAnalyser analyser = SemanticAnalyser(nodes);
    analyser.analyse();
    if (analyser.errors.isNotEmpty) {
      throw SemanticMultipleExceptions(analyser.errors);
    }
    debugPrint(analyser.vars);
    return analyser.vars;
  }

  @override
  void execute(final BuildConfig buildConfig) {
    _buildConfig = buildConfig;
    _intermediateFile = File('${buildConfig.output.path}.ll');

    debugPrint(
      'Building ${buildConfig.target.path} to ${buildConfig.output.path}',
    );

    final code = buildConfig.target.readAsStringSync();

    final tokens = _getTokens(code);
    final nodes = _getNodes(tokens);
    final vars = _analyseAndTrowsExceptions(nodes);
    final output = _getReadyCode(nodes, vars);

    _intermediateFile.createSync(recursive: true);
    _intermediateFile.writeAsStringSync(output);

    _compile();

    if (!config.debug) _intermediateFile.deleteSync();
  }
}
