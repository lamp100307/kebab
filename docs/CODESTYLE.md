# KSR - Kebab Syntax Rules

This document contains recommendations how to write Kebab code like [Python's PEP8](https://peps.python.org/pep-0008/).

## Table of contents

The KSR is divided into `6` chapters

- [KSR-1: Comments](#ksr-1-comments)
- [KSR-2: Format and indentation](#ksr-2-format-and-indentation)
- [KSR-3: Naming](#ksr-3-naming)
- [KSR-4: Result and optional](#ksr-4-result-and-optional)
- [KSR-5: File structure](#ksr-5-file-structure)
- [KSR-6: Others](#ksr-6-others)

## KSR-1: Comments

### 1.1. Comments style

There are 7 types of comments:

| Type                  | Syntax    | Example                                        |
| --------------------- | --------- | ---------------------------------------------- |
| one-line comment      | //        | // This is an example of all types of comments |
| documentation comment | ///       | /// This is very important var!                |
| question comment      | //?       | //? Why?                                       |
| todo comment          | // TODO:  | // TODO: rename var                            |
| fixme comment         | // FIXME: | // FIXME: fix this bug                         |
| multi-line comment    | /* */     | /* There may be write very important things */ |
| docstring comment     | //* *//   | //* Function sums two numbers *//              |

```rust
// This is an example of all types of comments. (one-line comment)
/// This is very important var!                 (documentation comment)
//? Why?                                        (question comment)
let x = 5  // TODO: rename var                  (todo comment)
let x = 6  // FIXME: shadow var                 (fixme comment)

/*
 There may be write very important things.
 (multi-line comment)
*/

fn add(a: int, b: int) -> int {
//* Function sums two numbers

There may place extra information about the function

Args:
    a: int - first number
    b: int - second number

Returns:
    int - sum of a and b

Example:
    add(2, 3) -> 5
*// (docstring comment)
    return a + b // keyword "return" is optional in the Kebab
}
```

## KSR-2: Format and indentation

### 2.1. Indentations

4 spaces better than one tab

```rust
// ✅ correct
fn main() {
    print("Hello, world!")
}

// ❌ wrong - tab or 2 spaces
fn main() {
  print("Hello, world!")   // ❌ 2 spaces
	print("Hello, world!") // ❌ tab
}
```

### 2.2. Curly braces

"{" on the same line where it is used

```rust
// ✅ correct
fn add(x: int, y: int) -> int {
    return x + y
}

if x > 0 {
    print("positive")
} else {
    print("non-positive")
}

// ❌ wrong
fn add(x: int, y: int) -> int
{                         // ❌ "{" on the next line
    return x + y
}

if x > 0
{                         // ❌ "{" on the next line
    print("positive")
}
```

### 2.3. Operators

Around operators there should be a space

```rust
// ✅ correct
let result = a + b * c
if x > 0 && y < 10 { ... }

// ❌ wrong
let result=a+b*c        // ❌ there aren't spaces
if x>0&&y<10 { ... }    // ❌ there aren't spaces
```

Exceptions: `?`, `++`, `--` `^`

```rust
// ✅ correct
let result = a^b * c
result++
```

### 2.4 Space after punctuation

After commas, colons and arrows there should be a space

```rust
// ✅ correct
let colors = ["red", "green", "blue"]  
fn add(x: int, y: int) -> int { ... }      
let name: string = "John"              

// ❌ wrong
let colors = ["red","green","blue"]    // ❌ there aren't spaces
fn add(x:int,y:int)->int { ... }       // ❌ there aren't spaces
let name:string = "John"               // ❌ there isn't space
```

### 2.5. Definition schemas and classes

For schemas and classes, each field, function should be on a new line

```rust
// ✅ correct
schema User {
    id: string,
    name: string,
    email: string,
}

// ❌ wrong
schema User { id: string, name: string, email: string }  // ❌ everything is on the same line
```

### 2.6. Conditional statements

Else on the same line as the closing brace of if

```rust
// ✅ correct
if x < 10 {
    print("x < 10")
} else if x == 10 {
    print("x = 10")
} else {
    print("x > 10")
}

// ❌ wrong
if x < 10 {
    print("x < 10")
}                    
else if x == 10 {   // ❌ "else if" is on the next line
    print("x = 10")
}             
else {              // ❌ "else" is on the next line
    print("x > 10")
}
```

## KSR-3: Naming

### 3.1. Variables and functions

For variables and functions, names should be in kebab-case

```rust
// ✅ correct
let user-name = "John"
fn kebab-func() { ... }

// ❌ wrong
let user_name = "John"      // ❌ snake_case
let userName = "Maks"       // ❌ camelCase
let TotalAmount = 1234      // ❌ PascalCase
```

### 3.2. Constants

For constants, names should be in SCREAMING_SNAKE_CASE

```rust
// ✅ correct
let$ MAX_SIZE = 1024
let$ DEFAULT_TIMEOUT = 30

// ❌ wrong
let$ developer-github = "@Lynx20wz"  // ❌ kebab-case
let$ max_size = 1024                 // ❌ snake_case
let$ maxSize = 1024                  // ❌ camelCase
let$ default_timeout = 30            // ❌ snake_case
```

### 3.3. Classes and schemas

For classes and schemas, names should be in camelCase

```rust
// ✅ correct
class userProfile { ... }
schema apiResponse { ... }

// ❌ wrong
class user-profile { ... }   // ❌ kebab-case
schema api_response { ... }  // ❌ snake-case
```

### 3.4. Mixins

For mixins, names should be in PascalCase

```rust
mixin JsonConverterMixin {
    fn to-json(self) -> String { ... }
}

mixin json_converter { ... } // ❌ snake-case
```

## KSR-4: Result and Optional

### 4.1. "?" operator <!-- ? can we call it null-check operator? -->

It is better to use "?" for checking Result or Optional to avoid errors

```rust
fn res(x: int) -> Result(int, Err) {
    if x == 2 {
        ok(x)
    } else {
        err(Err("x != 2!"))
    }
}

fn main() {
    // ✅ correct
    let right = res(3)? {
        ok(x) => x
    }
    print(x)

    // ❌ wrong
    let wrong = res(3) 
    print(x)
}
```

## KSR-5: File structure

### 5.1. The order of definitions

Recommended order of definitions:

1. Imports
2. Constants
3. Mixins
4. Schemas
5. Classes
6. Functions
7. Others

```rust
// 1. Imports
import std.io
import utils.math

// 2. Constants
let$ VERSION = "1.0.0"
let$ API_URL = "https://api.example.com"

// 3. Mixins
mixin Display { ... }

// 4. Schemas
schema User { ... }

// 5. Classes 
class UserService { ... }

// 6. Functions
fn foo() { ... }

// 7. Others
let x = 5
```

### 5.2. The order of imports

Recommended order of imports:

1. std
2. third party
3. global
4. local

```rust
// standard library
import std.io      
import std.math
import std.collections

// third party library
import third_party
import http.client

// global modules
import @node       

// local modules
import utils       
import models
```

## KSR-6: Others

### 6.1. Numbers

Divide the digits in large numbers with "_"

```rust
// ✅ correct
let billion = 1_000_000_000
let hex = 0xFF_FF_FF
let binary = 0b1010_1010

// ❌ wrong
let billion = 1000000000           // ❌ difficult to read
```

#### 6.2. Line length

Recommended line length: 90 characters

```rust
// ✅ correct
let long_string = """This is a very long string, that should be split
into multiple lines for better readability."""

if very_long_condition_one && 
   very_long_condition_two &&
   very_long_condition_three { ... }

if very_long_condition_one  
    && very_long_condition_two 
    && very_long_condition_three { ... }

fn very_long_function_signature(
    param1: string,
    param2: int,
    param3: bool
) -> Result<int> { ... }
```
