mod core;
extern crate regex;

use core::lexer::lexer::lex;
use core::llvm::context::context_maker::{Context, Dependencies};
use core::llvm::llvm_ir::generator::IrGenerator;
use core::parser::parser::Parser;
use core::semantic::semantic::SemanticAnalyser;

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

    let ast = match Parser::new(tokens).parse() {
        Ok(ast) => {
            if debug {
                println!("{:#?}", ast);
            };
            ast
        }
        Err(e) => {
            eprintln!("{}", e);
            std::process::exit(1);
        }
    };

    let mut semantic_analyser = SemanticAnalyser::new();
    match semantic_analyser.analyse(ast.clone()) {
        Ok(_) => (),
        Err(e) => {
            eprintln!("{}", e);
            std::process::exit(1);
        }
    }
    let mut context_maker = Context::new();
    let ir = context_maker.translate_ast(ast);

    let mut ir_generator = IrGenerator::new(vec![ir], context_maker.dependencies.clone());
    let ir = ir_generator.gen_ir();
}
