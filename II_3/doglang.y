%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yylex();
extern int yylineno;
extern char* yytext;
extern int col;

void yyerror(const char *s);

// szimbolumtabla struktura
#define MAX_SYMBOLS 100

typedef struct {
    char* name;
    int line;
    int col;
    int initialized;
} Symbol;

Symbol symbol_table[MAX_SYMBOLS];
int symbol_count = 0;
int semantic_errors = 0;  

// szimbolumtabla fuggvenyek
int symbol_lookup(const char* name) {
    for (int i = 0; i < symbol_count; i++) {
        if (strcmp(symbol_table[i].name, name) == 0) {
            return i;
        }
    }
    return -1;
}

int symbol_add(const char* name, int line, int col, int initialized) {
    if (symbol_count >= MAX_SYMBOLS) {
        fprintf(stderr, "[sor: %d, oszlop: %d] Hiba: Tul sok valtozo!\n", line, col);
        semantic_errors++;
        return -1;
    }
    
    // ellen, hogy mar letezik-e
    int idx = symbol_lookup(name);
    if (idx != -1) {
        fprintf(stderr, "[sor: %d, oszlop: %d] Szemantikai hiba: '%s' valtozo mar deklaralva volt (sor: %d, oszlop: %d)\n",
                line, col, name, symbol_table[idx].line, symbol_table[idx].col);
        return -1;
    }
    
    // hozzaadjuk
    symbol_table[symbol_count].name = strdup(name);
    symbol_table[symbol_count].line = line;
    symbol_table[symbol_count].col = col;
    symbol_table[symbol_count].initialized = initialized;
    symbol_count++;
    
    return symbol_count - 1;
}

void symbol_check_usage(const char* name, int line, int col) {
    int idx = symbol_lookup(name);
    if (idx == -1) {
        fprintf(stderr, "[sor: %d, oszlop: %d] Szemantikai hiba: '%s' valtozo nem lett deklaralva\n",
                line, col, name);
        semantic_errors++;
    }
}

// kodgeneralas
FILE* output_file = NULL;
int indent_level = 0;

void indent() {
    for (int i = 0; i < indent_level; i++) {
        fprintf(output_file, "    ");
    }
}

%}

%error-verbose

%union {
    int num;
    char* str;
}

%token DOG TREAT BARK HOWL SIT CHASE REPEAT TIMES IF ELSE
%token LPAREN RPAREN LBRACE RBRACE SEMICOLON
%token ASSIGN PLUS MINUS MULT DIV MOD
%token EQ NE LT GT LE GE
%token <str> ID
%token <num> NUMBER
%token ERROR

%type <str> expression

%left EQ NE
%left LT GT LE GE
%left PLUS MINUS
%left MULT DIV MOD
%right ASSIGN

%%

program:
    DOG ID LBRACE {
        // file megnyitasa es header generalasa
        output_file = fopen("output.c", "w");
        if (!output_file) {
            fprintf(stderr, "Hiba: Nem sikerult megnyitni az output.c fajlt!\n");
            exit(1);
        }
        fprintf(output_file, "// Generalt kod a DogLang programbol: %s\n", $2);
        fprintf(output_file, "#include <stdio.h>\n\n");
        fprintf(output_file, "int main() {\n");
        indent_level = 1;
        free($2);
    }
    statement_list RBRACE {
        // lezaras
        indent();
        fprintf(output_file, "return 0;\n");
        fprintf(output_file, "}\n");
        fclose(output_file);
        printf("\n==> C kod sikeresen generalt: output.c\n");
    }
    | DOG ID LBRACE error RBRACE {
        yyerror("Hiba a program torzseben");
        yyerrok;
    }
    ;

statement_list:
    /* ures */
    | statement_list statement
    ;

statement:
    declaration
    | assignment
    | print_stmt
    | error_stmt
    | wait_stmt
    | loop_stmt
    | repeat_stmt
    | if_stmt
    | error SEMICOLON {
        yyerror("Hibas utasitas");
        yyerrok;
    }
    ;

declaration:
    TREAT ID ASSIGN expression SEMICOLON {
         // hozzaadjuk a szimbolumtablahoz ( inicializalva)
        symbol_add($2, yylineno, col, 1);
        
        // C kod generalas
        indent();
        fprintf(output_file, "int %s = ", $2);
        fprintf(output_file, "%s;\n", $4);
        
        free($2);
        free($4);
    }
    | TREAT ID SEMICOLON {
        // hozzaadjuk a szimbolumtablahoz (nem inicializalva)
        symbol_add($2, yylineno, col, 0);
        
        // C kod generalas
        indent();
        fprintf(output_file, "int %s;\n", $2);
        
        free($2);
    }
    ;

assignment:
    ID ASSIGN expression SEMICOLON {
        // ellen, hogy letezik-e a valtozo
        symbol_check_usage($1, yylineno, col);
        
        // C kod generalas
        indent();
        fprintf(output_file, "%s = %s;\n", $1, $3);
        
        free($1);
        free($3);
    }
    ;

print_stmt:
    BARK expression SEMICOLON {
        // C kod generalas
        indent();
        fprintf(output_file, "printf(\"%%d\\n\", %s);\n", $2);
        free($2);
    }
    ;

