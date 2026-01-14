mod args;
mod clang;
mod commands;
mod config;
mod core;
mod toml;

use clap::Parser;

fn main() {
    let args = args::Args::parse();

    let config = match config::ConfigBuilder::new(args) {
        Ok(config) => config,
        Err(e) => {
            eprintln!("Failed: build config: {}", e);
            return;
        }
    };

    match config.command.execute(&config) {
        Ok(()) => {}
        Err(e) => eprintln!("Failed: execute {:?} command: {}", config.command, e),
    }
}
