%{
#include <iostream>
#include "grammar.tab.h"
#include <cstring>

extern int lineNum;
extern std::string class_name;

void yy_beg_loc();
void yy_end_loc();
%}

%option noyywrap

%s LOCAL

%%

"//".*                              ;   // skip single-line comments
"/*"(.|\n)*?"*/"                    ;   // skip block comments
[ \t\r\n]+                          ;   // ignore whitespace

"class"                             {
                                        yylval.s = strdup(yytext);
                                        return CLASS;
                                    }
("public"|"private"|"protected")    { return ACC; }


<LOCAL>("int"|"char"|"float"|"double"|"void"|"bool"|"string") {
    yylval.s = strdup(yytext);
    return LTYPE;
}

("int"|"char"|"float"|"double"|"void"|"bool"|"string") {
    yylval.s = strdup(yytext);
    return TYPE;
}

";"+                                { return SC; }
"{"                                 { return '{'; }
"}"                                 { return '}'; }
"("                                 { return '('; }
")"                                 { return ')'; }
","                                 { return ','; }
":"									{ return ':'; }
"="									{ return '='; }

[0-9]+								{  yylval.d = atoi(yytext); return NUM; }

[A-Za-z_][A-Za-z0-9_]*              {
                                        yylval.s = strdup(yytext);
                                        if(class_name == yytext)
                                            return CNAME;
                                        return NAME;
                                    }

.                                   ;

%%

void yy_beg_loc() { BEGIN(LOCAL); }
void yy_end_loc() { BEGIN(INITIAL); }
