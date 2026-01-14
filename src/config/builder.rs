use std::path::{Path, PathBuf};

use super::paths::PathsBuilder;
use super::structures::{Flags, Project};
use crate::{args::Args, toml::TomlConfig};

#[derive(Debug)]
pub struct Config {
    pub flags: Flags,
    pub paths: super::paths::Paths,
    pub project: Option<Project>,
}

pub struct ConfigBuilder {
    args: Args,
    toml_config: Option<TomlConfig>,
    project_dir: Option<PathBuf>,
    working_dir: PathBuf,
}

impl ConfigBuilder {
    pub fn new(args: Args) -> Config {
        let working_dir = std::env::current_dir().unwrap();
        Self {
            args,
            toml_config: None,
            project_dir: None,
            working_dir,
        }
        .discover_project()
        .build()
    }

    pub fn discover_project(mut self) -> Self {
        let search_dir = self
            .args
            .path
            .as_ref()
            .map(|p| {
                if p.is_dir() {
                    p.clone()
                } else {
                    p.parent().unwrap_or(&self.working_dir).to_path_buf()
                }
            })
            .unwrap_or(self.working_dir.clone());

        if let Some(project_dir) = self.find_oven_toml(&search_dir) {
            let toml_path = project_dir.join("oven.toml");
            if let Ok(content) = std::fs::read_to_string(&toml_path) {
                if let Ok(toml_config) = toml::from_str::<TomlConfig>(&content) {
                    self.toml_config = Some(toml_config);
                    self.project_dir = Some(project_dir);
                }
            }
        }
        self
    }

    pub fn build(self) -> Config {
        let flags = self.build_flags();
        let project = self.build_project_info();

        Config {
            flags,
            paths: PathsBuilder {
                self.args
            },
            project,
        }
    }

    fn build_flags(&self) -> Flags {
        Flags {
            debug: self.args.debug.unwrap_or(
                self.toml_config
                    .as_ref()
                    .map_or(false, |c| c.build_opt.debug),
            ),
            quiet: self.args.quiet.unwrap_or(
                self.toml_config
                    .as_ref()
                    .map_or(false, |c| c.build_opt.quiet),
            ),
            // optimize: self
            //     .args
            //     .optimize
            //     .or(self.toml_config.as_ref().and_then(|t| t.build_opt.optimize))
            //     .unwrap_or(false),
            // verbose: self
            //     .args
            //     .verbose
            //     .or(self.toml_config.as_ref().and_then(|t| t.build_opt.verbose))
            //     .unwrap_or(false),
        }
    }

    fn build_project_info(&self) -> Option<Project> {
        self.toml_config.as_ref().map(|toml| {
            let project_dir = self.project_dir.clone().unwrap();

            Project {
                name: toml.project_opt.name.clone(),
                version: toml.project_opt.version.clone(),
                authors: toml.project_opt.authors.clone().unwrap_or_default(),
                toml_path: project_dir.join("oven.toml"),
                project_dir,
            }
        })
    }

    fn find_oven_toml(&self, start_dir: &Path) -> Option<PathBuf> {
        let mut current = start_dir;

        while current.exists() {
            let toml_path = current.join("oven.toml");
            if toml_path.is_file() {
                return Some(current.to_path_buf());
            }

            if let Some(parent) = current.parent() {
                current = parent;
            } else {
                break;
            }
        }
        None
    }
}
