#!/bin/bash

# mkdir -p ./output
bison -d grammar.y
flex lexer.l
