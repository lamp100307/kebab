mod core;

use std::ffi::OsStr;
use std::fs::{read_to_string, remove_file, write};
use std::path::PathBuf;
use std::process::{Command, exit};

use core::lexer::lexer::lex;
use core::llvm::llvm_ir::generator::LlvmIrGenerator;
use core::llvm::middle_ir::mir_maker::{get_dependencies, make_middle_ir};
use core::parser::parser::Parser;
use core::semantic::semantic::SemanticAnalyser;
use core::utils::args_parser::{ArgType, get_args};
use core::utils::clang_installer::resolve_clang;
use core::utils::toml_parser::parse_toml;

use crate::core::utils::toml_parser::get_toml_path;

fn main() {
    match resolve_clang() {
        Ok(()) => (),
        Err(e) => {
            eprintln!("Failed to download the portable Clang: {}", e);
            exit(1);
        }
    }

    let args = match get_args() {
        Ok(args) => args,
        Err(e) => {
            eprintln!("Couldn't parse arguments: {}", e);
            exit(1);
        }
    };

    let toml_path = get_toml_path(args.path.as_deref());
    let toml_project = toml_path.and_then(|path| parse_toml(&path).ok());
    let path = args
        .path
        .or_else(|| toml_project.and_then(|p| Some(PathBuf::from(p.entry))))
        .expect("Couldn't get path with code");

    let content = read_to_string(&path).expect("Couldn't read the file content");

    let tokens = lex(&content)
        .map(|tokens| {
            if args.debug {
                println!("Tokens: {:#?}", tokens);
            }
            tokens
        })
        .unwrap_or_else(|e| {
            eprintln!("Couldn't lex the file: {}", e);
            exit(1);
        });

    // TODO: think about how you can do without mut
    let mut parser = Parser::new(tokens);
    let mut ast = match parser.parse() {
        Ok(ast) => {
            if args.debug {
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

    if args.debug {
        println!("Optimized AST: {:#?}", ast);
    }

    // TODO: think about how you can do without mut
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

    if args.debug {
        println!("Middle IR: {:#?}", mir);
    }

    let output_path = args.output.clone().unwrap_or_else(|| {
        let stem = path.file_stem().unwrap_or(OsStr::new("output"));
        let mut output = PathBuf::from(stem);
        output.set_extension("exe");
        output
    });

    // TODO: think about how you can do without mut
    let mut generator = LlvmIrGenerator::new();
    let llvm_ir = generator.generate_llvm_ir(mir, dependencies);

    if args.debug {
        println!("LLVM IR: \n{}", llvm_ir);
    }

    let llvm_path = output_path.with_extension("ll");
    write(&llvm_path, llvm_ir.clone()).unwrap();

    //compiling and running
    let clang_compile_proc = Command::new("clang")
        .arg(&llvm_path)
        .arg("-O3")
        .arg("-o")
        .arg(output_path.clone())
        .output()
        .expect("Failed to execute process");

    if !clang_compile_proc.stdout.is_empty() {
        println!(
            "Clang output:\n{}",
            String::from_utf8_lossy(&clang_compile_proc.stdout)
        );
    }

    if !clang_compile_proc.stderr.is_empty() {
        eprintln!(
            "Clang errors:\n{}",
            String::from_utf8_lossy(&clang_compile_proc.stderr)
        );
    }

    if !clang_compile_proc.status.success() {
        eprintln!(
            "Clang failed with exit code: {:?}",
            clang_compile_proc.status.code()
        );
    }

    remove_file(llvm_path).unwrap();

    if args.command == ArgType::Run {
        let output = Command::new(&output_path)
            .output()
            .expect("Failed to execute process");

        if !output.stdout.is_empty() {
            println!("{}", String::from_utf8_lossy(&output.stdout));
        }
    }
}
