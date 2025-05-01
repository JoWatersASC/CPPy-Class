# CPPy-Class

### Turn C++ class declarations into python class declarations


## Build
run 'build.sh' script

#### Output
![Output-Pic](assets/cppy-class.png)

#### Tree
![Output-Tree](assets/tree.png)

### **1\. Grammar Definition \[25 pts\]**

#### **BNF Format:**

\<program\> ::= \<class\_decl\>+  
\<class\_decl\> ::= "class" \<identifier\> "{" \<member\>\* "}"   
\<member\> ::= \<access\_specifier\> \<identifier\> ";"  
\<access\_specifier\> ::= "public" | "private" | "protected"  
\<identifier\> ::= \[A-Za-z\_\]\[A-Za-z0-9\_\]\*

#### **Coverage Explanation:**

This grammar captures the basic structure of a C++-like class system including:

* Class declarations

* Access specifiers (public, private, protected)

* Member identifiers

This simple structure supports hierarchical parsing of class definitions.

---

### **2\. Parser Implementation \[30 pts\]**

#### **Parsing Strategy:**

We use a **LALR(1) bottom-up parsing** approach via **Bison** to match token streams from the lexer. The strategy handles nested rules efficiently and supports lookahead for disambiguation.

#### **Fit for Use Case:**

Our language is structured and declarative (class-based), which fits naturally into LALR parsing. It avoids deep recursion, making LALR a good performance fit.

#### **Source Code:**

* **Lexer (Flex):** Tokenizes input source using regex patterns.

* **Parser (Bison):** Processes tokens and builds class structure.

* Outputs are prepared to reflect syntax trees and potential intermediate code.

---

### **3\. Executable Program with Use Case \[20 pts\]**

#### **Flow:**

Input (C++-style class source)  
     ↓  
Lexical Analysis (Flex)  
     ↓  
Parsing (Bison)  
     ↓  
Syntax Tree / Structured Output

#### **Use Case:**

Parses class definitions from a source file and outputs structured JSON representing class structure. For example:

class Shape {  
  public area;  
  private size;  
};

→

{  
  "class": "Shape",  
  "members": \[  
    {"access": "public", "name": "area"},  
    {"access": "private", "name": "size"}  
  \]  
}

---

### **4\. Assumptions & Language Design \[15 pts\]**

#### **Assumptions:**

* All class declarations are syntactically valid.

* Every member must be followed by a semicolon.

* No function definitions or expressions are allowed (identifier declarations only).

#### **Language Objectives:**

* Simplify and validate object-oriented structure

* Provide a stepping stone for more complex C++-like features

* Enable structured output (e.g., for transpilation or analysis)

---

### **5\. Demo Output \+ Parse Tree \[10 pts\]**

#### **Example Input:**

class Car {  
  public speed;  
  private model;  
};

#### **Parse Tree (Textual Representation):**

program  
└── class\_decl ("Car")  
    ├── member (public, speed)  
    └── member (private, model)

#### **Generated Output:**

{  
  "class": "Car",  
  "members": \[  
    {"access": "public", "name": "speed"},  
    {"access": "private", "name": "model"}  
  \]  
}