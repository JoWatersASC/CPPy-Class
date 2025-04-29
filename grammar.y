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
string paren_name = ""; // optional parent class name
string ctor_params = "";

struct method {
     string name;
     string params;

     bool operator==(const method& o) const { return name == o.name; }
};

std::vector<method> methods;
std::vector<std::string> mem_vars;
std::unordered_set<std::string> members;

std::ofstream out("./CPPy-Class.py");
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
%type <s> CLS CTOR DEC VAR VARL NAMEL 

%start S

%%
S    : CLASS CLS
     ;

CLS  : NAME IHRT '{' BOD '}' SC
     {
          print_indent();

          out << "class " << $1;
          if (!paren_name.empty()) 
               out << "(" << paren_name << ")";
          out << ":\n";

          inc_indent();
          print_indent();

          if (has_constructor) {
               out << "def __init__(self";

               if (!ctor_params.empty()) 
                    out << ", " << ctor_params;
               out << "):\n";
          } else {
               out << "def __init__(self):\n";
          }

          inc_indent();

          for (auto &v : mem_vars) {
               print_indent();
               out << "self." << v << " = None\n";
          }

          dec_indent();

          for (auto &m : methods) {
               print_indent();
               out << "def " << m.name << "(self";

               if (!m.params.empty())
                    out << ", " << m.params;
               out << "):\n";

               inc_indent();
               print_indent();
               
               out << "pass\n";
               
               dec_indent();
          }

          dec_indent();

          mem_vars.clear();
          methods.clear();
          has_constructor = false;
     }
     ;

IHRT : e        { paren_name.clear(); }
     | ACC NAME { paren_name = $2; }

BOD  : e
     | ACC ':' BOD
     | VAR SC BOD
     | FUNC BOD
     | CTOR BOD
     ;

SCP  :                        {} // store SCP output in a string and appnend to the function
     | '{' VAR SC SCP '}'     { indent++; }
     | '{' CALL SC SCP '}'    {}
     ;

VAR  : DEC                    { $$ = $1; mem_vars.push_back($1); }
     | DEC '='                { $$ = $1 + '='; mem_vars.push_back($1); }// skip init
     ;
     /* : TYPE NAME SC
      {
        mem_vars.push_back($2);
      }
    ;*/
FUNC : DEC '(' ')' SCP      { methods.push_back({ string($1), "" }); } // maybe store the SCP result in a map of sorts for each func, 
     | DEC '(' VARL ')' SCP { methods.push_back({ string($1), string($3) }); } //or keep another field 'string body' in 'method' struct
     | DEC '(' ')' SC       { methods.push_back({ string($1), "" }); } // Declarations w/ no body
     | DEC '(' VARL ')' SC { methods.push_back({ string($1), string($3) }); }
     ;

CALL : NAME '(' ')' SC
     | NAME '(' NAMEL ')' SC {}
     ;

DEC  : NAME NAME
     {
          string var = $2;
          
          if (!members.count(var)) { // insert returns boolean: true if successful/didn't exist already
               $$ = $2;
               members.insert(var);
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
          if ($1 == class_name && !has_constructor) {
               has_constructor = true;
               ctor_params.clear();
          }
     }
     | NAME '(' VARL ')' SCP
     {
          if ($1 == class_name && !has_constructor) {
               has_constructor = true;
               ctor_params = $3;
          }
     }
     ;
     /*
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
     */

e : ;
%%