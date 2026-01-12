use std::{iter::Peekable, path::PathBuf, vec::IntoIter};

#[derive(PartialEq, Eq)]
pub enum ArgType {
    Run,
    Build,
    Test,
}

impl Default for ArgType {
    fn default() -> Self {
        ArgType::Run
    }
}

impl ArgType {
    fn from(value: &str) -> Result<Self, String> {
        match value.to_lowercase().as_str() {
            "run" => Ok(ArgType::Run),
            "build" => Ok(ArgType::Build),
            "test" => Ok(ArgType::Test),
            _ => Err(format!("Unsupported command: {}", value)),
        }
    }
}

#[derive(Default)]
pub struct Args {
    pub base_name: String,
    pub command: ArgType,
    pub path: Option<PathBuf>,
    pub output: Option<PathBuf>,
    pub debug: bool,
}

/// Get command line arguments
/// # The Kebab compile call examples
/// - `kebab run <path>`
/// - `kebab build <path> -d -o <output_path>`
/// - `kebab test <path>`
pub fn get_args() -> Result<Args, String> {
    let mut iter = get_args_iter()?;
    let mut args = Args::default();

    args.base_name = iter.next().unwrap().clone();
    args.command = ArgType::from(iter.next().ok_or("Missing command")?.as_str())?;
    match iter.next_if(|x| !x.starts_with('-')) {
        Some(path) => args.path = Some(PathBuf::from(path)),
        None => {}
    }

    while let Some(arg) = iter.next() {
        match arg.as_str() {
            "-o" | "--output" => {
                args.output = Some(PathBuf::from(iter.next().ok_or("Missing output path")?))
            }
            "-d" | "--debug" => args.debug = true,
            _ => return Err(format!("Unknown option: {}", arg)),
        }
    }

    Ok(args)
}

fn get_args_iter() -> Result<Peekable<IntoIter<String>>, String> {
    let user_args: Vec<String> = std::env::args().collect();

    if user_args.len() < 2 {
        return Err(
            "Usage: kebab <command> <path> [-o/--output <output_path>] [-d/--debug]".to_string(),
        );
    }

    Ok(user_args.into_iter().peekable())
}
