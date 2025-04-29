%{
#include <iostream>
#include "grammar.tab.h"
#include <cstring>

extern int lineNum;
%}

%option noyywrap


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
