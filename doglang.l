%option noyywrap
%option yylineno

%{
#include <stdio.h>
#include "doglang.tab.h"

int col = 1;

void update_col() {
    col += yyleng;
}
%}

ID      [A-Za-z_][A-Za-z0-9_]*
        /* betuvel vagy alahuzassal kezdodik */
NUMBER  [0-9]+

%%

\n                  { col = 1; }
[ \t\r]+            { col += yyleng; }
"//".*              { col += yyleng; }

"DOG"               { update_col(); return DOG; }
"TREAT"             { update_col(); return TREAT; }
"BARK"              { update_col(); return BARK; }
"HOWL"              { update_col(); return HOWL; }
"SIT"               { update_col(); return SIT; }
"CHASE"             { update_col(); return CHASE; }
"REPEAT"            { update_col(); return REPEAT; }
"TIMES"             { update_col(); return TIMES; }
"IF"                { update_col(); return IF; }
"ELSE"              { update_col(); return ELSE; }

"=="                { update_col(); return EQ; }
"!="                { update_col(); return NE; }
"<="                { update_col(); return LE; }
">="                { update_col(); return GE; }

"="                 { update_col(); return ASSIGN; }
"<"                 { update_col(); return LT; }
">"                 { update_col(); return GT; }
"+"                 { update_col(); return PLUS; }
"-"                 { update_col(); return MINUS; }
"*"                 { update_col(); return MULT; }
"/"                 { update_col(); return DIV; }
"%"                 { update_col(); return MOD; }

"("                 { update_col(); return LPAREN; }
")"                 { update_col(); return RPAREN; }
"{"                 { update_col(); return LBRACE; }
"}"                 { update_col(); return RBRACE; }
";"                 { update_col(); return SEMICOLON; }

{NUMBER}            { update_col(); return NUMBER; }
{ID}                { update_col(); return ID; }

.                   {
                      fprintf(stderr, "[sor: %d, oszlop: %d, hossz: %d] Nem letezik! %s\n",
                              yylineno, col, (int)yyleng, yytext);
                      col += yyleng;
                      return ERROR;
                    }

%%