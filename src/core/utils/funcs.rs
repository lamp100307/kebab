use std::path::{Path, PathBuf};

use crate::core::utils::toml_parser::TomlConfig;

pub fn project_relative(toml: Option<&TomlConfig>, path: &Path) -> PathBuf {
    match toml {
        Some(pr) => pr
            .path
            .parent()
            .map(|p| p.join(path))
            .unwrap_or(path.to_path_buf()),
        None => path.to_path_buf(),
    }
}
