%{
#include <iostream>
#include <fstream>
#include <cctype>
#include <cmath>

#include <vector>
#include <unordered_set>

using std::unordered_set;
using std::ofstream;
using std::cout;
using std::endl;

std::string class_name;
unordered_set<std::string> mem_vars;

// ofstream outFilePy("CPPy-Class.py");
std::ostream& out = cout;

int indent = 0;
void print_indent() { for(int i=0; i<indent; ++i) out << "    "; }
void newline()      { out << "\n"; }
void inc_indent()   { ++indent; }
void dec_indent()   { --indent; }

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
%type <s> CLS DEC VAR VARL NAMEL

%start S

%%
S    : class CLS
     ;

CLS  : NAME '{' BOD '}' SC    
     {
          if (!has_constructor) {
               inc_indent();
               print_indent(); 
               
               out << "def __init__(self):\n";

               inc_indent();

               for (auto &v : mem_vars) {
                    print_indent(); 
                    out << "self." << v << " = None\n";
               }

               dec_indent();
               dec_indent();
          }
          
          has_constructor = false;
          mem_vars.clear();
     }
     ;

BOD  : e
     | ACC ':' BOD
     | VAR SC BOD
     | FUNC BOD
     | CTOR BOD
     ;

SCP  :                        {}
     | '{' VAR SC SCP '}'     { scope_level++; }
     | '{' CALL SC SCP '}'    {}
VAR  : DEC                    { $$ = $1 }
     | DEC '='                { $$ = $1 + '='; }// skip init
     ;
     /* : TYPE NAME SC
      {
        mem_vars.push_back($2);
      }
    ;*/
FUNC : DEC '(' ')' SCP
     {
          inc_indent();
          print_indent(); 

          out << "def " << $1 << "(self):\n"; newline();

          inc_indent();
          print_indent(); 

          out << "pass\n";

          dec_indent();
          dec_indent();
     }
     | DEC '(' VARL ')' SCP
     {
          inc_indent();
          print_indent();

          out<< "def " << $1 << "(self, " << $3 << "):\n";

          inc_indent();
          print_indent(); 

          out << "pass\n";

          dec_indent();
          dec_indent();
     }
     ;

CALL : NAME '(' ')' SC
     | NAME '(' NAMEL ')' SC {}
     ;

DEC  : NAME NAME
     {
          string var = $2;
          
          if (mem_vars.insert(var).second) { // insert returns boolean: true if successful/didn't exist already
               $$ = $2;
          } else {
               cerr << "Warning: duplicate member " << var << "\n";
               $$ = 0;
          }
     }
     ;

VARL : VAR               { $$ = string($1); }
     | VARL ',' VAR      { $$ = $1 + ", " + string($3); }
     ;

NAMEL: NAME              { $$ = string($1); }
     | NAMEL ',' NAME    { $$ = $1 + ", " + string($3); }
     ;

CTOR : NAME '(' ')' SCP
     {
          if ($1 != class_name) {
               cerr << "Warning: constructor name " << $1 << " != class " << class_name << endl;
          } else if (has_constructor) {
               cerr << "Error: only one constructor allowed\n";
          } else {
               has_constructor = true;
               inc_indent();
               print_indent();
               
               out << "def __init__(self):\n";
               
               inc_indent();

               for (auto &v : mem_vars) {
                    print_indent();
                    cout << "self." << v << " = None\n";
               }
               
               dec_indent();
               dec_indent();
          }
     }
     | NAME '(' VARL ')' SCP
     {
          if ($1 != class_name) {
               cerr << "Warning: constructor name " << $1 << " != class " << class_name << endl;
          } else if (has_constructor) {
               cerr << "Error: only one constructor allowed\n";
          } else {
               has_constructor = true;
               inc_indent();
               print_indent(); 
               
               out << "def __init__(self, " << $3 << "):\n";
               
               inc_indent();

               for (auto &v : mem_vars) {
                    print_indent(); 
                    out << "self." << v << " = None\n";
               }

               dec_indent();
               dec_indent();
          }
     }
     ;

e : ;
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
