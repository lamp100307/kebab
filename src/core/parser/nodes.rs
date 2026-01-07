pub enum AstNode {
    Int(i32),
    Op {
        left: Box<AstNode>,
        op: String,
        right: Box<AstNode>
    }
}