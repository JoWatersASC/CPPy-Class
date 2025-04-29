%{
#include <iostream>
#include <fstream>
#include <cctype>
#include <cmath>

#include <vector>
#include <unordered_set>

using std::unordered_set;
using std::ofstream;

std::string class_name;
set<std::string> mem_vars;
int indent = 0;
bool has_constructor = false;

int lineNum = 1;

using std::cout;
using std::endl;

void yyerror(const char *s) {
	cout << lineNum << ": " << s << endl;
}
extern int yylex(void);
#define YYDEBUG 1
extern int yydebug;

%}

%union {
	int d;
	
	char *s;
}
/*
%token <d> NUMBER
%token <s> IDENTIFIER
%token '='
%token MIN MAX POW
%type <d> exp factor term
*/
%token <s> ACC NAME SC class
%type <s> CLS DEC

%start S

%%
S    : class CLS              { $$ = $2; }
CLS  : NAME '{' BOD '}' SC    { $$ = $1; class_name = $1; scope_level++; }
BOD  : ACC ':'                {}
     | ACC ':' BOD            {}
     | FUNC                   {}
     | FUNC BOD               {}
     | VAR SC                 {}
     | VAR SC BOD             {}
     | CSTRCT                 {}
     | CSTRCT BOD             {}
SCP  :                        {}
     | '{' VAR SC SCP '}'     { scope_level++; }
     | '{' CALL SC SCP '}'    {}
VAR  : DEC                    {}
     | DEC '=' EXP            {}
FUNC : DEC '('')' SCP         {}
     | DEC '(' VARL ')' SCP   {}
CALL : NAME '(' ')' SC        {}
     | NAME '(' NAMEL ')' SC  {}
DEC  : NAME NAME              {
                                  if(mem_vars.find($2) != mem_vars.end()) { 
								      mem_vars.insert($2);
                                      $$ = $2; 
                                  } else {
                                      std::cout << "Duplicate variable declarations of: " << $2 << std::endl;
                                      $$ = 0;
                                  }
                              }

VARL : VAR
     | VARL ',' VAR
NAMEL: NAME
     | NAMEL ',' NAME

CSTRCT : NAME '(' ')' SCP     {
                                  if(class_name != $1) {
                                      std::cout << "Function missing type specifier: " << $1 << std::endl;
                                  } else if(has_constructor) {
                                      std::cout << "Class may only have single constructor" << std::endl;
                                  } else {
                                      has_constructor = true;
                                  }
                              }
       | NAME '('VARL')' SCP
%%

/*
%%

cls_dec : class dec {std::cout << "The result is " << $1 << std::endl; }
	;
dec	: MIN '(' exp ',' exp ')' { $$ = std::min($3, $5); }
	| MAX '(' exp ',' exp ')' { $$ = std::max($3, $5); }
	| POW '(' exp ',' exp ')' { $$ = pow($3, $5); }
	| IDENTIFIER '=' exp	{
		variables[$1] = $3;
		$$ = $3;
	}
	| IDENTIFIER		{
		if(variables.find($1) != variables.end())
			$$ = variables[$1];
		else {
			std::cout << "Error: Undefined variable " << $1 << std::endl;
			$$ = 0;
		}
	}
	| exp '+' factor	{ $$ = $1 + $3; }
	| factor 		{ $$ = $1; }
	;
factor	: factor '*' term	{ $$ = $1 * $3; }
	| factor '/' term		{ $$ = $1 / $3; }
	| factor '-' term		{ $$ = $1 - $3; }	
	| term			{ $$ = $1; }
	;
term	: NUMBER		{ $$ = $1; }
	| '(' exp ')'		{ $$ = $2; }
	;
%%
*/
