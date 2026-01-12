use std::{fs::File, path::Path};

use reqwest::blocking;

mod download_error {
    pub enum DownloadError {
        IO(std::io::Error),
        Reqwest(reqwest::Error),
    }

    impl From<std::io::Error> for DownloadError {
        fn from(e: std::io::Error) -> Self {
            DownloadError::IO(e)
        }
    }

    impl From<reqwest::Error> for DownloadError {
        fn from(e: reqwest::Error) -> Self {
            DownloadError::Reqwest(e)
        }
    }

    impl std::fmt::Display for DownloadError {
        fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
            match self {
                DownloadError::IO(e) => e.fmt(f),
                DownloadError::Reqwest(e) => e.fmt(f),
            }
        }
    }
}

use download_error::DownloadError;

/// Checks if clang is installed, if not, downloads it
/// If occurs [`DownloadError`], exits
pub fn resolve_clang(clang_path: &Path) -> Result<(), DownloadError> {
    if !clang_path.exists() {
        download_clang()?
    }
    Ok(())
}

/// Downloads portable Clang from ours GitHub repo
fn download_clang() -> Result<(), DownloadError> {
    println!("📦 Downloading Clang...");
    println!("🕑 This might take a few minutes...");

    const URL: &str = "https://github.com/lamp100307/KebabBack/releases/download/clang/clang.exe";
    const FILE_PATH: &str = "clang.exe";

    let mut response = blocking::get(URL)?;
    let mut file = File::create(FILE_PATH)?;
    std::io::copy(&mut response, &mut file)?;

    println!("✅ Portable Clang ready!");
    Ok(())
}
