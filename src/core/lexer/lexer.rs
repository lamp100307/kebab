use crate::core::error_trait::Span;
use super::token::{TokenType, Token};
use super::lexer_error::LexerError;

pub fn lex(content: &str) -> Result<Vec<Token>, LexerError> {
    let mut tokens = Vec::new();
    let mut line: usize = 1;
    let mut col: usize = 1;
    let mut chars = content.char_indices().peekable();

    while let Some((pos, c)) = chars.next() {
        match c {
            '\n' => {
                line += 1;
                col = 1;
            }
            '\r' => {
                if chars.peek().map(|(_, next_c)| *next_c == '\n').unwrap_or(false) {
                    chars.next();
                    line += 1;
                    col = 1;
                } else {
                    col += 1;
                }
            }
            ' ' | '\t' => {
                col += 1;
            }
            '0'..='9' => {
                let start_col = col;
                let start_line = line;
                let mut num = String::new();
                num.push(c);

                while let Some(&(_, next_c)) = chars.peek() {
                    if next_c.is_ascii_digit() {
                        num.push(next_c);
                        col += 1;
                        chars.next();
                    } else {
                        break;
                    }
                }

                tokens.push(Token {
                    token_type: TokenType::Int,
                    value: num.clone(),
                    span: Span {
                        start_line,
                        start_col,
                        source_snippet: content[pos..].chars().take(num.len()).collect(),
                    },
                });
                col += 1;
            }
            '(' => tokens.push(Token {
                token_type: TokenType::LParen,
                value: c.to_string(),
                span: Span {
                    start_line: line,
                    start_col: col,
                    source_snippet: content[pos..].chars().take(1).collect(),
                },
            }),
            ')' => tokens.push(Token {
                token_type: TokenType::RParen,
                value: c.to_string(),
                span: Span {
                    start_line: line,
                    start_col: col,
                    source_snippet: content[pos..].chars().take(1).collect(),
                },
            }),
            '+' | '-' | '*' | '/' => {
                let op = c.to_string();
                col += 1;
                tokens.push(Token {
                    token_type: TokenType::OP,
                    value: op,
                    span: Span {
                        start_line: line,
                        start_col: col,
                        source_snippet: content[pos..].chars().take(1).collect(),
                    },
                })
            }
            'a'..='z' | 'A'..='Z' => {
                let start_col = col;
                let start_line = line;
                let mut id = String::new();
                id.push(c);

                while let Some(&(_, next_c)) = chars.peek() {
                    if next_c.is_ascii_alphanumeric() {
                        id.push(next_c);
                        col += 1;
                        chars.next();
                    } else {
                        break;
                    }
                }

                let mut types: TokenType = TokenType::Id;

                match id.as_str() {
                    "print" => types = TokenType::Keyword,
                    _ => ()
                }

                tokens.push(Token {
                    token_type: types,
                    value: id.clone(),
                    span: Span {
                        start_line,
                        start_col,
                        source_snippet: content[pos..].chars().take(id.len()).collect(),
                    },
                });
                col += 1;
            }
            _ => {
                let line_start = content[..pos]
                    .rfind('\n')
                    .map(|i| i + 1)
                    .unwrap_or(0);

                let line_end = content[pos..]
                    .find('\n')
                    .map(|i| pos + i)
                    .unwrap_or(content.len());

                return Err(LexerError::InvalidChar {
                    char: c,
                    span: Span {
                        start_line: line,
                        start_col: col,
                        source_snippet: content[line_start..line_end].to_string(),
                    },
                    suggestion: {
                        match c {
                            ';' => Some("Remove this semicolon".to_string()),
                            _ => None
                        }
                    },
                });
            }
        }
    }

    Ok(tokens)
}