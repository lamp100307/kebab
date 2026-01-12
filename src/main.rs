mod core;

use std::ffi::OsStr;
use std::fs::{create_dir_all, read_to_string, remove_file, write};
use std::path::{Path, PathBuf};
use std::process::{Command, exit};

use core::lexer::lexer::lex;
use core::llvm::llvm_ir::generator::LlvmIrGenerator;
use core::llvm::middle_ir::mir_maker::{get_dependencies, make_middle_ir};
use core::parser::parser::Parser;
use core::semantic::semantic::SemanticAnalyser;
use core::utils::args_parser::{ArgType, Args, get_args};
use core::utils::clang_installer::ClangInstaller;
use core::utils::funcs::project_relative;

use crate::core::utils::toml_parser::*;

fn main() {
    let args = match get_args() {
        Ok(args) => args,
        Err(e) => {
            eprintln!("Failed: parse arguments: {e}");
            exit(1);
        }
    };

    let toml_path = get_toml_path(args.path.as_deref());
    let toml = toml_path.and_then(|path| parse_toml(&path).ok());

    let is_debug = args.debug || toml.as_ref().map_or(false, |t| t.build.debug);

    let source_path = get_source_path(is_debug, &args, toml.as_ref()).unwrap_or_else(|e| {
        eprintln!("{e}");
        std::process::exit(1);
    });

    let output_path = get_output_path(source_path.as_path(), toml.as_ref(), &args);

    match args.command {
        ArgType::Run => {
            if !output_path.exists() {
                build(
                    &args,
                    toml.as_ref(),
                    source_path.as_path(),
                    output_path.as_path(),
                    is_debug,
                );
            }
            run(output_path.as_path());
        }
        ArgType::Build => {
            build(
                &args,
                toml.as_ref(),
                source_path.as_path(),
                output_path.as_path(),
                is_debug,
            );
        }
        ArgType::Test => {}
    }
}

fn build(
    args: &Args,
    toml: Option<&TomlConfig>,
    source_path: &Path,
    output_path: &Path,
    is_debug: bool,
) {
    let is_quiet = args.quiet || toml.as_ref().map_or(false, |t| t.build.quiet);
    let build_dir = project_relative(toml, PathBuf::from("/build").as_path());

    let content = read_to_string(&source_path)
        .expect(format!("Failed: read the file: {source_path:?}").as_str());

    let tokens = lex(&content)
        .map(|tokens| {
            if args.debug {
                println!("Tokens: {:#?}", tokens);
            }
            tokens
        })
        .unwrap_or_else(|e| {
            eprintln!("Failed: lex the file: {e}");
            exit(1);
        });

    let mut parser = Parser::new(tokens);
    let mut ast = match parser.parse() {
        Ok(ast) => {
            if is_debug {
                println!("AST: {ast:#?}");
            }
            ast
        }
        Err(e) => {
            eprintln!("{e}");
            exit(1);
        }
    };

    ast.optimize();

    if is_debug {
        // TODO: implement logger
        println!("Optimized AST: {ast:#?}");
    }

    let mut semantic = SemanticAnalyser::new();
    match semantic.analyse(&ast) {
        Ok(()) => (),
        Err(e) => {
            eprintln!("{e}");
            exit(1);
        }
    }

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

    let llvm_path = build_dir
        .join(output_path.file_name().unwrap_or(OsStr::new("output.ll")))
        .with_extension("ll");
    write(&llvm_path, llvm_ir.clone()).unwrap();

    // compiling and running
    let clang_path = match ClangInstaller::new(
        // the path is from oven.toml, or in the build folder
        toml.and_then(|t| t.project.clang_path.as_deref())
            .unwrap_or(build_dir.join("clang.exe").as_path()),
    )
    .resolve_clang()
    {
        Ok(clang_path) => clang_path,
        Err(e) => {
            eprintln!("Failed to download the portable Clang: {e}");
            exit(1);
        }
    };

    let clang_compile_proc = Command::new(clang_path)
        .arg(&llvm_path)
        .arg("-O3")
        .arg("-o")
        .arg(&output_path)
        .output()
        .expect("Failed: execute process");

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
        eprintln!(
            "Clang failed with exit code: {:?}",
            clang_compile_proc.status.code()
        );
    }

    // remove_file(llvm_path).unwrap();
}

