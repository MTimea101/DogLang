# DogLang – Custom Programming Language

DogLang is a custom-designed programming language built using Flex (lexical analysis) and Bison (syntax analysis).

This project focuses on understanding how programming languages work internally, including tokenization, parsing, grammar definition, and error handling.

---

## Features

- Custom language syntax inspired by dog-themed keywords 🐾
- Lexical analysis using Flex
- Syntax parsing using Bison (LALR(1) parser)
- Support for:
  - Variable declaration (TREAT)
  - Assignment
  - Printing (BARK)
  - Error messages (HOWL)
  - Control structures (IF, ELSE)
  - Loops (CHASE, REPEAT)
- Expression evaluation with operator precedence
- Error handling with line and column reporting
- Recovery from syntax errors

---

## Language Example

```doglang
DOG program {
    TREAT x = 5;
    BARK x;

    IF (x > 3) {
        BARK x;
    } ELSE {
        HOWL x;
    }

    REPEAT 3 TIMES {
        SIT;
    }
}
```

---

## Project Structure

.
├── doglang.l
├── doglang.y
├── Makefile
├── test_valid.dog
├── test_error.dog
├── parser

---

##  Build & Run

### Build
make

### Run
./parser < test_valid.dog

### Test
make test

### Clean
make clean

---

## Manual Build

bison -d -v doglang.y
flex doglang.l
gcc lex.yy.c doglang.tab.c -o parser
./parser < test_valid.dog

---

## Error Handling

The parser provides detailed error messages including line and column numbers.

---

## Learning Goals

- Compiler design basics
- Lexical analysis
- Syntax parsing
- Error handling
- Programming language design

---

## Author

Timea Majercsik

---

## Notes

This is an educational project focused on language design and parsing.
