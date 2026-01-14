use std::path::PathBuf;

#[derive(Debug, Clone)]
pub struct Flags {
    pub debug: bool,
    pub quiet: bool,
    pub optimize: bool,
    pub verbose: bool,
}

#[derive(Debug)]
pub struct Project {
    pub name: String,
    pub version: String,
    pub authors: Vec<String>,
    pub toml_path: PathBuf,
    pub project_dir: PathBuf,
    // pub raw_toml: crate::project::toml::RawTomlConfig,
}
