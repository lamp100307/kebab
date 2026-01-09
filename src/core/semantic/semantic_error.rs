use crate::core::error_trait::{ErrorDisplay, Span};
use crate::core::parser::nodes::AstNode;
use crate::core::semantic::vars::Type;

pub enum SemanticError {
    TypeMismatch { left: Type, right: Type, span: Span },
    UnsupportedASTNode { node: AstNode, span: Span },
}

impl ErrorDisplay for SemanticError {
    fn error_code(&self) -> &'static str {
        match self {
            SemanticError::TypeMismatch { .. } => "SE0001",
            SemanticError::UnsupportedASTNode { .. } => "SE0002",
        }
    }

    fn error_title(&self) -> String {
        match self {
            SemanticError::TypeMismatch { left, right, .. } => {
                format!("Type Mismatch, left: {}, right: {}", left, right)
            }
            SemanticError::UnsupportedASTNode { node, .. } => {
                format!("Unsupported AST Node: {}", node)
            }
        }
    }

    fn span(&self) -> &Span {
        match self {
            SemanticError::TypeMismatch { span, .. } => span,
            SemanticError::UnsupportedASTNode { span, .. } => span,
        }
    }

    fn help(&self) -> Option<String> {
        match self {
            _ => None,
        }
    }
}

impl std::fmt::Display for SemanticError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        self.format_error(f)
    }
}
