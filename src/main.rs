mod args;
mod clang;
mod commands;
mod config;
mod toml;

use clap::Parser;

fn main() {
    let args = args::Args::parse();

    let config = config::ConfigBuilder::new(args);

    match config.command.execute(&config) {
        Ok(()) => {},
        Err(e) => eprintln!("Failed: execute {:?} command: {}", config.command, e)
    }
}
