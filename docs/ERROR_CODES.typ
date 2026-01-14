#set page(width: 8.5in, height: 11in, margin: 0.75in)
#show raw.where(block: true): it => {
  set text(font: "JetBrains Mono")
  block(
    fill: rgb("#e9f1f8"),
    radius: 0.5em,
    inset: 1em,
    stroke: rgb("#c5d5e6"),
    width: 100%,
    it,
  )
}

= Kebab error codes

The following document describes all errors in the Kebab programming language.

#show outline.entry: it => link(
  it.element.location(),
  it.indented(it.prefix(), it.body()),
)

#outline(title: "Table of contents", depth: 4)

== Error codes format <error-codes-format>

There are several error type formats in Kebab:

#grid(
  columns: (1fr, 4fr),
  row-gutter: 0.3em,
  [LE`xxxx`], [Lexer error],
  [PA`xxxx`], [Parser error],
  [SE`xxxx`], [Semantic error],
  [LV`xxxx`], [LLVM error],
)

where `xxxx` is a numeric error code.

#pagebreak()
== List of errors <list-of-errors>

=== Lexer errors

#text(fill: rgb(0, 0, 150), weight: "bold")[LE`xxxx` – Lexer errors format]

==== LE0001 – Invalid character

This error is raised when the lexer detects an invalid character.

===== Example

```text
[LE0001] Invalid character:
  |
1 | print(№)
  |       ^

help: maybe you accidentally misclicked a character?
```

=== Parser errors

#text(fill: rgb(0, 0, 150), weight: "bold")[PA`xxxx` – Parser errors format]

==== PA0001 – Token Mismatch
