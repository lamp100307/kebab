use crate::config::Config;
use clap::Subcommand;
pub mod build;
pub mod clean;
pub mod init;
pub mod run;
pub mod test;

#[derive(PartialEq, Clone, Debug, Subcommand)]
pub enum CommandType {
    Run,
    Build,
    Clean,
    Init { name: String },
    Test,
}

impl Default for CommandType {
    fn default() -> Self {
        CommandType::Run
    }
}

impl CommandType {
    pub fn execute(&self, config: &Config) -> anyhow::Result<()> {
        match self {
            CommandType::Run => run::execute(config),
            CommandType::Build => build::execute(config),
            CommandType::Clean => clean::execute(config),
            CommandType::Init { name } => init::execute(config, name),
            CommandType::Test => test::execute(config),
        }
    }
}

pub trait Command {
    fn execute(config: &Config) -> anyhow::Result<()>;
}
