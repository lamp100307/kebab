//! Parser - converts tokens to AST
//! AST - Abstract Syntax Tree
//!
//! # Example:
//!
//! ```kebab
//! print(2 * 3)
//! ```
//!
//! will be converted to
//!
//! ```rust
//! AST: Program(
//!     [
//!         Print(
//!             Op {
//!                 left: Int(2),
//!                 op: "*",
//!                 right: Int(3),
//!             },
//!         ),
//!     ],
//! )
//! ```

use crate::core::error_trait::Span;
use crate::core::lexer::token::{Token, TokenType};
use crate::core::parser::{nodes::AstNode, parser_error::ParserError};

pub struct Parser {
    pos: usize,
    tokens: Vec<Token>,
}

impl Parser {
    pub fn new(tokens: Vec<Token>) -> Parser {
        Parser { pos: 0, tokens }
    }

    /// Parse the tokens into an AST
    pub fn parse(&mut self) -> Result<AstNode, ParserError> {
        let mut ast = Vec::new();
        while self.pos < self.tokens.len() {
            ast.push(self.parse_expr()?);
        }
        Ok(AstNode::Program(ast))
    }

    fn peek(&self) -> Option<Token> {
        self.tokens.get(self.pos).cloned()
    }

    /// Takes a token and checks if it matches the expected token type
    /// Also checks if the end of the tokens has been reached
    fn consume(&mut self, expected_token_type: TokenType) -> Result<Token, ParserError> {
        if let Some(token) = self.peek() {
            if token.token_type == expected_token_type {
                self.pos += 1;
                Ok(token)
            } else {
                Err(ParserError::TokenMismatch {
                    expected: expected_token_type,
                    got: token.token_type,
                    span: token.span.clone(),
                    help: None,
                })
            }
        } else {
            Err(ParserError::UnexpectedEOF {
                span: Span {
                    // TODO fixme
                    start_line: 0,
                    start_col: 0,
                    source_snippet: "".to_string(),
                },
            })
        }
    }

    fn parse_expr(&mut self) -> Result<AstNode, ParserError> {
        let mut left = self.parse_term()?;
        if self.pos >= self.tokens.len() {
            return Ok(left);
        }
        while let Some(token) = self.peek() {
            if token.token_type == TokenType::OP && (token.value == "+" || token.value == "-") {
                self.consume(TokenType::OP)?;
                let right = self.parse_term()?;
                left = AstNode::Op {
                    op: token.value,
                    left: Box::new(left),
                    right: Box::new(right),
                };
            } else {
                break;
            }
        }
        Ok(left)
    }

    fn parse_term(&mut self) -> Result<AstNode, ParserError> {
        let mut left = self.parse_factor()?;
        if self.pos >= self.tokens.len() {
            return Ok(left);
        }
        while let Some(token) = self.peek() {
            if token.token_type == TokenType::OP && (token.value == "*" || token.value == "/") {
                self.consume(TokenType::OP)?;
                let right = self.parse_factor()?;
                left = AstNode::Op {
                    op: token.value,
                    left: Box::new(left),
                    right: Box::new(right),
                };
            } else {
                break;
            }
        }
        Ok(left)
    }

    fn parse_factor(&mut self) -> Result<AstNode, ParserError> {
        let node = self.peek().ok_or(ParserError::UnexpectedEOF {
            span: Span {
                // TODO fixme
                start_line: 0,
                start_col: 0,
                source_snippet: "".to_string(),
            },
        })?;
        match node.token_type {
            TokenType::Int => {
                let str_num = self.consume(TokenType::Int)?;
                let num = str_num.value.parse::<i32>().unwrap();
                Ok(AstNode::Int(num))
            }
            TokenType::Keyword => match node.value.as_str() {
                "print" => {
                    self.consume(TokenType::Keyword)?;
                    self.consume(TokenType::LParen)?;
                    let expr = self.parse_expr()?;
                    self.consume(TokenType::RParen)?;
                    Ok(AstNode::Print(Box::new(expr)))
                }
                _ => Err(ParserError::TokenMismatch {
                    expected: TokenType::Keyword,
                    got: node.token_type,
                    span: node.span.clone(),
                    help: None,
                }),
            },
            _ => Err(ParserError::TokenMismatch {
                expected: TokenType::Int,
                got: node.token_type,
                span: node.span.clone(),
                help: None,
            }),
        }
    }
}
