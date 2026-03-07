import 'dart:io';

import './lexer.dart';
import 'package:kebab/token.dart';

import './parser.dart';
import 'package:kebab/ast_node.dart';

import './compiler.dart';

void main(List<String> arguments) {
  final code = File(arguments[0]).readAsStringSync();
  final debug = arguments.length > 1 && arguments[1] == 'debug';
  final List<Token> tokens = Lexer.tokenize(code);
  if (debug) for (var token in tokens) {print(token.toString());}
  final Parser parser = Parser(tokens);
  final List<ASTNode> nodes = parser.parse();
  if (debug) for (var node in nodes) {print(node.toString());}
  final Compiler compiler = Compiler(nodes);
  compiler.add_dependencies();
  final output = compiler.compile();

  if (debug) print(output);

  //save to file
  final outputPath = "${arguments[0].split('.').first}.c";
  File(outputPath).writeAsStringSync(output);

  //compile and run
  final execPath = '${arguments[0].split('.').first}.c';
  final compileResult = Process.runSync('tcc', [outputPath, '-o', execPath]);
  
  if (compileResult.exitCode != 0) {
    print('❌ Ошибка компиляции:');
    print(compileResult.stderr);
    return;
  }
  
  // 2. Запускаем и ПОЛУЧАЕМ ВЫВОД
  final runResult = Process.runSync('./$execPath', []);
  
  if (runResult.exitCode == 0) {
    print(runResult.stdout);  // ВОТ ТУТ ВЫВОД!
  } else {
    print('❌ Ошибка выполнения:');
    print(runResult.stderr);
  }
}
