use regex::Regex;
use std::fmt::Display;

pub enum TokenType {
    Int,
    OP,
}

impl Display for TokenType {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{:?}", self)
    }
}

pub(crate) struct Token {
    token_type: TokenType,
    value: String,
    regex: Regex
}

impl Display for Token {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}: {}", self.token_type, self.value)
    }
}