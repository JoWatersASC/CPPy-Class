%{
#include <iostream>
#include <cctype>
#include <cmath>

#include <vector>
#include <unordered_set>

template<typename T>
using set = std::unordered_set<T>;

std::string class_name;
set<std::string> mem_vars;

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


%start S


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
