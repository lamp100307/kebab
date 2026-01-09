use core::error_trait::Span;
use crate::core::error_trait::ErrorDisplay;

#[derive(Debug, Clone)]
pub enum ParserError {
    TokenMismatch {
        expected: String,
        got: String,
        span: Span,
        suggestion: Option<String>
    },
    UnexpectedEOF {
        span: Span,
    },
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
            ParserError::TokenMismatch { expected, got, .. } => format!("Token Mismatch: expected: {}, got: {}", expected, got),
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
            ParserError::TokenMismatch { suggestion, .. } => suggestion.clone(),
            _ => None
        }
    }
}

impl std::fmt::Display for ParserError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.error_title())
    }
}