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
	@echo "=== Testing error program ==="
	./$(TARGET) < test_error.dog || true

clean:
	rm -f lex.yy.c doglang.tab.c doglang.tab.h doglang.output $(TARGET)

.PHONY: all test clean
