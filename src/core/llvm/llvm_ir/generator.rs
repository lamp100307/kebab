use super::super::middle_ir::mir_nodes::MirNode;
use crate::core::llvm::middle_ir::mir_nodes::Dependency;

pub struct LlvmIrGenerator {
    stack: u32,
}

impl LlvmIrGenerator {
    pub fn new() -> LlvmIrGenerator {
        LlvmIrGenerator { stack: 0 }
    }

    fn fresh_var(&mut self) -> String {
        self.stack += 1;
        format!("%var{}", self.stack)
    }

    pub fn generate_llvm_ir(&mut self, ast: Vec<MirNode>, dependencies: Vec<Dependency>) -> String {
        let mut ir = String::new();
        //windows target
        ir.push_str("target datalayout = \"e-m:e-i64:64-f80:128-n8:16:32:64-S128\"\n");
        ir.push_str("target triple = \"x86_64-pc-windows-msvc19.44.35221\"\n");
        for dep in dependencies {
            match dep {
                Dependency::Printf => {
                    ir.push_str("declare i32 @printf(i8*, ...)\n");
                }
                Dependency::IntFmt => {
                    ir.push_str(
                        "@int_fmt = private unnamed_addr constant [4 x i8] c\"%d\\0A\\00\"\n",
                    );
                }
            }
        }
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
            MirNode::I32(n) => n.to_string(),
            MirNode::Add { left, right } => {
                let left_val = self.gen_node(&**left, ir);
                let right_val = self.gen_node(&**right, ir);

                let temp_name = self.fresh_var();

                ir.push_str(
                    &format!("  {} = add i32 {}, {}\n", temp_name, left_val, right_val).as_str(),
                );

                temp_name
            }
            MirNode::Sub { left, right } => {
                let left_val = self.gen_node(&**left, ir);
                let right_val = self.gen_node(&**right, ir);

                let temp_name = self.fresh_var();

                ir.push_str(
                    &format!("  {} = sub i32 {}, {}\n", temp_name, left_val, right_val).as_str(),
                );
                temp_name
            }
            MirNode::Mul { left, right } => {
                let left_val = self.gen_node(&**left, ir);
                let right_val = self.gen_node(&**right, ir);

                let temp_name = self.fresh_var();

                ir.push_str(
                    &format!("  {} = mul i32 {}, {}\n", temp_name, left_val, right_val).as_str(),
                );
                temp_name
            }
            MirNode::Div { left, right } => {
                let left_val = self.gen_node(&**left, ir);
                let right_val = self.gen_node(&**right, ir);

                let temp_name = self.fresh_var();

                ir.push_str(
                    &format!("  {} = sdiv i32 {}, {}\n", temp_name, left_val, right_val).as_str(),
                );
                temp_name
            }
            MirNode::Print { left } => {
                let left_val = self.gen_node(&**left, ir);
                match &**left {
                    MirNode::I32(_) => {
                        ir.push_str(&format!("  call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @int_fmt, i32 0, i32 0), i32 {})\n", left_val).as_str());
                    }
                    _ => (),
                }
                "".to_string()
            }
        }
    }
}
