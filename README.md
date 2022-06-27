# mini_compiler


execution: 

compile: 
flex project.l && bison -d project.y && gcc lex.yy.c project.tab.c -ll -o test.o

run:
./test.o < testfile
./test.o [command line input]

because of the inambiguity of the specification: 

- an error is issued if: 

* the grammar/syntax is incorrect
* an unknown token is found 
* an undefined identifier is being used 
* a value larger than identifier capacity is being assigned to the identifier 

- a warning is issued if: 

* an identifier is being redeclared 
* an identifier of a larger size is being assigned to an identifier of a smaller size 

- identifier names are being treated as case insensitive like the rest of the program  (id Z = id z)