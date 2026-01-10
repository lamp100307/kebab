#[derive(Debug, PartialEq)]
pub enum ArgType {
    Path,
    Output,
    Debug,
    Command,
}

#[derive(Debug)]
pub struct Arg {
    pub arg_type: ArgType,
    pub value: Option<String>,
}

pub fn parse_args(args: Vec<String>) -> (Option<String>, Vec<Arg>) {
    let mut command = None;
    let mut parsed_args = Vec::new();
    let mut iter = args.iter().enumerate().peekable();
    
    while let Some((_, arg)) = iter.next() {
        match arg.as_str() {
            "run" | "build" | "test" | "clean" => {
                if command.is_none() {
                    command = Some(arg.clone());
                } else {
                    parsed_args.push(Arg {
                        arg_type: ArgType::Path,
                        value: Some(arg.clone()),
                    });
                }
            }
            "-p" => {
                if let Some(next_arg) = iter.peek() {
                    parsed_args.push(Arg {
                        arg_type: ArgType::Path,
                        value: Some(next_arg.1.clone()),
                    });
                    iter.next();
                }
            }
            "-o" => {
                if let Some(next_arg) = iter.peek() {
                    parsed_args.push(Arg {
                        arg_type: ArgType::Output,
                        value: Some(next_arg.1.clone()),
                    });
                    iter.next();
                }
            }
            "-d" | "--debug" | "debug" => {
                parsed_args.push(Arg {
                    arg_type: ArgType::Debug,
                    value: None,
                });
            }
            _ => {
                panic!("Unsupported argument: {}", arg);
            }
        }
    }
    
    (command, parsed_args)
}