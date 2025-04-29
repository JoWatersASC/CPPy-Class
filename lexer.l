%{
#include <iostream>
#include "grammar.tab.h"
#include <cstring>

extern int lineNum;
%}

%option noyywrap

%%

"//".*                              ;   // skip single-line comments
"/*"(.|\n)*?"*/"                    ;   // skip block comments
[ \t\r\n]+                          ;   // ignore whitespace

"class"                             {
                                        yylval.s = strdup(yytext);
                                        return CLASS;
                                    }
("public"|"private"|"protected")    { return ACC; }
";"+                                { return SC; }
"{"                                 { return '{'; }
"}"                                 { return '}'; }
"("                                 { return '('; }
")"                                 { return ')'; }
","                                 { return ','; }
":"									{ return ':'; }

[A-Za-z_][A-Za-z0-9_]*              {
                                        yylval.s = strdup(yytext);
                                        return NAME;
                                    }

.                                   ;

%%

/*

%%

[ \t]	;
\n	{ return 0; }

"min" { return MIN; }
"max" { return MAX; }
"pow" { return POW; }

[0-9]+	{ yylval.d = atoi(yytext); return NUMBER; }

[A-Za-z_][A-Za-z0-9_]* { yylval.s = strdup(yytext); return IDENTIFIER; }

"="	{ return '='; }

"+"	{ return '+'; }
"*"	{ return '*'; }
"-" { return '-'; }
"/" { return '/'; }
"("	{ return '('; }
")"	{ return ')'; }
"," { return ','; }
.	{std::cout << "Invalid character: " << yytext << std::endl; }

%%
*/
