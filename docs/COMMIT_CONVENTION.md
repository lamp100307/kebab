# COMMIT CONVENTION

This document describes how to work with commits in this repository

## Branches agreements

### Main branch

Only **@Lynx20wz** and **@lamp100307** have the right to commit here. However there are some rules:

1) Commit message:
    - format: `Kebab v(version)`
    - example: `Kebab v0.1.0`
2) All significant changes (new feature, fix major bugs with indicate commit it was fixed, etc) **must** be described in commit message

#### Commit example

```md
Kebab v0.1.0

- implemented basic features like parser, lexer, variables, etc.
- added commit convention in `COMMIT_CONVENTION.md`.
```

### Dev branch

1) Try to split one big commit into several ones
2) All code's objects must be enclosed in \`\` (backticks)
    - example: ```fix method `parse_expr` in class `Parser`.```

Several actions formats:

1) Commit's label:
    - format: `[type] (message)`
    - example: `[fix] warnings`
2) Extra comments:
    - format: ```- `file.rs`: (type what you did) (what you did).```
    - example: ```- `semantic_error.rs`: deleted unused `variable not found` variant in `SemanticError` enum.```
3) Extra-renaming comments:
    - files or directories: ``` `old_name` -> `new_name`. ```
    - objects: ``` `file.rs`: `old_name` -> `new_name`. ```
4) Extra-move comments:
    - format: ``` `old/path/file.rs` -> `new/path/`. ```
    - example: ``` `COMMIT_CONVENTION.md` -> `docs/` ```

### Others

1) Branches name format:
    - format: `[type]/[for-what]`
    - example: `impl/add-logger`
2) Commit's label:
    - format: `[type] (message)`. The commit type usually matches the branch type
    - example: `[impl] added library for logging`
3) All changes **must** be related to branch name. So, if you create a branch `impl/add-logger`, you **mustn't** work on the parser in this branch

## Types of commit or branches

| Type           | Tag  | Description                                                                                                        |
| -------------- | ---- | ------------------------------------------------------------------------------------------------------------------ |
| implementation | impl | implementing a new feature                                                                                         |
| fix            | fix  | bug fix (if a bug from issue, use `[fix#issue_number] (message)`)                                                  |
| refactoring    | ref  | changes that do not affect the meaning of the code (white-space, formatting, codestyle, etc) or renaming something |
| performance    | perf | changes that improves performance                                                                                  |
| documentation  | docs | adding or updating a documentation                                                                                 |
| tests          | test | adding or updating tests                                                                                           |
