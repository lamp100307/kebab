pub enum Type {
    Int,
}

impl std::fmt::Display for Type {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.as_str())
    }
}

impl Type {
    pub fn as_str(&self) -> &str {
        match self {
            Type::Int => "Int",
        }
    }
}

// pub struct Var {
//     name: String,
//     value: String,
//     var_type: Type
// }
