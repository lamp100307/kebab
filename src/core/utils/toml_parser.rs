use std::{
    fs::read_to_string,
    path::{Path, PathBuf},
};

use serde::Deserialize;

#[derive(Deserialize)]
pub struct TomlConfig {
    pub project: ProjectOptions,
    pub build: BuildOptions,
    #[serde(skip)]
    pub path: PathBuf,
}

#[derive(Deserialize)]
pub struct ProjectOptions {
    pub name: String,
    // pub version: String,
    pub entry: Option<PathBuf>,
    pub clang_path: Option<PathBuf>,
}

#[derive(Deserialize)]
pub struct BuildOptions {
    #[serde(default)]
    pub debug: bool,
    #[serde(default)]
    pub quiet: bool,
    #[serde(default)]
    pub output: Option<PathBuf>,
}

pub fn parse_toml(path: &Path) -> Result<TomlConfig, Box<dyn std::error::Error>> {
    let content = read_to_string(path)?;
    let mut toml: TomlConfig = toml::from_str(&content).expect("Couldn't read the toml file");
    toml.path = path.to_path_buf();
    Ok(toml)
}

/// Returns the path to the `oven.toml`
/// Look for the `oven.toml` in the current directory,
/// if it doesn't exist, look for given path
pub fn get_toml_path(path: Option<&Path>) -> Option<PathBuf> {
    std::env::current_dir()
        .ok()
        .map(|p| p.join("oven.toml"))
        .filter(|p| p.exists())
        .or_else(|| {
            path.and_then(|p| {
                let toml_path = p.join("oven.toml");
                toml_path.exists().then_some(toml_path)
            })
        })
}
