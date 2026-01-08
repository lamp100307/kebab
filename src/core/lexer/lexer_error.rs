use core::error_trait::Span;
use crate::core::error_trait::ErrorDisplay;

#[derive(Debug)]
pub enum LexerError {
    InvalidChar {
        char: char,
        span: Span,
        suggestion: Option<String>
    },
}

impl ErrorDisplay for LexerError {
    fn error_code(&self) -> &'static str {
        match self {
            LexerError::InvalidChar { .. } => "E0001",
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

    fn notes(&self) -> Vec<String> {
        Vec::new()
    }
}

impl std::fmt::Display for LexerError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        self.format_error(f)
    }
}