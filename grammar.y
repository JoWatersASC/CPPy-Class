%{
#include <iostream>
#include <fstream>
#include <cctype>
#include <cmath>
#include <sstream>
#include <cstring>

#include <vector>
#include <unordered_set>

using std::string;
using std::cout;
using std::cerr;
using std::endl;


string class_name;
string paren_name = ""; // optional parent class name
string ctor_params = "";
string ctor_body = "";

std::ostringstream builder;

struct mem_var {
	string name;
	string val;
};
struct method {
     string name;
     string params;
	 string body;

     bool operator==(const method& o) const { return name == o.name; }
};

std::vector<method> methods;
std::vector<mem_var> mem_vars;
std::unordered_set<std::string> members;
std::unordered_set<std::string> locals;

extern std::ofstream out;

// std::ostream *output_stream = &cout;
// std::ostream& out = *output_stream;

int indent = 0;
void print_indent() { for(int i=0; i < indent; i++) out << "    "; }
void newline()      { out << "\n"; }
void inc_indent()   { ++indent; }
void dec_indent()   { --indent; }

bool has_constructor = false;
// bool from_file       = false; // defines if user inputs info or comes

int lineNum = 1;

void dup_err(const string& var) {
	cout << "[ERROR] CANNOT HAVE DUPLICATE IDENTIFIER: " << var << '\n';
	cerr << "[ERROR] CANNOT HAVE DUPLICATE IDENTIFIER: " << var << '\n';
}

void yyerror(const char *s) {
	cerr << lineNum << ": " << s << endl;
}
extern int yylex(void);
#define YYDEBUG 1
extern int yydebug;

extern void yy_beg_loc();
extern void yy_end_loc();

%}

%union {
	int d;
	float f;
	
	char *s;
}

%token <f> NUM
%token <s> ACC NAME SC CLASS CNAME TYPE LTYPE
%type <s> CLS CTOR MDEC LDEC VAR VARL NAMEL IHRT CALL

%start S

%%
S    : CLASS CLS
     ;

CLS  : NAME {class_name = $1; }IHRT '{' BOD '}' SC
     {
          print_indent();

          out << "class " << $1;
          if (!paren_name.empty()) 
               out << paren_name;
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
               out << "self." << v.name << " = " << (v.val.empty() ? "None" : v.val) << endl;
          }
		  
		  std::istringstream ctbstr(ctor_body);
		  string line;
		  while(getline(ctbstr, line)) {
			  print_indent();
			  out << line << endl;
		  }
		  out << endl;

          dec_indent();

          for (auto &m : methods) {
               print_indent();
               out << "def " << m.name << "(self";

               if (!m.params.empty())
                    out << ", " << m.params;
               out << "):\n";

               inc_indent();
               print_indent();
               
			   if(m.body.empty())
			       out << "pass\n";
			   else
				   out << m.body << endl;
               
               dec_indent();
          }

          dec_indent();

          mem_vars.clear();
          methods.clear();
          has_constructor = false;
     }
     ;

IHRT : e            { paren_name = ""; $$ = (char*)""; }
     | ':' ACC NAME { paren_name = const_cast<char *>(('('+ string($3) + ')').c_str()); }

BOD  : e
     | ACC ':' BOD
     | MVAR SC BOD
     | FUNC BOD
     | CTOR BOD
     ;

MVAR : MDEC                    { mem_vars.push_back({ $1, "" }); members.insert($1); yy_end_loc(); }
     | MDEC '=' NAME      	   { mem_vars.push_back({ $1, $3 }); members.insert($1); yy_end_loc(); } // skip init
	 | MDEC '=' NUM      	   { mem_vars.push_back({ $1, std::to_string($3) }); members.insert($1); yy_end_loc(); }
     ;
VAR  : LDEC                    	{ $$ = $1; members.insert($1); }
     | LDEC '=' NAME           	{ 
									builder << $1 << '=' << $3;
									$$ = strdup(const_cast<char *>(builder.str().c_str())); 
									builder.str("");
									members.insert($1); 
								}// skip init
	 | LDEC '=' NUM            	{ 
									builder << $1 << '=' << std::to_string($3);
									$$ = strdup(const_cast<char *>(builder.str().c_str())); 
									builder.str("");
									members.insert($1); 
								}
	 // | LDEC '=' CALL            { 
									// builder << $1 << '=' << std::to_string($3);
									// $$ = strdup(const_cast<char *>(builder.str().c_str())); 
									// builder.str("");
									// members.insert($1); 
								// }
     ;
	 
