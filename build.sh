#!/bin/bash

mkdir -p ./output

bison -d grammar.y &&
flex lexer.l &&
g++ grammar.tab.c lex.yy.c main.cpp -o output/cppygen
