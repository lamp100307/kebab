use core::parser::nodes::AstNode;
use core::semantic::vars::Type;
use crate::core::error_trait::{ErrorDisplay, Span };

pub enum SemanticError {
    VariableNotFound {
        name: String,
        span: Span,
        suggestion: Option<String>
    },
    TypeMismatch {
        left: Type,
        right: Type,
        span: Span
    },
    UnsupportedASTNode {
        node: AstNode,
        span: Span
    }
}

impl ErrorDisplay for SemanticError {
    fn error_code(&self) -> &'static str {
        match self {
            SemanticError::VariableNotFound { .. } => "SE0001",
            SemanticError::TypeMismatch { .. } => "SE0002",
            SemanticError::UnsupportedASTNode { .. } => "SE0003",
        }
    }

    fn error_title(&self) -> String {
        match self {
            SemanticError::VariableNotFound { .. } => "Variable Not Found".to_string(),
            SemanticError::TypeMismatch { .. } => "Type Mismatch".to_string(),
            SemanticError::UnsupportedASTNode { .. } => "Unsupported AST Node".to_string(),
        }
    }

    fn span(&self) -> &Span {
        match self {
            SemanticError::VariableNotFound { span, .. } => span,
            SemanticError::TypeMismatch { span, .. } => span,
            SemanticError::UnsupportedASTNode { span, .. } => span
        }
    }

    fn help(&self) -> Option<String> {
        match self {
            SemanticError::VariableNotFound { suggestion, .. } => suggestion.clone(),
            _ => None
        }
    }
}

impl std::fmt::Display for SemanticError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        self.format_error(f)
    }
}