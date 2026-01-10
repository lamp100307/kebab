mod core;

use std::fs::{read_to_string, remove_file, write};
use std::process::{Command, exit};

use core::lexer::lexer::lex;
use core::llvm::llvm_ir::generator::LlvmIrGenerator;
use core::llvm::middle_ir::mir_maker::{get_dependencies, make_middle_ir};
use core::parser::parser::Parser;
use core::semantic::semantic::SemanticAnalyser;
use core::utils::clang_installer::resolve_clang;

fn main() {
    match resolve_clang() {
        Ok(_) => {}
        Err(e) => {
            eprintln!("Failed to download the portable Clang: {}", e);
            exit(1);
        }
    }

    let args: Vec<String> = std::env::args().collect();
    if args.len() < 2 {
        eprintln!("Expected at least one argument");
        eprintln!("Usage: {} <filename> [debug]", args[0]);
        return;
    }

    let file = &args[1];
    let debug = args.get(2).map(|arg| arg == "debug").unwrap_or(false);

    let contents = read_to_string(file).expect("Something went wrong when reading the file");

    let tokens = match lex(&contents) {
        Ok(tokens) => {
            if debug {
                println!("Tokens: {:#?}", tokens);
            }
            tokens
        }
        Err(e) => {
            eprintln!("{}", e);
            exit(1);
        }
    };

    let mut parser = Parser::new(tokens);
    let mut ast = match parser.parse() {
        Ok(ast) => {
            if debug {
                println!("AST: {:#?}", ast);
            }
            ast
        }
        Err(e) => {
            eprintln!("{}", e);
            exit(1);
        }
    };

    ast.optimize();

    if debug {
        println!("Optimized AST: {:#?}", ast);
    }

    let mut semantic = SemanticAnalyser::new();

    match semantic.analyse(&ast) {
        Ok(()) => (),
        Err(e) => {
            eprintln!("{}", e);
            exit(1);
        }
    }

    let dependencies = get_dependencies(&ast);
    let mir = make_middle_ir(ast);

    if debug {
        println!("Middle IR: {:#?}", mir);
    }

    let mut generator = LlvmIrGenerator::new();
    let llvm_ir = generator.generate_llvm_ir(mir, dependencies);

    if debug {
        println!("LLVM IR: \n{}", llvm_ir);
    }

    let llvm_file = format!("{}.ll", file);
    write(&llvm_file, llvm_ir.clone()).unwrap();

    let output_file = format!("{}.exe", file);

    //compiling and running
    let output = Command::new("clang")
        .arg(&llvm_file)
        .arg("-O3")
        .arg("-o")
        .arg(output_file.clone())
        .output()
        .expect("failed to execute process");

    if !output.stdout.is_empty() {
        println!("clang output:\n{}", String::from_utf8_lossy(&output.stdout));
    }

    if !output.stderr.is_empty() {
        eprintln!("clang errors:\n{}", String::from_utf8_lossy(&output.stderr));
    }

    if !output.status.success() {
        eprintln!("clang failed with exit code: {:?}", output.status.code());
    }

    let output = Command::new(output_file)
        .output()
        .expect("failed to execute process");

    if !output.stdout.is_empty() {
        println!("{}", String::from_utf8_lossy(&output.stdout));
    }

    remove_file(llvm_file).unwrap();
}
