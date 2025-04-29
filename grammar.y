%{
#include <iostream>
#include <fstream>
#include <cctype>
#include <cmath>

#include <vector>
#include <unordered_set>

using std::string;
using std::cout;
using std::cerr;
using std::endl;

string class_name;
std::unordered_set<std::string> mem_vars;
std::ofstream out = std::ofstream("./output/CPPy-Class.py");

// std::ostream *output_stream = &cout;
// std::ostream& out = *output_stream;

int indent = 0;
void print_indent() { for(int i=0; i<indent; ++i) out << "    "; }
void newline()      { out << "\n"; }
void inc_indent()   { ++indent; }
void dec_indent()   { --indent; }

bool has_constructor = false;
// bool from_file       = false; // defines if user inputs info or comes

int lineNum = 1;

using std::cout;
using std::endl;

void yyerror(const char *s) {
	cerr << lineNum << ": " << s << endl;
}
extern int yylex(void);
#define YYDEBUG 1
extern int yydebug;

%}

%union {
	int d;
	
	char *s;
}

%token <s> ACC NAME SC CLASS
%type <s> CLS DEC VAR VARL NAMEL

%start S

%%
S    : CLASS CLS
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
     | '{' VAR SC SCP '}'     { indent++; }
     | '{' CALL SC SCP '}'    {}
     ;

VAR  : DEC                    { $$ = $1; }
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

VARL : VAR               { $$ = $1; }
     | VARL ',' VAR      { $$ = const_cast<char *>(
                              (string($1) + ", " + string($3)).c_str()
                         );}
     ;

NAMEL: NAME              { $$ = $1; }
     | NAMEL ',' NAME    { $$ = const_cast<char *>(
                              (string($1) + ", " + string($3)).c_str()
                         );}
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
                    out << "self." << v << " = None\n";
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