error_stmt:
    HOWL expression SEMICOLON {
        // C kod generalas
        indent();
        fprintf(output_file, "fprintf(stderr, \"HOWL: %%d\\n\", %s);\n", $2);
        free($2);
    }
    ;

wait_stmt:
    SIT SEMICOLON {
        // C kod generalas (wait/sleep)
        indent();
        fprintf(output_file, "// SIT - pause\n");
    }
    ;

loop_stmt:
    CHASE LPAREN expression RPAREN {
        indent();
        fprintf(output_file, "while (%s) {\n", $3);
        indent_level++;
        free($3);
    }
    LBRACE statement_list RBRACE {
        indent_level--;
        indent();
        fprintf(output_file, "}\n");
    }
    ;

repeat_stmt:
    REPEAT expression TIMES {
        indent();
        fprintf(output_file, "for (int _i = 0; _i < %s; _i++) {\n", $2);
        indent_level++;
        free($2);
    }
    LBRACE statement_list RBRACE {
        indent_level--;
        indent();
        fprintf(output_file, "}\n");
    }
    ;

if_stmt:
    IF LPAREN expression RPAREN LBRACE {
        indent();
        fprintf(output_file, "if (%s) {\n", $3);
        indent_level++;
        free($3);
    }
    statement_list RBRACE else_part
    ;

else_part:
    /* ures */ {
        indent_level--;
        indent();
        fprintf(output_file, "}\n");
    }
    | ELSE LBRACE {
        indent_level--;
        indent();
        fprintf(output_file, "} else {\n");
        indent_level++;
    }
    statement_list RBRACE {
        indent_level--;
        indent();
        fprintf(output_file, "}\n");
    }
    ;

expression:
    NUMBER {
        char buffer[32];
        sprintf(buffer, "%d", $1);
        $$ = strdup(buffer);
    }
    | ID {
        // ellen, hogy letezik-e a valtozo
        symbol_check_usage($1, yylineno, col);
        $$ = strdup($1);
        free($1);
    }
    | expression PLUS expression {
        char* result = malloc(strlen($1) + strlen($3) + 10);
        sprintf(result, "(%s + %s)", $1, $3);
        $$ = result;
        free($1);
        free($3);
    }
    | expression MINUS expression {
        char* result = malloc(strlen($1) + strlen($3) + 10);
        sprintf(result, "(%s - %s)", $1, $3);
        $$ = result;
        free($1);
        free($3);
    }
    | expression MULT expression {
        char* result = malloc(strlen($1) + strlen($3) + 10);
        sprintf(result, "(%s * %s)", $1, $3);
        $$ = result;
        free($1);
        free($3);
    }
    | expression DIV expression {
        char* result = malloc(strlen($1) + strlen($3) + 10);
        sprintf(result, "(%s / %s)", $1, $3);
        $$ = result;
        free($1);
        free($3);
    }
    | expression MOD expression {
        char* result = malloc(strlen($1) + strlen($3) + 10);
        sprintf(result, "(%s %% %s)", $1, $3);
        $$ = result;
        free($1);
        free($3);
    }
    | expression EQ expression {
        char* result = malloc(strlen($1) + strlen($3) + 10);
        sprintf(result, "(%s == %s)", $1, $3);
        $$ = result;
        free($1);
        free($3);
    }
    | expression NE expression {
        char* result = malloc(strlen($1) + strlen($3) + 10);
        sprintf(result, "(%s != %s)", $1, $3);
        $$ = result;
        free($1);
        free($3);
    }
    | expression LT expression {
        char* result = malloc(strlen($1) + strlen($3) + 10);
        sprintf(result, "(%s < %s)", $1, $3);
        $$ = result;
        free($1);
        free($3);
    }
    | expression GT expression {
        char* result = malloc(strlen($1) + strlen($3) + 10);
        sprintf(result, "(%s > %s)", $1, $3);
        $$ = result;
        free($1);
        free($3);
    }
    | expression LE expression {
        char* result = malloc(strlen($1) + strlen($3) + 10);
        sprintf(result, "(%s <= %s)", $1, $3);
        $$ = result;
        free($1);
        free($3);
    }
    | expression GE expression {
        char* result = malloc(strlen($1) + strlen($3) + 10);
        sprintf(result, "(%s >= %s)", $1, $3);
        $$ = result;
        free($1);
        free($3);
    }
    | LPAREN expression RPAREN {
        $$ = $2;
    }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "[sor: %d, oszlop: %d] Szintaktikai hiba: %s (token: %s)\n",
            yylineno, col, s, yytext);
}

int main() {
    printf("DogLang Parser + Code Generator indul...\n");
    int result = yyparse();
    if (result == 0 && semantic_errors == 0) {
        printf("Sikeres elemzes!\n");
        printf("\nSzimbolumtabla:\n");
        printf("===============\n");
        for (int i = 0; i < symbol_count; i++) {
            printf("  %s (sor: %d, oszlop: %d, init: %s)\n",
                   symbol_table[i].name,
                   symbol_table[i].line,
                   symbol_table[i].col,
                   symbol_table[i].initialized ? "igen" : "nem");
        }
    } else {
        printf("Elemzes sikertelen!\n");
    }
    return (result == 0 && semantic_errors == 0) ? 0 : 1;
 }