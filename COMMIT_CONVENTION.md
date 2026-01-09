# COMMIT CONVENTION

## Branches agreements

### Main branch

Only **@Lynx20wz** and **@lamp100307** have the right to commit here. However there are some rules:

1) Commit's label format: `Kebab v(version)` | `Kebab v0.1.0`
2) All significant changes (new feature, fix major bugs with indicate commit it was fixed, etc) **must** be described in commit message

#### Commit example

```md
Kebab v0.1.0

- implemented basic features like parser, lexer, variables, etc.
- added commit convention in `COMMIT_CONVENTION.md`.
```

### Dev branch

1. Commit's label format: `[type] (message)` | `[fix] warnings`
2. Try to split one big commit into several ones
3. Extra comments format: ```- `file.rs`: (type what you did) (what you did).``` | ```- `semantic_error.rs`: deleted unused `variable not found` variant in `SemanticError` enum.```
4. Renaming comments format: ``` `old_name` -> `new_name`. ``` for files or directories and ``` `file.rs`: `old_name` -> `new_name`. ``` for objects
5. All code's objects must be enclosed in \`\` (backticks) | ```fix method `parse_expr` in class `Parser`.```

### Others

1. Branches name format: `[type]/[for-what]` | `impl/add-logger`
2. Commit's label: free style
3. All changes **must** be related to branch name. So, if you create a branch `impl/add-logger`, you **mustn't** do parser in this branch

## Types of commit or branches

| Type           | Tag  | Description                                                                                                        |
| -------------- | ---- | ------------------------------------------------------------------------------------------------------------------ |
| implementation | impl | implementing a new feature                                                                                         |
| fix            | fix  | bug fix (if a bug from issue, use `[fix#issue_number] (message)`)                                                  |
| refactoring    | ref  | changes that do not affect the meaning of the code (white-space, formatting, codestyle, etc) or renaming something |
| performance    | perf | changes that improves performance                                                                                  |
| documentation  | docs | adding or updating a documentation                                                                                 |
| tests          | test | adding or updating tests                                                                                           |
