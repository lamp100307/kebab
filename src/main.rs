mod core;

use std::fs::{File, read_to_string, remove_file, write};
use std::process::{Command, exit};

use reqwest::blocking;
use which::which;

use core::lexer::lexer::lex;
use core::llvm::llvm_ir::generator::LlvmIrGenerator;
use core::llvm::middle_ir::mir_maker::{get_dependencies, make_middle_ir};
use core::parser::parser::Parser;
use core::semantic::semantic::SemanticAnalyser;

fn download_portable_clang() -> Result<(), Box<dyn std::error::Error>> {
    println!("📦 Downloading Clang...");

    let url = "https://github.com/lamp100307/KebabBack/releases/download/clang/clang.exe";
    let file_path = "clang.exe";

    let mut response = blocking::get(url)?;
    let mut file = File::create(file_path)?;
    std::io::copy(&mut response, &mut file)?;

    println!("✅ Portable Clang ready!");
    Ok(())
}

fn main() {
    if !which("clang").is_ok() || which("clang.exe").is_ok() {
        match download_portable_clang() {
            Ok(_) => (),
            Err(e) => {
                eprintln!("Failed to download portable Clang: {}", e);
                exit(1);
            }
        }
    }

    // work with args
    let args: Vec<String> = std::env::args().collect();
    if args.len() < 2 {
        eprintln!("Expected at least one argument");
        eprintln!("Usage: {} <filename> [debug]", args[0]);
        return;
    }

    let file = &args[1];
    let debug = args.get(2).map(|arg| arg == "debug").unwrap_or(false);

    // read file
    let contents = read_to_string(file).expect("Something went wrong reading the file");

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

    // create AST
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

    // semantic analysis
    let mut semantic = SemanticAnalyser::new();

    match semantic.analyse(&ast) {
        Ok(()) => (),
        Err(e) => {
            eprintln!("{}", e);
            exit(1);
        }
    }

    // MIR
    let dependencies = get_dependencies(&ast);
    let mir = make_middle_ir(ast);

    if debug {
        println!("Middle IR: {:#?}", mir);
    }

    // IR
    let mut generator = LlvmIrGenerator::new();
    let llvm_ir = generator.generate_llvm_intermediate_representation(mir, dependencies);

    if debug {
        println!("LLVM IR: \n{}", llvm_ir);
    }

    // create the temp file with ir code
    let llvm_file = format!("{}.ll", file);
    write(&llvm_file, llvm_ir.clone()).unwrap();

    // write to the final file
    let output_file = format!("{}.exe", file);

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

    // remove temp file
    remove_file(llvm_file).unwrap();
}
