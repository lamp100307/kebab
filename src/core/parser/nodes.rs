#[derive(Debug)]
pub enum AstNode {
    Program(Vec<AstNode>),
    Int(i32),
    Op {
        left: Box<AstNode>,
        op: String,
        right: Box<AstNode>,
    },
}

impl std::fmt::Display for AstNode {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            AstNode::Program(nodes) => write!(f, "{:#?}", nodes),
            AstNode::Int(n) => write!(f, "{}", n),
            AstNode::Op { left, op, right } => write!(f, "({} {} {})", left, op, right),
        }
    }
}

impl AstNode {
    pub fn optimize(&mut self) {
        match self {
            AstNode::Program(nodes) => {
                for node in nodes {
                    node.optimize();
                }
            }
            AstNode::Int(_) => (),
            AstNode::Op { left, op, right } => {
                left.optimize();
                right.optimize();

                if let (AstNode::Int(left_val), AstNode::Int(right_val)) = (&**left, &**right) {
                    let result = match op.as_str() {
                        "+" => left_val + right_val,
                        "-" => left_val - right_val,
                        "*" => left_val * right_val,
                        "/" => {
                            if *right_val == 0 {
                                return;
                            }
                            left_val / right_val
                        }
                        _ => return,
                    };

                    *self = AstNode::Int(result);
                }
            }
        }
    }
}