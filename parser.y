%{
#include <stdio.h>
#include <string.h>
%}

%union {
	int int_value;
    	float float_value;
    	char* str;
}

%token <int_value> INTEGER_CONSTANT
%token <str> IDENTIFIER
%token <str> DATA_TYPE /* Added DATA_TYPE token */

%left PLUS MINUS
%left MULTIPLY DIVIDE
%type <int_value> expr

%start input

%%

input : /* empty production to allow an empty input */
      | input line
      ;

line : declaration '\n'
     | expr '\n'
     ;

declaration : DATA_TYPE IDENTIFIER '=' expr {
    printf("%s is \"%s\", value is %f\n", $2, $1, $4);
}
;

expr : expr PLUS expr { $$ = $1 + $3; }
     | expr MINUS expr { $$ = $1 - $3; }
     | expr MULTIPLY expr { $$ = $1 * $3; }
     | expr DIVIDE expr { $$ = $1 / $3; }
     | INTEGER_CONSTANT { $$ = $1; }
     ;

%%

int yywrap() {
    return 1;
}

int yyerror() {
    return 1;
}
