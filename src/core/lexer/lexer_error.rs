//! Enum of lexer errors
//! Lexer errors looks like `LExxxx` where `xxxx` is error code
//!
//! # Error codes:
//! LE0001 [`LexerError::InvalidChar`] - Invalid character

use crate::core::error_trait::ErrorDisplay;
use crate::core::error_trait::Span;

#[derive(Debug)]
pub enum LexerError {
    /// [LE0001] Invalid character:
    ///   |
    /// 1 | print(№)
    ///   |       ^
    ///
    /// help: maybe you accidentally misclicked a character?
    InvalidChar {
        char: char,
        span: Span,
        suggestion: Option<String>,
    },
}

impl ErrorDisplay for LexerError {
    fn error_code(&self) -> &'static str {
        match self {
            LexerError::InvalidChar { .. } => "LE0001",
        }
    }

    fn error_title(&self) -> String {
        match self {
            LexerError::InvalidChar { char, .. } => format!("Invalid character: {}", char),
        }
    }

    fn span(&self) -> &Span {
        match self {
            LexerError::InvalidChar { span, .. } => span,
        }
    }

    fn help(&self) -> Option<String> {
        match self {
            LexerError::InvalidChar { suggestion, .. } => suggestion.clone(),
        }
    }
}

impl std::fmt::Display for LexerError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        self.format_error(f)
    }
}
