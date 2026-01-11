# Kebab error codes

There are described all errors in the Kebab programming language.

## Table of contents

- [Error codes format](#error-codes-format)
- [Lexer errors](#lexer-errors)
  - [LE0001 - Invalid character](#le0001---invalid-character)
- [Parser errors](#parser-errors)
  - [PA0001 - Token Mismatch](#pa0001---token-mismatch)
  - [PA0002 - Unexpected EOF](#pa0002---unexpected-eof)
- [Semantic errors](#semantic-errors)
  - [SE0001 - Type Mismatch](#se0001---type-mismatch)
  - [SE0002 - Unsupported AST Node](#se0002---unsupported-ast-node)
- [LLVM errors](#llvm-errors)

## Error codes format

There are several error type formats in the Kebab:

- LExxxx - Lexer error
- PAxxxx - Parser error
- SExxxx - Semantic error
- LVxxxx - LLVM error

where `xxxx` is error code.

## List of errors

### Lexer errors

LExxxx - lexer errors format

#### LE0001 - Invalid character

This error is raised when the lexer detects an invalid character.

```text
[LE0001] Invalid character:
  |
1 | print(№)
  |       ^

help: maybe you accidentally misclicked a character?
```

### Parser errors

PAxxxx - parser errors format

#### PA0001 - Token Mismatch

This error is raised when the parser detects a token mismatch.

```text
[PA0001] Token Mismatch:
    expected: TokenType::LParen("(")
    got: TokenType::Int("2")
  |
1 | print 2
  |       ^

help: maybe you forgot a `(`
```

#### PA0002 - Unexpected EOF

EOF - End Of File

This error is raised when the parser detects an unexpected end of file.

```text
[PA0002] Unexpected EOF:
  |
1 | print(
  |       ^

help: maybe you forgot a `)`
```

### Semantic errors

SExxxx - semantic errors format

#### SE0001 - Type Mismatch

This error is raised when the semantic analyzer detects a type mismatch.

```text
[SE0001] Type Mismatch:
    left: Type::Int("2")
    right: Type::Str("2")
  |
1 | print(2 + "2")
  |            ^

help: maybe "2" should be converted to Type::Int
```

#### SE0002 - Unsupported AST Node

... <!-- @lamp100307 check `src/core/semantic/semantic.rs:72` -->

### LLVM errors

LVxxxx - LLVM errors format
