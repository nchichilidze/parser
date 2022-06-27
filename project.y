%{

#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include <math.h>
#include <ctype.h>
#define MAX_VARIABLES 100

extern int yylex();
extern int yyparse();
extern int yylineno;
extern FILE* yyin;

int variableCounter = 0;

/* a datatype which stores the name and the capacity of each declared identifier */
typedef struct  {
	int capacity;
	char* name;
}variable;

/* declaring the methods used in the program */
variable *variables;
void yyerror(const char* s);
void defineVariable(char *size, char *name);
char* toLower(char* name);
bool exists(char *name);
int getCapacity(char *size);
void compareIdentifierSizes(char* identifier1, char* identifier2);
void checkVariableAssignment(int value, char* identifier);
bool validateIdIndefinition(char* identifier);
bool validateIdDefinition(char* identifier);

/* printVariables dictates whether the list of declared variables appears on the console for testing purposes */
bool printVariables = false; 

%}

/* datatypes used for tokens */
%union {
	char *id;
	int ival;
}

%start program
%token<ival> NUMBER
%token<id> IDENTIFIER
%token<id> CAPACITY
%token ADD TO BODY END BEGINNING PRINT INPUT STRING SEMICOLON  DOT MOVE

%%
/* grammar definition */
program: beginning_statement variable_definitions body_of_operations end_statement


beginning_statement: BEGINNING DOT

/* declarations */
variable_definitions: variable_definition | variable_definition variable_definitions 
variable_definition: CAPACITY IDENTIFIER DOT {
							if(validateIdIndefinition($2)) {
								defineVariable($1, $2);
							}
						}




/* operations */
body_of_operations: BODY DOT operations

operations:         operation DOT | operation DOT operations 


operation:          print_operation 
                    | input_operation 
                    | add_operation 
                    | move_operation


/* print */
print_operation:     PRINT print_content; 
print_content:       STRING 
					| STRING SEMICOLON print_content 
					| IDENTIFIER {validateIdDefinition($1);} 
					| IDENTIFIER SEMICOLON print_content {validateIdDefinition($1);} 



/* input */
input_operation:     INPUT IDENTIFIER {validateIdDefinition($2);}
					 | INPUT IDENTIFIER SEMICOLON list_of_identifiers {validateIdDefinition($2);}

list_of_identifiers:  IDENTIFIER {validateIdDefinition($1);}
					 | IDENTIFIER SEMICOLON list_of_identifiers {validateIdDefinition($1);}

 

/* add */
add_operation:       ADD NUMBER TO IDENTIFIER {validateIdDefinition($4);}
                    | ADD IDENTIFIER TO IDENTIFIER {validateIdDefinition($2); validateIdDefinition($4);}


/* move */
move_operation:      MOVE NUMBER TO IDENTIFIER { 
							if(validateIdDefinition($4)) {
								checkVariableAssignment($2, $4);
							}
						}
					| MOVE IDENTIFIER TO IDENTIFIER { 
						if (validateIdDefinition($2) && validateIdDefinition($4)){
							compareIdentifierSizes($2, $4);
						}
					}




/* end */
end_statement:      END DOT { printf("Success. Program is error-free. \n"); exit(0);}

%%

int main() {
	/* initialising the variables array */
	variables = (variable*)malloc(sizeof(int)*MAX_VARIABLES);
	yyin = stdin;

	do {
		yyparse();
	} while(!feof(yyin));

	return 0;
}

void yyerror(const char* s) {
	fprintf(stderr, "Parse error (Line: %d): %s\n", yylineno, s);
	exit(1);
}

char* toLower(char* s) {
  for(char *p=s; *p; p++) *p=tolower(*p);
  return s;
}

bool exists(char* name) { 
	bool var_exists = false; 
	char* lower_name = toLower(name);

	for(int i = 0; i < variableCounter; i++) {
		char* curName = variables[i].name;
		if(strcmp(curName, lower_name) == 0) {
			var_exists = true;
		}
	}
	
	return var_exists;

}


void printvars() { 
	if (printVariables == false) { 
		return;
	}
	printf("\n****************variables*********************\n");
	for (int x = 0; x < variableCounter; x++){
		char* name = variables[x].name;
		int cap = variables[x].capacity;
		printf("%d: %s [cap: %d] \n", x, name, cap);
    }
    printf("**********************************************\n");

}

int lookupCapacity(char* identifier) { 

	int cap = -1;
	for (int i = 0; i < variableCounter; i++) { 
		char* name = variables[i].name;
		cap = variables[i].capacity; 

		if (strcmp(name, identifier)==0) { 
			return cap;
		}

	}
	return cap;
}

int getCapacity(char* capacity) { 
	int length = 0; 
	while(capacity != NULL && *capacity != '\0') {
		length++;
		++capacity;
	}
	return length;
}


/* adds a new variable to the program */
void defineVariable(char *size, char *name) {

	variable var; 
	var.capacity= getCapacity(size);

	/* lowercasing all new identifiers because they should be case insensitive */
	var.name = toLower(name);

	variables[variableCounter]=var;

	variableCounter = variableCounter + 1;
	printvars();

}

/* making sure that an identifier is defined already  */
bool validateIdDefinition(char* identifier) { 
	if (exists(identifier) == false) { 
		printf("Error: Identifier: [%s] is not declared (Line %d)\n", identifier, yylineno);
		exit(1);
		return false;
	}
	return true;

}

/* making sure that an identifier is not defined yet */
bool validateIdIndefinition(char* identifier) { 
	if (exists(identifier) == true) { 
		printf("Warning: %s is already declared (Line %d)\n", identifier, yylineno);
		return false;
	}
	return true;
}

void compareIdentifierSizes(char* identifier1, char* identifier2) { 
	printvars();
	int cap1 = lookupCapacity(identifier1);
	int cap2 = lookupCapacity(identifier2);
	if (cap1 > cap2) { 
		printf("Warning: Identifier: %s [cap: %d] is bigger than identifier: %s [cap: %d](Line %d)\n", identifier1, cap1, identifier2, cap2, yylineno);
	}

}

void checkVariableAssignment(int value, char* identifier) {
	int digitsInValue = 0; 

	while(value != 0) { 
		value = value/10;
		digitsInValue++; 
	}

	int digitsInIdentifier = lookupCapacity(identifier);

	if (digitsInValue > digitsInIdentifier) { 
		printf("Error: Given value is larger than the identifier: %s [cap: %d] (Line %d)\n", identifier, digitsInIdentifier, yylineno);
		exit(1);
	}

}






