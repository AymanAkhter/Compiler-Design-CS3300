%{
    #include <stdio.h>
    #include <string.h>
    #include "P1.tab.h"
%}

%%
"(" {  yylval.txt = strdup(yytext); return LEFTROUND;}
")" {  yylval.txt = strdup(yytext); return RIGHTROUND;}
"[" {  yylval.txt = strdup(yytext); return LEFTSQUARE;}
"]" {  yylval.txt = strdup(yytext); return RIGHTSQUARE;}
"{" {  yylval.txt = strdup(yytext); return LEFTCURLY;}
"}" {  yylval.txt = strdup(yytext); return RIGHTCURLY;}
"!=" { yylval.txt = strdup(yytext); return NOTEQUAL;}
"class" {  yylval.txt = strdup(yytext); return CLASS;}
"public" {  yylval.txt = strdup(yytext); return PUBLIC;}
"static" {  yylval.txt = strdup(yytext); return STATIC;}
"void" {  yylval.txt = strdup(yytext); return VOID;}
"main" {  yylval.txt = strdup(yytext); return MAIN;}
"String" {  yylval.txt = strdup(yytext); return STRINGG;}
"System.out.println" {  yylval.txt = strdup(yytext); return SYSTEMPRINT;}
";" {  yylval.txt = strdup(yytext); return SEMICOLON;}
"extends" {  yylval.txt = strdup(yytext); return EXTENDS;}
"," {  yylval.txt = strdup(yytext); return COMMA;}
"return" {yylval.txt = strdup(yytext); return RETURN;}
"int" {  yylval.txt = strdup(yytext); return INT;}
"boolean" {  yylval.txt = strdup(yytext); return BOOLEAN;}
"=" {  yylval.txt = strdup(yytext); return EQUAL;}
"if" {  yylval.txt = strdup(yytext); return IF;}
"else" {  yylval.txt = strdup(yytext); return ELSE;}
"do" {  yylval.txt = strdup(yytext); return DO;}
"while" {  yylval.txt = strdup(yytext); return WHILE;}
"&&" {  yylval.txt = strdup(yytext); return ANDAND;}
"||" {  yylval.txt = strdup(yytext); return OROR;}
"!" {  yylval.txt = strdup(yytext); return NOT;}
"<=" {  yylval.txt = strdup(yytext); return LESSEQUAL;}
"+" {  yylval.txt = strdup(yytext); return PLUS;}
"-" {  yylval.txt = strdup(yytext); return MINUS;}
"*" {  yylval.txt = strdup(yytext); return MULTIPLY;}
"/" {  yylval.txt = strdup(yytext); return DIVIDE;}
"." {  yylval.txt = strdup(yytext); return DOT;}
"length" {  yylval.txt = strdup(yytext); return LENGTH;}
"true" {  yylval.txt = strdup(yytext); return TRUE;}
"false" {  yylval.txt = strdup(yytext); return FALSE;}
"this" {  yylval.txt = strdup(yytext); return THIS;}
"new" {  yylval.txt = strdup(yytext); return NEW;}
"#define" {  yylval.txt = strdup(yytext); return HASHDEFINE;}
(\/\/)[^\n\r]+ {;}
[ \n\t\r\f]+ {;}
[a-zA-Z_$][a-zA-Z0-9_$]* { yylval.txt = strdup(yytext);  yylval.txt = strdup(yytext); return ID;}
[0-9]+ {  yylval.txt = strdup(yytext); return NUM;}
. {printf("// Failed to parse macrojava code."); exit(1);}
%%

