%{
#include <iostream>
#include "grammar.tab.h"
#include <cstring>

extern int lineNum;
extern std::string class_name;
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


("public"|"private"|"protected")    { return ACC; }

<LOCAL>("int"|"char"|"float"|"double"|"void"|"bool") {
    yylval.s = strdup(yytext);
    return LTYPE;
}

("int"|"char"|"float"|"double"|"void"|"bool") {
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

[A-Za-z_][A-Za-z0-9_]*              {
                                        yylval.s = strdup(yytext);
                                        if(class_name == yytext)
                                            return CNAME;
                                        return NAME;
                                    }

.                                   ;

%%
