# Kebab - modern programming language

Kebab - the new compile language surpasses C in convenience and is not inferior in speed! Tired of `malloc/free` in C? Do you not stand the slowness of Python? Is Rust very difficult?

## Features

✅ **Convenient syntax** - without semicolons
✅ **C-like speed** - compile into LLVM and optimizations
✅ **Security** - checks at the compilation stage
✅ **Modern features**
    - String interpolation: `"Hello $name!"`
    - Decorators: `#time() fn foo() { ... }`
    - Generators: `gen numbers() { yield i }`

### Compare with C

```c
#include<stdio.h>
int main() {
    for(int i = 0; i < 100000; i++) {
        printf("%d\n", i);
    }
}
```

```rust
fn main() => for i in 100000 => print(i)
```

Besides the fact that this code is the same in meaning, it is also the same in execution speed!

| place | language       | time      | difference |
| ----- | -------------- | --------- | ---------- |
| 1     | ⚡️ kebab       | 0.046490s | -          |
| 2     | ⚡️ C (GCC)     | 0.046698s | +0.4%      |
| 3     | ⚡️ Rust        | 0.106954s | +130.1%    |
| 4     | ⚡️ C++         | 0.146590s | +215.3%    |
| 5     | 🐍 Python      | 0.232401s | +399.9%    |
| 6     | 🐍 JavaScript  | 0.276098s | +493.9%    |

🐍 - interpreted | ⚡️ - compiled

## Installation

1) Download the release 1.0.0 beta or the latest one that will be available on [GitHub](https://github.com/lamp100307/kebab)
2) Add to PATH
3) Run `kebab new <project_name>`
4) Programming and enjoy!

### Build from source code

Requirements: `rustc`

```bash
git clone https://github.com/lamp100307/kebab.git
cd kebab
cargo build
```

## Links

- 📚 [Documentation](https://link/)
- 🗺️ [Roadmap](https://link/)
- 💬 [Community](https://link/)
