use clap::Parser;
use std::path::PathBuf;

use crate::commands::CommandType;

#[derive(Parser, Debug, Clone)]
#[command(name = "kebab")]
#[command(about = "Kebab compiler and build tool")]
pub struct Args {
    #[command(subcommand)]
    pub command: CommandType,

    /// Path to source file or project directory
    #[arg(default_value = ".")]
    pub path: Option<PathBuf>,

    #[arg(short('o'), long("output"))]
    pub output: Option<String>,
    #[arg(short('d'), long("debug"))]
    pub debug: Option<bool>,
    #[arg(short('q'), long("quiet"))]
    pub quiet: Option<bool>,
}
