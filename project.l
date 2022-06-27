/* Headers, declarations */
%{
    #include <stdio.h>
    #include <stdlib.h>
    #include "project.tab.h"
%}

/* Token Specification */
%option yylineno
%option noyywrap
%option caseless 

%%
[\t\n ]+                                            ;
\.                          						{return DOT;};
\;													{return SEMICOLON;};
[x]+                                                {yylval.id = strdup(yytext); return CAPACITY;};
ADD                                                 {return ADD;};
TO                                                  {return TO;};
BODY                                                {return BODY;};
END                                                 {return END;};
BEGINNING                                           {return BEGINNING;};
PRINT                                               {return PRINT;};
INPUT                                               {return INPUT;};
MOVE                                                {return MOVE;};
[0-9]+                                              {yylval.ival = atoi(yytext); return NUMBER;};
[a-z][a-z0-9_-]{0,32}                               {yylval.id = strdup(yytext);  return IDENTIFIER;};
\"([^"\\])*\"                                       {return STRING;};
.                                                   {printf("Error: Invalid/Unknown Token (Line: %d)\n", yylineno); exit(1); };
%%