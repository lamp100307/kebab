mod core;

use core::lexer::lexer::lex;
use core::parser::parser::Parser;
use core::semantic::semantic::SemanticAnalyser;
use core::llvm::middle_ir::mir_maker::make_middle_ir;
use core::llvm::llvm_ir::generator::LlvmIrGenerator;

fn main() {
    let args: Vec<String> = std::env::args().collect();
    if args.len() < 2 {
        eprintln!("Expected at least one argument");
        eprintln!("Usage: {} <filename> [debug]", args[0]);
        return;
    }

    let file = &args[1];
    let debug = args.get(2).map(|arg| arg == "debug").unwrap_or(false);

    let contents = std::fs::read_to_string(file).expect("Something went wrong reading the file");

    let tokens = match lex(&contents) {
        Ok(tokens) => {
            if debug {
                println!("{:#?}", tokens);
            }
            tokens
        }
        Err(e) => {
            eprintln!("{}", e);
            std::process::exit(1);
        }
    };

    let mut parser = Parser::new(tokens);
    let mut ast = match parser.parse() {
        Ok(ast) => ast,
        Err(e) => {
            eprintln!("{}", e);
            std::process::exit(1);
        }
    };

    println!("{}", ast);

    ast.optimize();

    println!("{}", ast);

    let mut semantic = SemanticAnalyser::new();

    match semantic.analyse(&ast) {
        Ok(()) => println!("Semantic analysis successful!"),
        Err(e) => {
            eprintln!("{}", e);
            std::process::exit(1);
        }
    }

    let mir = make_middle_ir(ast);

    println!("{:#?}", mir);

    let mut generator = LlvmIrGenerator::new();
    let llvm_ir = generator.generate_llvm_ir(mir);

    println!("{}", llvm_ir);
}
