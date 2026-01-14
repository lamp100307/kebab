use clap::builder::OsStr;

use crate::clang::ClangInstaller;
use crate::core::lexer::lexer::lex;
use crate::core::llvm::llvm_ir::generator::LlvmIrGenerator;
use crate::core::llvm::middle_ir::mir_maker::{get_dependencies, make_middle_ir};
use crate::core::parser::parser::Parser;
use crate::core::semantic::semantic::SemanticAnalyser;
use std::fs::{read_to_string, write};

use crate::commands::Command as CommandTr;
use crate::config::Config;
use anyhow::{Ok, bail};
use std::process::Command;

struct Build;

impl CommandTr for Build {
    fn execute(config: &Config) -> anyhow::Result<()> {
        let entry = config.paths.entry.as_path();
        let is_debug = config.flags.debug;

        let content =
            read_to_string(entry).expect(format!("Failed: read the file: {entry:?}").as_str());

        let tokens = lex(&content)
            .map(|tokens| {
                if is_debug {
                    println!("Tokens: {:#?}", tokens);
                }
                tokens
            })
            .expect("Failed: lex");

        let mut parser = Parser::new(tokens);
        let mut ast = parser
            .parse()
            .inspect(|ast| {
                if is_debug {
                    println!("AST: {ast:#?}");
                }
            })
            .expect("Failed: parse AST");

        ast.optimize();

        if is_debug {
            // TODO: implement logger
            println!("Optimized AST: {ast:#?}");
        }

        let mut semantic = SemanticAnalyser::new();
        semantic.analyse(&ast).expect("Failed: analyse semantic");

        let dependencies = get_dependencies(&ast);
        let mir = make_middle_ir(ast);

        if is_debug {
            println!("Middle IR: {mir:#?}");
        }

        let mut generator = LlvmIrGenerator::new();
        let llvm_ir = generator.generate_llvm_ir(mir, dependencies);

        if is_debug {
            println!("LLVM IR: \n{llvm_ir}",);
        }

        let llvm_path = config
            .paths
            .build_dir
            .join(
                config
                    .paths
                    .output
                    .file_stem()
                    .unwrap_or(&OsStr::from("output")),
            )
            .with_extension("ll");
        write(&llvm_path, llvm_ir.clone()).unwrap();

        // compiling and running
        let clang_path = config.paths.clang.as_path();
        ClangInstaller::new(clang_path).resolve_clang();

        let clang_compile_proc = Command::new(clang_path)
            .arg(&llvm_path)
            .arg("-O3")
            .arg("-o")
            .arg(config.paths.output.as_path())
            .output()
            .expect("Failed: execute process");

        let is_quiet = config.flags.quiet;

        if !clang_compile_proc.stdout.is_empty() && !is_quiet {
            println!(
                "Clang output:\n{}",
                String::from_utf8_lossy(&clang_compile_proc.stdout)
            );
        }

        if !clang_compile_proc.stderr.is_empty() && !is_quiet {
            eprintln!(
                "Clang errors:\n{}",
                String::from_utf8_lossy(&clang_compile_proc.stderr)
            );
        }

        if !clang_compile_proc.status.success() {
            bail!(
                "Clang failed with exit code: {:?}",
                clang_compile_proc.status.code()
            );
        }

        Ok(())

        // remove_file(llvm_path).unwrap();
    }
}
