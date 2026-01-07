use regex::Regex;

use super::token::TokenType;

pub fn lex(content: &str) -> Result<Vec<(TokenType, Regex)>, String> {
    let tokens = vec![
        (TokenType::Int, Regex::new(r"\d+").unwrap()),
        (TokenType::OP, Regex::new(r"[+\-*/]").unwrap()),
    ];

    for (token_type, token_regex) in tokens {
        println!("{}: {}", token_type, token_regex);
    }

    // TODO: finish it
}