fn run(path: &Path) {
    let output = Command::new(path)
        .output()
        .expect("Failed: to execute process");

    if !output.stdout.is_empty() {
        println!("{}", String::from_utf8_lossy(&output.stdout));
    }
}

/// Returns the path to the source file
/// Tried:
/// 1) path in args
/// 2) path from toml
/// 3) ./src/<project_name>.keb
/// 4) ./<project_name>.keb
/// 5) ./main.keb
/// 6) ./src/main.keb
fn get_source_path(
    is_debug: bool,
    args: &Args,
    config: Option<&TomlConfig>,
) -> Result<PathBuf, String> {
    if let Some(path) = &args.path {
        if path.is_file() {
            return path
                .canonicalize()
                .map_err(|e| format!("Failed: access {path:?}: {e}"));
        }
        if is_debug {
            eprintln!("Warning: {path:?} is not a file, ignoring");
        }
    }

    if let Some(config) = config {
        if let Some(entry) = &config.project.entry {
            let path = project_relative(Some(config), entry);
            if path.is_file() {
                return path
                    .canonicalize()
                    .map_err(|e| format!("Failed: access {path:?}: {e}"));
            }
            if is_debug {
                eprintln!("Warning: {path:?} is not a file, ignoring");
            }
        }

        let candidates = vec![
            PathBuf::from("./src/")
                .join(&config.project.name)
                .with_extension("keb"),
            PathBuf::from(".")
                .join(&config.project.name)
                .with_extension("keb"),
            PathBuf::from("./main.keb"),
            PathBuf::from("./src/main.keb"),
        ];

        for candidate in candidates {
            if candidate.is_file() {
                return candidate
                    .canonicalize()
                    .map_err(|e| format!("Failed: access {candidate:?}: {e}"));
            }
        }

        return Err(format!(
            "Could not find source file for project '{}'. \
            Tried: ./src/{0}.keb, ./{0}.keb, ./main.keb, ./src/main.keb",
            config.project.name
        ));
    }

    Err(
        "Failed: file with the source code not found. Provide path <file.keb> or create oven.toml"
            .to_string(),
    )
}

/// Returns the path to the output file
/// Stem for the output file is (by priority):
/// 1) given output path in args
/// 2) name of the project from toml
/// 3) the same name as the source
///
/// Path of the output file is (by priority):
/// 1) given output path in args
/// 2) in build dir
/// 3) in the same dir with source
fn get_output_path(source_path: &Path, toml: Option<&TomlConfig>, args: &Args) -> PathBuf {
    if let Some(path) = &args.output {
        let output_path = PathBuf::from(path);

        let result = match path.file_name() {
            Some(name) => output_path.parent().unwrap_or(Path::new(".")).join(name),
            None => output_path
                .parent()
                .unwrap_or(Path::new("."))
                .join(toml.map_or("output", |t| t.project.name.as_str())),
        };

        return set_target_extension(&result);
    }

    let filename = match toml {
        Some(config) => &config.project.name,
        None => source_path
            .file_stem()
            .and_then(|s| s.to_str())
            .unwrap_or("output"),
    };

    let directory = match toml {
        Some(config) => config
            .path
            .parent()
            .map(|p| p.join("build"))
            .unwrap_or(PathBuf::from("./build")),

        None => source_path.parent().unwrap_or(Path::new(".")).to_path_buf(),
    };

    let output = directory.join(filename);
    if let Some(parent) = output.parent() {
        create_dir_all(parent)
            .unwrap_or_else(|e| panic!("Failed to create directory {:?}: {}", parent, e));
    }

    set_target_extension(output.as_path())
}

fn set_target_extension(path: &Path) -> PathBuf {
    let mut result = path.to_path_buf();
    #[cfg(target_os = "windows")]
    result.set_extension("exe");
    #[cfg(target_os = "macos")]
    result.set_extension("app");
    #[cfg(target_os = "linux")]
    result.set_extension("AppImage");
    result
}
