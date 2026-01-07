use std::fmt;

#[derive(Debug, Clone)]
pub struct Span {
    pub start_line: usize,
    pub start_col: usize,
    pub source_snippet: String,
}

pub trait ErrorDisplay {
    // ? Why are these functions and not fields?
    fn error_code(&self) -> &'static str;
    fn error_title(&self) -> String;
    fn span(&self) -> &Span;
    fn help(&self) -> Option<String>;
    fn notes(&self) -> Vec<String>;

    fn format_error(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(
            f,
            "\x1b[1;31merror\x1b[0m[{}]: {}\n",
            self.error_code(),
            self.error_title()
        )?;

        let span = self.span();

        write!(
            f,
            "  \x1b[1;34m-->\x1b[0m input:{}:{}\n",
            span.start_line, span.start_col
        )?;

        write!(f, "   \x1b[1;34m|\x1b[0m\n")?;

        let line_num = format!("{:3}", span.start_line);
        write!(
            f,
            "{} \x1b[1;34m|\x1b[0m {}\n",
            line_num, span.source_snippet
        )?;

        let pointer_padding = " ".repeat(span.start_col + 1);
        write!(f, "   \x1b[1;34m|\x1b[0m {}^\n", pointer_padding)?;

        write!(f, "   \x1b[1;34m|\x1b[0m\n")?;

        if let Some(help_msg) = self.help() {
            write!(
                f,
                "   \x1b[1;34m=\x1b[0m \x1b[1;33mhelp\x1b[0m: {}\n",
                help_msg
            )?;
        }

        for note in self.notes() {
            write!(f, "   \x1b[1;34m=\x1b[0m \x1b[1;33mnote\x1b[0m: {}\n", note)?;
        }

        Ok(())
    }
}
