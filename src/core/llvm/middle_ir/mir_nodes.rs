
#[derive(Debug)]
pub enum MirNode {
    I32(i32),
    Add { left: Box<MirNode>, right: Box<MirNode> },
    Sub { left: Box<MirNode>, right: Box<MirNode> },
    Mul { left: Box<MirNode>, right: Box<MirNode> },
    Div { left: Box<MirNode>, right: Box<MirNode> },
}

impl std::fmt::Display for MirNode {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            MirNode::I32(n) => write!(f, "{}", n),
            MirNode::Add { left, right } => write!(f, "({} + {})", left, right),
            MirNode::Sub { left, right } => write!(f, "({} - {})", left, right),
            MirNode::Mul { left, right } => write!(f, "({} * {})", left, right),
            MirNode::Div { left, right } => write!(f, "({} / {})", left, right),
        }
    }
}