use toml::Value;
use std::fs;

pub struct Project {
    pub name: String,
    pub version: String,
    pub entry: String,
    pub clang_path: String,
}

pub fn parse_toml(path: &str) -> Result<Project, Box<dyn std::error::Error>> {
    let content = fs::read_to_string(path)?;
    let value: Value = toml::from_str(&content)?;
    Ok(Project {
        name: value["name"].as_str().unwrap().to_string(),
        version: value["version"].as_str().unwrap().to_string(),
        entry: value["entry"].as_str().unwrap().to_string(),
        clang_path: value["clang_path"].as_str().unwrap().to_string(),
    })
}