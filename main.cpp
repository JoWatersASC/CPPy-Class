#include <iostream>
#include <fstream>
#include <cstdio>

using namespace std;

extern int yyparse();
extern FILE* yyin;
extern int yydebug;

std::ofstream out;

// extern ostream& out;
// extern bool from_file;

int main(int argc, char *argv[]) {
	yydebug = 1;
	
	if(argc < 2) {
        cerr << "Usage: " << argv[0] << " <input-file>\n";
        // cerr << "Usage: " << argv[0] << " <input-file> [<output-file>]\n";
        return 1;
    }

	if(argc == 3) {
		out.open(argv[2]);
	} else {
		out.open("CPPy-Class.py");
	}

	yyin = fopen(argv[1], "r");
    if(!yyin) {
        perror("fopen");
        return 1;
    }

	int pRes = yyparse(); // Result of parse
    fclose(yyin);

	if(pRes != 0) {
        cerr << "Parse failed with code " << pRes << "\n";
        return pRes;
    }

	return 0;
}