//! Enum of parser errors
//! Parser errors looks like `PAxxxx` where `xxxx` is error code
//!
//! # Error codes:
//! PA0001 [`ParserError::TokenMismatch`] - Token Mismatch
//! PA0002 [`ParserError::UnexpectedEOF`] - Unexpected EOF (End Of File)

use crate::core::error_trait::ErrorDisplay;
use crate::core::error_trait::Span;
use crate::core::lexer::token::TokenType;

#[derive(Debug, Clone)]
pub enum ParserError {
    /// [PA0001] Token Mismatch:
    ///     expected: TokenType::LParen("(")
    ///     got: TokenType::Int("2")
    ///   |
    /// 1 | print 2
    ///   |       ^
    ///
    /// help: maybe you forgot a `(`
    TokenMismatch {
        expected: TokenType,
        got: TokenType,
        span: Span,
        help: Option<String>,
    },

    /// [PA0002] Unexpected EOF:
    ///   |
    /// 1 | print(
    ///   |       ^
    ///
    /// help: maybe you forgot a `)`
    UnexpectedEOF { span: Span },
}

impl ErrorDisplay for ParserError {
    fn error_code(&self) -> &'static str {
        match self {
            ParserError::TokenMismatch { .. } => "PA0001",
            ParserError::UnexpectedEOF { .. } => "PA0002",
        }
    }

    fn error_title(&self) -> String {
        match self {
            ParserError::TokenMismatch { expected, got, .. } => {
                format!("Token Mismatch:\n\texpected: {}\n\tgot: {}", expected, got)
            }
            ParserError::UnexpectedEOF { .. } => "Unexpected EOF".to_string(),
        }
    }

    fn span(&self) -> &Span {
        match self {
            ParserError::TokenMismatch { span, .. } => span,
            ParserError::UnexpectedEOF { span } => span,
        }
    }

    fn help(&self) -> Option<String> {
        match self {
            ParserError::TokenMismatch { help, .. } => help.clone(),
            _ => None,
        }
    }
}

impl std::fmt::Display for ParserError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.error_title())
    }
}