SCP  : e                      {}
     | ';'
     | VAR SC      { builder << $1 << '\n'; } SCP        { members.erase($1); }
     | CALL SC     { builder << $1 << '\n'; } SCP        {  }
     | '{' VAR SC  { builder << $2 << '\n'; } SCP '}'    { indent++; members.erase($2); }
     | '{' CALL SC { builder << $2 << '\n'; } SCP '}'    { indent++;  }
     ;
	 
FUNC : MDEC '(' ')''{' SCP '}' 
	{
		methods.push_back({ string($1), "", std::move(builder.str()) }); 
		builder.str("");
		yy_end_loc();
	}
    | MDEC '(' VARL ')''{' SCP '}' 
	{ 
		methods.push_back({ string($1), string($3), std::move(builder.str()) }); 
		builder.str("");
		yy_end_loc();
	}
     | MDEC '(' ')' SC              { methods.push_back({ string($1), "", "" }); yy_end_loc(); } // Declarations w/ no body
     | MDEC '(' VARL ')' SC         { methods.push_back({ string($1), string($3), "" }); yy_end_loc(); }
     ;

CALL : NAME '(' ')'       { builder << $1 << "()"; $$ = strdup((char *)builder.str().c_str()); builder.str(""); }
     | NAME '(' NAMEL ')' { builder << $1 << '(' << $3 << ')'; $$ = strdup((char *)builder.str().c_str()); builder.str(""); }
     ;

MDEC  : TYPE NAME
     {
          string var = $2;
          
          if (!members.count(var)) { // insert returns boolean: true if successful/didn't exist already
               $$ = $2;
          } else {
               cout << "[ERROR] CANNOT HAVE DUPLICATE IDENTIFIER: " << var << '\n';
               cerr << "[ERROR] CANNOT HAVE DUPLICATE IDENTIFIER: " << var << '\n';
               $$ = 0;
          }
		  
		  yy_beg_loc();
     }
     ;

LDEC : LTYPE NAME
     {
          string var = $2;
          
          if (!members.count(var)) { // insert returns boolean: true if successful/didn't exist already
               $$ = $2;
          } else {
               dup_err(var);
               $$ = 0;
          }
     }
     ;

VARL : VAR               { $$ = $1; }
     | VARL ',' VAR      { $$ = strdup(const_cast<char *>(
                              (string($1) + ", " + string($3)).c_str()
                         ));
                         }
     ;

NAMEL: NUM				 { $$ = strdup(const_cast<char *>(std::to_string($1).c_str())); }
	 | NAME              { $$ = $1; }
     | NAMEL ',' NUM    { 
							builder << $1 << ", " << $3;
							$$ = strdup(const_cast<char *>(builder.str().c_str()));
							builder.str("");
						}
	 | NAMEL ',' NAME    { $$ = strdup(const_cast<char *>(
                              (string($1) + ", " + string($3)).c_str()
                         ));}
     ;

CTOR : CNAME '(' ')' SCP
     {
          if ($1 == class_name && !has_constructor) {
               has_constructor = true;
               ctor_params.clear();
			   ctor_body = std::move(builder.str());
			   builder.str("");
          } else if($1 == class_name) {
			  dup_err(class_name);
			  exit(0);
		  }
		  
		   yy_end_loc();
     }
     | CNAME '(' VARL ')' SCP
     {
          if ($1 == class_name && !has_constructor) {
               has_constructor = true;
               ctor_params = $3;
			   ctor_body = std::move(builder.str());
			   builder.str("");
          } else if($1 == class_name) {
			  dup_err(class_name);
			  exit(0);
		  }
		  
		  yy_end_loc();
     }
	 | CNAME '(' ')' SC
     {
          if ($1 == class_name && !has_constructor) {
               has_constructor = true;
               ctor_params.clear();
          } else if($1 == class_name) {
			  dup_err(class_name);
			  exit(0);
		  }
		  
		  yy_end_loc();
     }
     | CNAME '(' VARL ')' SC
     {
          if ($1 == class_name && !has_constructor) {
               has_constructor = true;
               ctor_params = $3;
          } else if($1 == class_name) {
			  dup_err(class_name);
			  exit(0);
		  }
		  
		  yy_end_loc();
     }
     ;
	 
e : ;
%%

// void yy_switch_to_LOCAL()   { BEGIN(LOCAL); }
// void yy_switch_to_INITIAL() { BEGIN(INITIAL); }
