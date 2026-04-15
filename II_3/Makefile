# DogLang Parser Makefile

CC = gcc
FLEX = flex
BISON = bison

CFLAGS = -Wall -Wno-unused-function -Wno-unneeded-internal-declaration
BISON_FLAGS = -d -v

TARGET = parser
SOURCES = doglang.l doglang.y

all: $(TARGET)

$(TARGET): lex.yy.c doglang.tab.c
	$(CC) $(CFLAGS) lex.yy.c doglang.tab.c -o $(TARGET)

lex.yy.c: doglang.l doglang.tab.h
	$(FLEX) doglang.l

doglang.tab.c doglang.tab.h: doglang.y
	$(BISON) $(BISON_FLAGS) doglang.y

test: $(TARGET)
	@echo "=== Testing valid program ==="
	./$(TARGET) < test_valid.dog
	@echo ""
	@echo "=== Testing syntax errors ==="
	./$(TARGET) < test_error.dog || true
	@echo ""
	@echo "=== Testing semantic errors ==="
	./$(TARGET) < test_semantic.dog || true

run_fibonacci: $(TARGET)
	@echo "=== Compiling Fibonacci ==="
	./$(TARGET) < fibonacci.dog && gcc output.c -o fibonacci && ./fibonacci

run_gcd: $(TARGET)
	@echo "=== Compiling GCD ==="
	./$(TARGET) < lnko.dog && gcc output.c -o gcd && ./gcd

clean:
	rm -f lex.yy.c doglang.tab.c doglang.tab.h doglang.output $(TARGET)
	rm -f output.c fibonacci gcd

.PHONY: all test run_fibonacci run_gcd clean