# Kebab Language: 

## Main info

Write Fast, Run Faster!

Kebab is a statically typed programming language that compiles to C. This means you get C-like performance (because that's what ultimately runs) with a more convenient and safer syntax.
🌟 Key Features

    - ⚡ C-like Speed - compilation to C delivers performance comparable to native code
    - 🔒 Type Safety - strong static typing prevents entire classes of bugs at compile time
    - 🔄 Seamless Interop - easily integrates with any language that can call C (which is almost all of them!)
    - 🛡️ Unsafe Blocks - drop down to low-level control when you need it with unsafe sections
    - 🎯 Clean Syntax - modern and readable without unnecessary ceremony
    - 🧠 Type Inference - let the compiler figure out types when you don't want to spell them out

## 📦 Example Code

```kebab
// Simple expression
print(1 + 2 * 4)  // Output: 9

// Variables with explicit types
let x: int = 42

// Type inference in action
let y = 13        // int automatically inferred
print(x + y)      // Output: 55

// Functions
fn add(x: int, y: int) -> int {
    x + y         // Implicit return (last expression)
}

// Alternative return type syntax
fn sub(x: int, y: int) {
    x - y
} -> int          // Return type specified after the block

// Unsafe blocks for low-level magic
unsafe {
    // Direct memory access
    const vga = 0x8B6000;
    // Do something dangerous but necessary
    *vga = 0x0F;
}
```

## 🚀 Quick Start

Building from Source

```bash

# Clone the repository
git clone https://github.com/lamp100307/kebab
cd kebab

# Compile the compiler (yes, it's self-hosted!)
dart compile exe bin/kebab.dart -o kebab

# Add to PATH (optional)
sudo mv kebab /usr/local/bin/

Installation Options
    GitHub Releases - download pre-built binaries from the latest release
    AUR (Arch Linux) - coming soon!
```

## Running Your First Program

```bash
# Create a test file
echo 'print("Hello, Kebab!")' > hello.keb

# Compile and run
kebab hello.keb
./hello

# Or in one line
kebab hello.keb && ./hello
```

## 🎯 Why Kebab?
Perfect For:
    - Systems Programming - with unsafe blocks when you need them
    - Embedded Systems - tiny footprint, C interoperability
    - Learning Compilers - clean codebase, easy to understand
    - Performance-Critical Apps - C-level speed with modern syntax

What Makes Kebab Special:
    - Compiles to C - battle-tested backend, amazing optimization
    - Gradual Unsafety - safe by default, unsafe when necessary
    - Predictable Performance - no hidden GC or runtime overhead
    - Small Runtime - what you write is what runs
