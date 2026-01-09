use crate::core::llvm::middle_ir::mir_nodes::{Dependency, MirNode};
use crate::core::parser::nodes::AstNode;

pub fn get_dependencies(ast: &AstNode) -> Vec<Dependency> {
    if let AstNode::Program(nodes) = ast {
        let mut dependencies = Vec::new();
        for node in nodes {
            if let AstNode::Print(node) = node {
                match **node {
                    AstNode::Int(_) => dependencies.push(Dependency::IntFmt),
                    _ => ()
                }
                dependencies.push(Dependency::Printf);
            }
        }
        dependencies
    } else {
        panic!("Unsupported AST node in get_dependencies {}", ast);
    }
}

pub fn make_middle_ir(ast: AstNode) -> Vec<MirNode> {
    if let AstNode::Program(nodes) = ast {
        let mut mir_nodes = Vec::new();
        for node in nodes {
            mir_nodes.push(make_middle_ir_node(&node));
        }
        mir_nodes
    } else {
        panic!("Unsupported AST node in make_middle_ir {}", ast);
    }
}

fn make_middle_ir_node(ast: &AstNode) -> MirNode {
    match ast {
        AstNode::Int(n) => MirNode::I32(*n),
        AstNode::Op { left, op, right } => {
            let left = make_middle_ir_node(&**left);
            let right = make_middle_ir_node(&**right);
            match op.as_str() {
                "+" => MirNode::Add { left: Box::new(left), right: Box::new(right) },
                "-" => MirNode::Sub { left: Box::new(left), right: Box::new(right) },
                "*" => MirNode::Mul { left: Box::new(left), right: Box::new(right) },
                "/" => MirNode::Div { left: Box::new(left), right: Box::new(right) },
                _ => panic!("Unsupported operator in make_middle_ir_node {}", op),
            }
        }
        AstNode::Print(node) => {
            MirNode::Print {
                left: Box::new(make_middle_ir_node(&**node)),
            }
        },
        _ => panic!("Unsupported AST node in make_middle_ir_node {}", ast),
    }
}