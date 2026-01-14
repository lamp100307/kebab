use std::{
    ffi::OsStr,
    path::{Path, PathBuf},
};

#[derive(Debug)]
pub struct Paths {
    pub entry: PathBuf,
    pub output: PathBuf,
    pub clang: PathBuf,
    pub build_dir: PathBuf,
    /// the directory where there is oven.toml
    pub project_dir: Option<PathBuf>,
    /// the directory where open terminal
    pub working_dir: PathBuf,
}

pub struct PathsBuilder<'a> {
    args: &'a crate::args::Args,
    toml_config: Option<&'a crate::toml::TomlConfig>,
    project_dir: Option<PathBuf>,
    working_dir: PathBuf,
}

impl PathsBuilder<'_> {
    fn build_paths(&self) -> Result<Paths, String> {
        let entry = self.resolve_entry_path()?;
        let build_dir = self.resolve_build_dir();

        Ok(Paths {
            output: self.resolve_output_path(&entry),
            clang: self.resolve_clang_path(&build_dir),
            project_dir: self.project_dir.clone(),
            working_dir: self.working_dir.clone(),
            entry: entry,
            build_dir: build_dir,
        })
    }

    fn resolve_entry_path(&self) -> Result<PathBuf, String> {
        // If the path argument is provided and is a valid kebab file
        if let Some(path) = &self.args.path {
            if path.is_file() && path.extension() == Some(OsStr::new("keb")) {
                return Ok(path.clone());
            }
        }

        // If the toml config is provided and has an entry
        if let Some(toml) = &self.toml_config {
            if let Some(entry) = &toml.project_opt.entry {
                let project_dir = self.project_dir.as_ref().unwrap();
                let entry_path = project_dir.join(entry);
                if entry_path.is_file() {
                    return Ok(entry_path);
                }
            }
        }

        let candidates = self.generate_candidate_paths();
        for candidate in candidates {
            if candidate.is_file() {
                return Ok(candidate);
            }
        }

        Err("Failed: get an entry file".to_string())
    }

    fn generate_candidate_paths(&self) -> Vec<PathBuf> {
        let mut candidates = Vec::with_capacity(4);
        let base_dir = self.project_dir.as_ref().unwrap_or(&self.working_dir);

        if let Some(toml) = &self.toml_config {
            candidates.push(base_dir.join(&toml.project_opt.name).with_extension("keb"));
            candidates.push(
                base_dir
                    .join("src")
                    .join(&toml.project_opt.name)
                    .with_extension("keb"),
            );
        }

        candidates.push(base_dir.join("main.keb"));
        candidates.push(base_dir.join("src/main.keb"));
        candidates
    }

    fn resolve_output_path(&self, entry: &Path) -> PathBuf {
        if let Some(output_arg) = &self.args.output {
            return self.resolve_special_output_path(output_arg, entry);
        }

        if let Some(toml) = &self.toml_config {
            if let Some(output) = &toml.build_opt.output {
                return self.build_absolute_path(output);
            }
        }

        self.generate_default_output_path(entry)
    }

    fn resolve_special_output_path(&self, output_arg: &str, entry: &Path) -> PathBuf {
        let output_path = PathBuf::from(output_arg);

        // Case 1: path ends with "."
        if output_arg == "." {
            return self.generate_filename_in_dir(
                Path::new("."),
                entry,
                self.toml_config.as_ref().map(|t| &t.project_opt.name),
            );
        }

        // Case 2: path ends with "/." or "\." (e.g. "build/.")
        if output_arg.ends_with("/.") || output_arg.ends_with("\\.") {
            let parent = output_path.parent().unwrap_or(Path::new("."));
            return self.generate_filename_in_dir(
                parent,
                entry,
                self.toml_config.as_ref().map(|t| &t.project_opt.name),
            );
        }

        // Case 3: path without extension or points to a directory
        if output_path.extension().is_none()
            || output_arg.ends_with('/')
            || output_arg.ends_with('\\')
        {
            let is_dir = if output_path.exists() {
                output_path.is_dir()
            } else {
                output_arg.ends_with('/') || output_arg.ends_with('\\')
            };

            if is_dir {
                return self.generate_filename_in_dir(
                    &output_path,
                    entry,
                    self.toml_config.as_ref().map(|t| &t.project_opt.name),
                );
            }
        }

        // Case 4: ordinary path to a file
        output_path
    }

    /// Генерация имени файла в указанной директории
    fn generate_filename_in_dir(
        &self,
        dir: &Path,
        entry: &Path,
        project_name: Option<&String>,
    ) -> PathBuf {
        let filename = if let Some(name) = project_name {
            // В проекте: используем имя проекта
            name.clone()
        } else {
            // Вне проекта: используем имя исходного файла без расширения
            entry
                .file_stem()
                .unwrap_or(OsStr::new("output"))
                .to_string_lossy()
                .to_string()
        };

        let mut result = dir.join(filename);

        // Добавляем .exe на Windows если нет расширения
        #[cfg(target_os = "windows")]
        if result.extension().is_none() {
            result.set_extension("exe");
        }

        result
    }

    /// Автоматическая генерация пути по умолчанию
    fn generate_default_output_path(&self, entry: &Path) -> PathBuf {
        // Определяем базовую директорию для сборки
        let build_base_dir = if let Some(project_dir) = &self.project_dir {
            // В проекте: рядом с oven.toml
            project_dir.clone()
        } else {
            // Вне проекта: рядом с исходным файлом
            entry.parent().unwrap_or(Path::new(".")).to_path_buf()
        };

        // Создаем путь build/<name>
        let build_dir = build_base_dir.join("build");
        let name = if let Some(toml) = &self.toml_config {
            toml.project_opt.name.clone()
        } else {
            entry
                .file_stem()
                .unwrap_or(OsStr::new("output"))
                .to_string_lossy()
                .to_string()
        };

        let mut output = build_dir.join(name);

        #[cfg(target_os = "windows")]
        if output.extension().is_none() {
            output.set_extension("exe");
        }

        output
    }

    /// Построить абсолютный путь относительно проекта
    fn build_absolute_path(&self, path: &Path) -> PathBuf {
        if path.is_absolute() {
            return path.to_path_buf();
        }

        let base = self.project_dir.as_ref().unwrap_or(&self.working_dir);
        base.join(path)
    }

    fn resolve_build_dir(&self) -> PathBuf {
        if let Some(project_dir) = &self.project_dir {
            project_dir.join("build")
        } else {
            self.working_dir.join("build")
        }
    }

    fn resolve_clang_path(&self, build_dir: &Path) -> PathBuf {
        if let Some(toml) = &self.toml_config {
            if let Some(clang_path) = &toml.project_opt.clang_path {
                let absolute_path = self.build_absolute_path(clang_path);

                if absolute_path.is_dir() || clang_path.ends_with("/") || clang_path.ends_with("\\")
                {
                    let mut path = absolute_path;
                    path.push("clang.exe");
                    return path;
                }

                return absolute_path;
            }
        }

        build_dir.join("clang.exe")
    }
}
