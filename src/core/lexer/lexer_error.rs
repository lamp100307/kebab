#[derive(Debug)]
pub enum LexerError {
    InvalidCharacter {
        character: char,
        pos: (u32, u32),
        code: String
    }
}