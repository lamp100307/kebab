import 'dart:io' show File, Process;

import 'package:args/args.dart' show ArgResults;

import '../build_config.dart';
import '../config.dart';
import '../core/core.dart';
import '../exceptions/exceptions.dart';
import 'commands.dart';

final class CommandBuild extends Command {
  @override
  final String name = 'build';
  @override
  final String description = 'Build the project';

  late final BuildConfig _buildConfig;
  late final File _intermediateFile;

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

  BuildConfig build(final ArgResults? argResults, final Config config) {
    _buildConfig = BuildConfig.init(argResults, config);
    _intermediateFile = File('${_buildConfig.output.path}.ll');

    _debugPrint(
      'Building ${_buildConfig.target.path} to ${_buildConfig.output.path}',
    );

    final code = _buildConfig.target.readAsStringSync();

    final tokens = _getTokens(code);
    final nodes = _getNodes(tokens);
    _analyseAndTrowsExceptions(nodes);
    final output = _getReadyCode(nodes);

    _intermediateFile.createSync(recursive: true);
    _intermediateFile.writeAsStringSync(output);

    _compile();

    if (!config.debug) _intermediateFile.deleteSync();

    return _buildConfig;
  }

  // It need to we can call [build] with a custom config
  @override
  void run() => build(argResults, config);
}
