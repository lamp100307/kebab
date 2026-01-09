use super::semantic_error::SemanticError;
use super::vars::Type;
use crate::core::error_trait::Span;
use crate::core::parser::nodes::AstNode;

pub struct SemanticAnalyser; // vars in plans

impl SemanticAnalyser {
    pub fn new() -> SemanticAnalyser {
        SemanticAnalyser
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
    }

    pub fn analyse(&mut self, ast: &AstNode) -> Result<(), SemanticError> {
        if let AstNode::Program(nodes) = ast {
            for node in nodes {
                self.analyse_node(node)?;
            }
        }
        Ok(())
    }

    fn analyse_node(&mut self, node: &AstNode) -> Result<(), SemanticError> {
        match node {
            AstNode::Int(_) => Ok(()),
            AstNode::Op { left, right, .. } => {
                self.analyse_node(&**left)?;
                self.analyse_node(&**right)?;
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
            AstNode::Print(node) => Ok(self.analyse_node(&**node)?),
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
