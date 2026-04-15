%{
#include <stdio.h>
#include <stdlib.h>

extern int yylex();
extern int yylineno; // sorszamlalo
extern char* yytext; // akt token szovege
extern int col;

void yyerror(const char *s);
%}

%error-verbose

/* Token deklaraciok */
%token DOG TREAT BARK HOWL SIT CHASE REPEAT TIMES IF ELSE
%token LPAREN RPAREN LBRACE RBRACE SEMICOLON
%token ASSIGN PLUS MINUS MULT DIV MOD
%token EQ NE LT GT LE GE
%token ID NUMBER
%token ERROR

/* Precedencia es asszociativitas */
%left EQ NE
%left LT GT LE GE
%left PLUS MINUS
%left MULT DIV MOD
%right ASSIGN

%%

program:
    DOG ID LBRACE statement_list RBRACE
    | DOG ID LBRACE error RBRACE {
        yyerror("Hiba a program torzseben");
        yyerrok;
    }
    ;

statement_list:
    /* ures */
    | statement_list statement /*tobb utasitas egymas utan*/
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
    TREAT ID ASSIGN expression SEMICOLON
    | TREAT ID SEMICOLON
    ;

assignment:
    ID ASSIGN expression SEMICOLON
    ;

print_stmt:
    BARK expression SEMICOLON
    ;

error_stmt:
    HOWL expression SEMICOLON
    ;

wait_stmt:
    SIT SEMICOLON
    ;

loop_stmt:
    CHASE LPAREN expression RPAREN LBRACE statement_list RBRACE
    ;

repeat_stmt:
    REPEAT expression TIMES LBRACE statement_list RBRACE
    ;

if_stmt:
    IF LPAREN expression RPAREN LBRACE statement_list RBRACE
    | IF LPAREN expression RPAREN LBRACE statement_list RBRACE ELSE LBRACE statement_list RBRACE
    ;

expression:
    NUMBER
    | ID
    | expression PLUS expression
    | expression MINUS expression
    | expression MULT expression
    | expression DIV expression
    | expression MOD expression
    | expression EQ expression
    | expression NE expression
    | expression LT expression
    | expression GT expression
    | expression LE expression
    | expression GE expression
    | LPAREN expression RPAREN
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "[sor: %d, oszlop: %d] Szintaktikai hiba: %s (token: %s)\n",
            yylineno, col, s, yytext);
}

int main() {
    printf("DogLang Parser indul...\n");
    int result = yyparse();
    if (result == 0) {
        printf("Sikeres elemzes!\n");
    } else {
        printf("Elemzes sikertelen!\n");
    }
    return result;
}
