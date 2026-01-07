extern crate regex;
use regex::Regex;
use super::lexer_error::LexerError;
use super::token::{ Token, TokenType };

fn lex() {
    let tokens = vec![
        (TokenType::Int, Regex::new(r"\d+").unwrap()),
        (TokenType::OP, Regex::new(r"[+\-*/]").unwrap()),
    ];

    for (token_type, token_regex) in tokens {
        println!("{}: {}", token_type, token_regex);
    }
}