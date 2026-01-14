use std::{
    fs::File,
    path::{Path, PathBuf},
};

use reqwest::blocking;

mod download_error {
    pub enum DownloadError {
        IO(std::io::Error),
        String(String),
    }

    impl From<std::io::Error> for DownloadError {
        fn from(e: std::io::Error) -> Self {
            DownloadError::IO(e)
        }
    }

    impl From<reqwest::Error> for DownloadError {
        fn from(e: reqwest::Error) -> Self {
            DownloadError::String(e.to_string())
        }
    }

    impl std::fmt::Display for DownloadError {
        fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
            match self {
                DownloadError::IO(e) => e.fmt(f),
                DownloadError::String(e) => e.fmt(f),
            }
        }
    }
}

use download_error::DownloadError;

pub struct ClangInstaller {
    clang_path: PathBuf,
}

impl ClangInstaller {
    pub fn new(clang_path: &Path) -> Self {
        ClangInstaller {
            clang_path: clang_path.to_path_buf(),
        }
    }

    /// Checks if clang is installed, if not, downloads it
    /// If occurs [`DownloadError`], exits
    pub fn resolve_clang(&self) -> Result<PathBuf, DownloadError> {
        if !self.clang_path.exists() {
            self.download_clang()?;
        }
        Ok(self.clang_path.clone())
    }

    fn download_clang(&self) -> Result<(), DownloadError> {
        println!("📦 Downloading Clang...");
        println!("🕑 This might take a few minutes...");

        //TODO: add linux support
        const URL: &str =
            "https://github.com/lamp100307/KebabBack/releases/download/clang/clang.exe";

        if let Some(parent) = self.clang_path.parent() {
            std::fs::create_dir_all(parent)?;
        }

        let mut response = blocking::get(URL).expect("Failed to download Clang");
        let mut file = File::create(&self.clang_path).expect("Failed to create file");
        std::io::copy(&mut response, &mut file)?;

        println!("✅ Portable Clang ready!");
        Ok(())
    }
}
