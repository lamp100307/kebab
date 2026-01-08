pub enum Type {
    Int
}

impl Type {
    pub fn as_str(&self) -> &str {
        match self {
            Type::Int => "Int"
        }
    }
}

pub struct Var {
    name: String,
    value: String,
    var_type: Type
}

