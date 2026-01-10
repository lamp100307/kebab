//! Semantic analyzer - checks if AST is correct

use super::semantic_error::SemanticError;
use super::vars::Type;
use crate::core::error_trait::Span;
use crate::core::parser::nodes::AstNode;

pub struct SemanticAnalyzer; // vars in plans

impl SemanticAnalyzer {
    pub fn new() -> SemanticAnalyzer {
        SemanticAnalyzer
    }

    /// Starts AST analysis
    pub fn analyze(&mut self, ast: &AstNode) -> Result<(), SemanticError> {
        if let AstNode::Program(nodes) = ast {
            for node in nodes {
                self.analyze_node(node)?;
            }
        }
        Ok(())
    }

    fn get_node_type(&self, node: &AstNode) -> Result<Type, SemanticError> {
        match node {
            AstNode::Int(_) => Ok(Type::Int),
            _ => Err(SemanticError::UnsupportedASTNode {
                node: node.clone(),
                span: Span {
                    // TODO fixme
                    start_col: 0,
                    start_line: 0,
                    source_snippet: "".to_string(),
                },
            }),
        }
    }

    fn are_types_equal(&mut self, types1: &Type, value: &AstNode) -> Result<bool, SemanticError> {
        match (types1.as_str(), self.get_node_type(&*value)?.as_str()) {
            ("Int", "Int") => Ok(true),
            ("Str", "Str") => Ok(true),
            (_, _) => Ok(false),
        }

        //? Ok(types1.as_str() == self.get_node_type(&*value)?.as_str())
    }

    fn analyze_node(&mut self, node: &AstNode) -> Result<(), SemanticError> {
        match node {
            AstNode::Int(_) => Ok(()),
            AstNode::Op { left, right, .. } => {
                //? Try to replace `&**` with `.as_ref()` (or just `&*`)
                self.analyze_node(&**left)?;
                self.analyze_node(&**right)?;
                if !self.are_types_equal(&self.get_node_type(&**left)?, &**right)? {
                    Err(SemanticError::TypeMismatch {
                        left: self.get_node_type(&**left)?,
                        right: self.get_node_type(&**right)?,
                        span: Span {
                            // TODO fixme
                            start_col: 0,
                            start_line: 0,
                            source_snippet: "".to_string(),
                        },
                    })?;
                }
                Ok(())
            }
            AstNode::Print(node) => Ok(self.analyze_node(&**node)?),
            //? How does an unsupported AST node gets here? It will be caught by parser, isn't it?
            //? Also, you didn't check for `AstNode::Program` (although I understand that it won't be here, but still)
            _ => Err(SemanticError::UnsupportedASTNode {
                node: node.clone(),
                span: Span {
                    // TODO fixme
                    start_col: 0,
                    start_line: 0,
                    source_snippet: "".to_string(),
                },
            })?,
        }
    }
}
