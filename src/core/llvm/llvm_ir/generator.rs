use super::super::middle_ir::mir_nodes::MirNode;

pub struct LlvmIrGenerator {
    stack: u32
}

impl LlvmIrGenerator {
    pub fn new() -> LlvmIrGenerator {
        LlvmIrGenerator {
            stack: 0
        }
    }

    fn fresh_var(&mut self) -> String {
        self.stack += 1;
        format!("%var{}", self.stack)
    }

    pub fn generate_llvm_ir(&mut self, ast: Vec<MirNode>) -> String {
        let mut ir = String::new();
        ir.push_str("define i32 @main() {\n");
        ir.push_str("entry:\n");

        for node in ast {
            self.gen_node(&node, &mut ir);
        }

        ir.push_str("  ret i32 0\n");

        ir.push_str("}\n");
        ir
    }

    fn gen_node(&mut self, node: &MirNode, ir: &mut String) -> String {
        match node {
            MirNode::I32(n) => {
                n.to_string()
            }
            MirNode::Add { left, right } => {
                let left_val = self.gen_node(&**left, ir);
                let right_val = self.gen_node(&**right, ir);

                let temp_name = self.fresh_var();

                ir.push_str(&format!("  {} = add i32 {}, {}\n", temp_name, left_val, right_val).as_str());

                temp_name
            }
            MirNode::Sub { left, right } => {
                let left_val = self.gen_node(&**left, ir);
                let right_val = self.gen_node(&**right, ir);

                let temp_name = self.fresh_var();

                ir.push_str(&format!("  {} = sub i32 {}, {}\n", temp_name, left_val, right_val).as_str());
                temp_name
            }
            MirNode::Mul { left, right } => {
                let left_val = self.gen_node(&**left, ir);
                let right_val = self.gen_node(&**right, ir);

                let temp_name = self.fresh_var();

                ir.push_str(&format!("  {} = mul i32 {}, {}\n", temp_name, left_val, right_val).as_str());
                temp_name
            }
            MirNode::Div { left, right } => {
                let left_val = self.gen_node(&**left, ir);
                let right_val = self.gen_node(&**right, ir);

                let temp_name = self.fresh_var();

                ir.push_str(&format!("  {} = sdiv i32 {}, {}\n", temp_name, left_val, right_val).as_str());
                temp_name
            }
        }
    }
}