use crate::core::error_trait::Span;
use crate::core::lexer::token::{Token, TokenType};
use crate::core::parser::nodes::AstNode;
use crate::core::parser::parser_error::ParserError;

pub struct Parser {
    pos: usize,
    tokens: Vec<Token>,
}

impl Parser {
    pub fn new(tokens: Vec<Token>) -> Parser {
        Parser { pos: 0, tokens }
    }

    fn peek(&self) -> Option<Token> {
        self.tokens.get(self.pos).cloned()
    }

    fn consume(&mut self, token_type: TokenType) -> Result<Token, ParserError> {
        if let Some(token) = self.peek() {
            if token.token_type == token_type {
                self.pos += 1;
                Ok(token)
            } else {
                Err(ParserError::TokenMismatch {
                    expected: token_type.to_string(),
                    got: token.token_type.to_string(),
                    span: token.span.clone(),
                    suggestion: None
                })
            }
        } else {
            Err(ParserError::UnexpectedEOF {
                span: Span {
                    start_line: 0,
                    start_col: 0,
                    source_snippet: "".to_string(),
                },
            })
        }
    }

    pub(crate) fn parse(&mut self) -> Result<AstNode, ParserError> {
        let mut ast = Vec::new();
        while self.pos < self.tokens.len() {
            ast.push(self.parse_expr()?);
        }
        Ok(AstNode::Program(ast))
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
                    right: Box::new(right)
                };
            } else {
                break
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
                    right: Box::new(right)
                };
            } else {
                break
            }
        }
        Ok(left)
    }

    fn parse_factor(&mut self) -> Result<AstNode, ParserError> {
        let node = self.peek().ok_or(ParserError::UnexpectedEOF {
            span: Span {
                start_line: 0,
                start_col: 0,
                source_snippet: "".to_string(),
            }
        })?;
        match node.token_type {
            TokenType::Int => {
                let str_num = self.consume(TokenType::Int)?;
                let num = str_num.value.parse::<i32>().unwrap();
                Ok(AstNode::Int(num))
            }
            _ => Err(ParserError::TokenMismatch {
                expected: TokenType::Int.to_string(),
                got: node.token_type.to_string(),
                span: node.span.clone(),
                suggestion: None
            })
        }
    }
}
