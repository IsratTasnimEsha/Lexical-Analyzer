%{
#include <stdio.h>
#include <string.h>
#include<stdlib.h>
#include <ctype.h>
#include "parser.tab.h"

int lineno=1;
FILE* output_file;

int keyword_count = 0;
int identifier_count = 0;
int special_symbol_count = 0;
int constant_count = 0;
int operator_count = 0;

char current_type[50];
char variables[100][32];
char constants[100][32];
static int var_len = 0;
static int const_len = 0;

char identifier[100][32];
char datatype[100][32];
union VALUE {
	int INT;
	float FLOAT;
	char CHAR;
	char STRING[100];
};
int choose[100];
static int value_len = 0;
union VALUE value[100];

char* trimWhitespace(char* str) {
    int start = 0, end = strlen(str) - 1;

    while (isspace(str[start])) {
        start++;
    }

    while ((end >= start) && isspace(str[end])) {
        end--;
    }

    str[end + 1] = '\0';

    return str + start;
}

void handleInteger(char* current_type) {
    char *token = strtok(yytext, "=");
    token = trimWhitespace(token);

    if (token != NULL) {
        for (int i = 1; i <= var_len; i++) {
	    if (strcmp(variables[i], token) == 0) {
		if(strcmp(current_type, "var") == 0 || strcmp(current_type, "const") == 0) {
                	printf("Error at Line %d: '%s' has been defined before.\n", lineno, token);	
			exit(1);
		}
	    }
	}

        for (int i = 1; i <= const_len; i++) {
            if (strcmp(constants[i], token) == 0) {
                if(strcmp(current_type, "var") == 0 || strcmp(current_type, "const") == 0) {
                	printf("Error at Line %d: '%s' has been defined before.\n", lineno, token);	
		}
            }
        }

	if (strcmp(current_type, "assign") == 0) {
	    for (int i = 1; i <= const_len; i++) {
		if (strcmp(constants[i], token) == 0) {
			printf("Error at Line %d: '%s' can't be assigned.\n", lineno, token);	
			exit(1);
		}
	    }

	    int i=1;
            	
            for (; i <= value_len; i++) {
	    	if (strcmp(identifier[i], token) == 0)
			break;	
	    }

	    if(i == value_len + 1) {
		printf("Error at Line %d: %s is not assigned before.\n", lineno, token);
		exit(1);
	    }
	    
   	    token = strtok(NULL, " \t\n\r");
            if (token != NULL) {
                fprintf(output_file, "%s - INTEGER_CONSTANT\n", token);
                value[i].INT = atoi(token);
                choose[i] = 1;
	    }
        }
	
        else if (strcmp(current_type, "var") == 0) {
            	fprintf(output_file, "%s - IDENTIFIER\n", token);
		var_len++;
            	strcpy(variables[var_len], token);
            	value_len++;
                strcpy(identifier[value_len], token);
                strcpy(datatype[value_len], "VAR");
                token = strtok(NULL, " \t\n\r");
		token = trimWhitespace(token);
                if (token != NULL) {
                    fprintf(output_file, "%s - INTEGER_CONSTANT\n", token);
                    value[value_len].INT = atoi(token);
                    choose[value_len] = 1;
                }
        }

        else if (strcmp(current_type, "const") == 0) {
            fprintf(output_file, "%s - IDENTIFIER\n", token);
            const_len++;
            strcpy(constants[const_len], token);
            value_len++;
            strcpy(identifier[value_len], token);
            strcpy(datatype[value_len], "CONST");
            token = strtok(NULL, " \t\n\r");
	    token = trimWhitespace(token);
            if (token != NULL) {
                fprintf(output_file, "%s - INTEGER_CONSTANT\n", token);
                value[value_len].INT = atoi(token);
                choose[value_len] = 1;
            }
        }
    }
}

void handleFloat(char* current_type) {
    char *token = strtok(yytext, "=");
    token = trimWhitespace(token);

    if (token != NULL) {
        for (int i = 1; i <= var_len; i++) {
	    if (strcmp(variables[i], token) == 0) {
		if(strcmp(current_type, "var") == 0 || strcmp(current_type, "const") == 0) {
                	printf("Error at Line %d: '%s' has been defined before.\n", lineno, token);	
			exit(1);
		}
	    }
	}

        for (int i = 1; i <= const_len; i++) {
            if (strcmp(constants[i], token) == 0) {
                if(strcmp(current_type, "var") == 0 || strcmp(current_type, "const") == 0) {
                	printf("Error at Line %d: '%s' has been defined before.\n", lineno, token);	
		}
            }
        }

	if (strcmp(current_type, "assign") == 0) {
	    for (int i = 1; i <= const_len; i++) {
		if (strcmp(constants[i], token) == 0) {
			printf("Error at Line %d: '%s' can't be assigned.\n", lineno, token);	
			exit(1);
		}
	    }

	    int i=1;
            	
            for (; i <= value_len; i++) {
	    	if (strcmp(identifier[i], token) == 0)
			break;	
	    }
		
            if(i == value_len + 1) {
		printf("Error at Line %d: %s is not assigned before.\n", lineno, token);
		exit(1);
	    }
	    
   	    token = strtok(NULL, " \t\n\r");
            if (token != NULL) {
                fprintf(output_file, "%s - FLOATING_CONSTANT\n", token);
                value[i].FLOAT = atof(token);
                choose[i] = 2;
	    }
        }
	
        else if (strcmp(current_type, "var") == 0) {
            	fprintf(output_file, "%s - IDENTIFIER\n", token);
		var_len++;
            	strcpy(variables[var_len], token);
            	value_len++;
                strcpy(identifier[value_len], token);
                strcpy(datatype[value_len], "VAR");
                token = strtok(NULL, " \t\n\r");
		token = trimWhitespace(token);
                 if (token != NULL) {
                    fprintf(output_file, "%s - FLOATING_CONSTANT\n", token);
                    value[value_len].FLOAT = atof(token);
                    choose[value_len] = 2;
                }
        }

        else if (strcmp(current_type, "const") == 0) {
            fprintf(output_file, "%s - IDENTIFIER\n", token);
            const_len++;
            strcpy(constants[const_len], token);
            value_len++;
            strcpy(identifier[value_len], token);
            strcpy(datatype[value_len], "CONST");
            token = strtok(NULL, " \t\n\r");
	    token = trimWhitespace(token);
            if (token != NULL) {
                fprintf(output_file, "%s - FLOATING_CONSTANT\n", token);
                value[value_len].FLOAT = atof(token);
                choose[value_len] = 2;
            }
        }
    }
}

void handleCharacter(char *current_type)
{
    char *token = strtok(yytext, "=");
    token = trimWhitespace(token);
    if (token != NULL)
    {
        for (int i = 1; i <= var_len; i++)
        {
            if (strcmp(variables[i], token) == 0)
            {
                if (strcmp(current_type, "var") == 0 || strcmp(current_type, "const") == 0)
                {
                    printf("Error at Line %d: '%s' has been defined before.\n", lineno, token);
                    exit(1);
                }
            }
        }
        for (int i = 1; i <= const_len; i++)
        {
            if (strcmp(constants[i], token) == 0)
            {
                if (strcmp(current_type, "var") == 0 || strcmp(current_type, "const") == 0)
                {
                    printf("Error at Line %d: '%s' has been defined before.\n", lineno, token);
                }
            }
        }
        if (strcmp(current_type, "assign") == 0)
        {
            for (int i = 1; i <= const_len; i++)
            {
                if (strcmp(constants[i], token) == 0)
                {
                    printf("Error at Line %d: '%s' can't be assigned.\n", lineno, token);
                    exit(1);
                }
            }
            int i = 1;

            for (; i <= value_len; i++)
            {
                if (strcmp(identifier[i], token) == 0)
                    break;
            }
            if (i == value_len + 1)
            {
                printf("Error at Line %d: %s is not assigned before.\n", lineno, token);
                exit(1);
            }

            token = strtok(NULL, " \t\n\r\f\v");
            if (token != NULL)
            {
                fprintf(output_file, "%s - CHARACTER_CONSTANT\n", token);
                value[i].CHAR = token[1];
                choose[i] = 3;
            }
        }
        else if (strcmp(current_type, "var") == 0)
        {
            fprintf(output_file, "%s - IDENTIFIER\n", token);
            var_len++;
            strcpy(variables[var_len], token);
            value_len++;
            strcpy(identifier[value_len], token);
            strcpy(datatype[value_len], "VAR");
            token = strtok(NULL, " \t\n\r\f\v");
            token = trimWhitespace(token);
            if (token != NULL)
            {
                fprintf(output_file, "%s - CHARACTER_CONSTANT\n", token);
                value[value_len].CHAR = token[1];
                choose[value_len] = 3;
            }
        }
        else if (strcmp(current_type, "const") == 0)
        {
            fprintf(output_file, "%s - IDENTIFIER\n", token);
            const_len++;
            strcpy(constants[const_len], token);
            value_len++;
            strcpy(identifier[value_len], token);
            strcpy(datatype[value_len], "CONST");
            token = strtok(NULL, " \t\n\r\f\v");
            token = trimWhitespace(token);
            if (token != NULL)
            {
                fprintf(output_file, "%s - CHARACTER_CONSTANT\n", token);
                value[value_len].CHAR = token[1];
                choose[value_len] = 3;
            }
        }
    }
}

void handleString(char *current_type)
{
    char *token = strtok(yytext, "=");
    token = trimWhitespace(token);
    if (token != NULL)
    {
        for (int i = 1; i <= var_len; i++)
        {
            if (strcmp(variables[i], token) == 0)
            {
                if (strcmp(current_type, "var") == 0 || strcmp(current_type, "const") == 0)
                {
                    printf("Error at Line %d: '%s' has been defined before.\n", lineno, token);
                    exit(1);
                }
            }
        }
        for (int i = 1; i <= const_len; i++)
        {
            if (strcmp(constants[i], token) == 0)
            {
                if (strcmp(current_type, "var") == 0 || strcmp(current_type, "const") == 0)
                {
                    printf("Error at Line %d: '%s' has been defined before.\n", lineno, token);
                }
            }
        }
        if (strcmp(current_type, "assign") == 0)
        {
            for (int i = 1; i <= const_len; i++)
            {
                if (strcmp(constants[i], token) == 0)
                {
                    printf("Error at Line %d: '%s' can't be assigned.\n", lineno, token);
                    exit(1);
                }
            }
            int i = 1;

            for (; i <= value_len; i++)
            {
                if (strcmp(identifier[i], token) == 0)
                    break;
            }

            if (i == value_len + 1)
            {
                printf("Error at Line %d: %s is not assigned before.\n", lineno, token);
                exit(1);
            }
            token = strtok(NULL, " \t\n\r\f\v");
            if (token != NULL)
            {
                fprintf(output_file, "%s - STRING_LITERAL\n", token);
                strcpy(value[i].STRING, token);
                choose[i] = 4;
            }
        }
        else if (strcmp(current_type, "var") == 0)
        {
            fprintf(output_file, "%s - IDENTIFIER\n", token);
            var_len++;
            strcpy(variables[var_len], token);
            value_len++;
            strcpy(identifier[value_len], token);
            strcpy(datatype[value_len], "VAR");
            token = strtok(NULL, " \t\n\r\f\v");
            token = trimWhitespace(token);
            if (token != NULL)
            {
                fprintf(output_file, "%s - STRING_LITERAL\n", token);
                strcpy(value[value_len].STRING, token);
                choose[value_len] = 4;
            }
        }
        else if (strcmp(current_type, "const") == 0)
        {
            fprintf(output_file, "%s - IDENTIFIER\n", token);
            const_len++;
            strcpy(constants[const_len], token);
            value_len++;
            strcpy(identifier[value_len], token);
            strcpy(datatype[value_len], "CONST");
            token = strtok(NULL, " \t\n\r\f\v");
            token = trimWhitespace(token);
            if (token != NULL)
            {
                fprintf(output_file, "%s - STRING_LITERAL\n", token);
                strcpy(value[value_len].STRING, token);
                choose[value_len] = 4;
            }
        }
    }
}

%}

%option noyywrap

cKeywords((block)|(select)|(option)|(otherwise)|(end_select)|(repeat)|(end_repeat)|(var)|(const)|(return)|(exit)|(resume)|(true)|(false)|(jump)|(size)|(static)|(try)|(catch)|(not))

%%

[\n]									{ lineno++; }
[ \t] {}

(@).*				        				{ fprintf(output_file, "%s\t- SINGLE_LINE_COMMENT\n", yytext); }
"<*"([^*]|[\r\n]|(\*+([^*>]|[\r\n])))*"*>" 				{ fprintf(output_file, "%s\t- MULTILINE_COMMENT\n", yytext); }

"<*".* {
    printf("Error at Line %d: Unclosed Comment: %s\n", lineno, yytext);
    exit(1);
}

.*"*>" {
    printf("Error at Line %d: Unexpected Closing Comment: %s\n", lineno, yytext);
    exit(1);
}

([#][" "]*(define)[" "]*([A-Za-z]+)[" "]*[A-Za-z0-9/.]+) { fprintf(output_file, "%s\t- MACRO\n", yytext); }

\[\[[ ]*[-+]?[0-9]+([ ]*,[ ]*[-+]?[0-9]+)*[ ]*\]\] 			{ fprintf(output_file, "%s\t- INTEGER_ARRAY\n", yytext); constant_count++; }
\[\[[ ]*[-+]?[0-9]*\.[0-9]+([ ]*,[ ]*[-+]?[0-9]*\.[0-9]+)*[ ]*\]\] 	{ fprintf(output_file, "%s\t- FLOAT_ARRAY\n", yytext); constant_count++; }
\[\[[ ]*('[^\']')([ ]*,[ ]*('[^\']'))*[ ]*\]\]				{ fprintf(output_file, "%s\t- CHARACTER_ARRAY\n", yytext); constant_count++; }
\[\[[ ]*(\"[^\"]*\")([ ]*,[ ]*(\"[^\"]*\"))*[ ]*\]\]			{ fprintf(output_file, "%s\t- STRING_ARRAY\n", yytext); constant_count++; }


var|const|assign {
    	strcpy(current_type, yytext);
	yylval.str = strdup(yytext);
    	return DATA_TYPE;
}

[a-zA-Z_][a-zA-Z0-9_]* {
	fprintf(output_file, "%s\t- IDENTIFIER\n", yytext); identifier_count++;
    	yylval.str = strdup(yytext); return IDENTIFIER;
}

//[a-zA-Z_][a-zA-Z0-9_]*[ ]*[=][ ]*([-+]?[0-9]+) {
//	handleInteger(current_type);
//}

//[a-zA-Z_][a-zA-Z0-9_]*[ ]*[=][ ]*([-+]?[0-9]*\.[0-9]+) {
//    	handleFloat(current_type);
//}

//[a-zA-Z_][a-zA-Z0-9_]*[ ]*[=][ ]*(\'[^\']\') {
//    	handleCharacter(current_type);
//}

//[a-zA-Z_][a-zA-Z0-9_]*[ ]*[=][ ]*(\"[^\"]*\") {
//	handleString(current_type);
//}

{cKeywords}	        			{ fprintf(output_file, "%s\t- KEYWORD\n", yytext); keyword_count++; }


"("                                 		{ fprintf(output_file, "%s\t- OPENING BRACKETS\n", yytext); special_symbol_count++; }
")"                                 		{ fprintf(output_file, "%s\t- CLOSING BRACKETS\n", yytext); special_symbol_count++; }
"{"                                 		{ fprintf(output_file, "%s\t- OPENING BRACES\n", yytext); special_symbol_count++; }
"}"                                 		{ fprintf(output_file, "%s\t- CLOSING BRACES\n", yytext); special_symbol_count++; }
":"                                 		{ fprintf(output_file, "%s\t- COLON\n", yytext); special_symbol_count++; }
";"                                 		{ fprintf(output_file, "%s\t- SEMICOLON\n", yytext); special_symbol_count++; }
","                                 		{ fprintf(output_file, "%s\t- COMMA\n", yytext); special_symbol_count++; }
">>"                               		{ fprintf(output_file, "%s\t- INPUT\n", yytext); special_symbol_count++; }
"<<"                                		{ fprintf(output_file, "%s\t- OUTPUT\n", yytext); special_symbol_count++; }
            
"+"                                 		{ fprintf(output_file, "%s\t- PLUS\n", yytext); operator_count++; 
						return PLUS; }
"-"                                 		{ fprintf(output_file, "%s\t- MINUS\n", yytext); operator_count++; 
						return MINUS; }
"*"                                 		{ fprintf(output_file, "%s\t- MULTIPLY\n", yytext); operator_count++; 
						return MULTIPLY }
"**"                                		{ fprintf(output_file, "%s\t- POWER\n", yytext); operator_count++; 
						return POWER; }
"/"                                 		{ fprintf(output_file, "%s\t- DIVIDE\n", yytext); operator_count++; 
						return DIVIDE; }
"%"                                 		{ fprintf(output_file, "%s\t- MODULO\n", yytext); operator_count++; 
						return MODULO; }
"="                                		{ fprintf(output_file, "%s\t- ASSIGNMENT\n", yytext); operator_count++; 
						return '='; }
            
"<"                                 		{ fprintf(output_file, "%s\t- LESS_THAN\n", yytext); operator_count++; }
"<="                                		{ fprintf(output_file, "%s\t- LESS_THAN_OR_EQUAL\n", yytext); operator_count++; }
">"                                 		{ fprintf(output_file, "%s\t- GREATER_THAN\n", yytext); operator_count++; }
">="                                		{ fprintf(output_file, "%s\t- GREATER_THAN_OR_EQUAL\n", yytext); operator_count++; }
"=="                                		{ fprintf(output_file, "%s\t- EQUALS\n", yytext); operator_count++; }
"!="                                		{ fprintf(output_file, "%s\t- NOT_EQUAL\n", yytext); operator_count++; }
            
"++"                                		{ fprintf(output_file, "%s\t- INCREMENT\n", yytext); operator_count++; }
"--"                                		{ fprintf(output_file, "%s\t- DECREMENT\n", yytext); operator_count++; }
            
"&&"                                		{ fprintf(output_file, "%s\t- LOGICAL_AND\n", yytext); operator_count++; }
"||"                                		{ fprintf(output_file, "%s\t- LOGICAL_OR\n", yytext); operator_count++; }
"&"                   	            		{ fprintf(output_file, "%s\t- BITWISE_AND\n", yytext); operator_count++; }
"|"                    	            		{ fprintf(output_file, "%s\t- BITWISE_OR\n", yytext); operator_count++; }
"^"                    	            		{ fprintf(output_file, "%s\t- BITWISE_XOR\n", yytext); operator_count++; }
"!"                                 		{ fprintf(output_file, "%s\t- LOGICAL_NOT\n", yytext); operator_count++; }

[-+]?[0-9]+					{ 
							fprintf(output_file, "%s\t- INTEGER_CONSTANT\n", yytext); constant_count++; 
							yylval.ival = atoi(yytext); return INTEGER_CONSTANT;
						}
[-+]?[0-9]*\.[0-9]+				{
 							fprintf(output_file, "%s\t- FLOATING_CONSTANT\n", yytext); constant_count++; 
							yylval.fval = atof(yytext); return FLOATING_CONSTANT;
						}
\'[^\']\' 					{ 
							fprintf(output_file, "%s\t- CHARACTER_CONSTANT\n", yytext); constant_count++; 
							yylval.cval = yytext[1]; return CHARACTER_CONSTANT;
						}
\"[^\"]*\"					{ 
							fprintf(output_file, "%s\t- STRING_LITERAL\n", yytext); constant_count++; 
							yylval.sval = strdup(yytext); return STRING_LITERAL;
						}
           
"input"                	            		{ fprintf(output_file, "%s\t- IDENTIFIER\n", yytext); identifier_count++; }
"output"                            		{ fprintf(output_file, "%s\t- IDENTIFIER\n", yytext); identifier_count++; }


"repeat"([^*]|[\r\n]|(\*+([^*>]|[\r\n])))*"end_repeat" {
    int statement = 0; 

    fprintf(output_file, "%s\n- REPEATED_STATEMENT starting at line %d\n", yytext, lineno);

    char *line = strtok(yytext, "\n");

    while (line != NULL) {
        if (strcmp(line, "") != 0) {      
            statement++;
        }

        line = strtok(NULL, "\n"); 
    }

    fprintf(output_file, "No. of statements: %d\n", statement - 2);
}

"repeat".* {
    printf("Error at Line %d: Unclosed Loop: %s\n", lineno, yytext);
    exit(1);
}

"end_repeat".* {
    printf("Error at Line %d: Unexpected Loop: %s\n", lineno, yytext);
    exit(1);
}

"select"([^*]|[\r\n]|(\*+([^*>]|[\r\n])))*"end_select" {
    int total_options = 0;
    int otherwise_count = 0;

    fprintf(output_file, "\n%s - CONDITIONAL_STATEMENT\n", yytext);

    char *line = strtok(yytext, "\n");
    while (line != NULL) {
        if (strcmp(line, "") != 0) {
            if (strstr(line, "option") != NULL) {
                total_options++;
            } else if (strstr(line, "otherwise") != NULL) {
                otherwise_count++;
            }
        }
        line = strtok(NULL, "\n");
    }

    if (otherwise_count > 1) {
        printf("Error at Line %d: Multiple 'otherwise' statements found within the block\n", lineno);
    } 
    else {
        fprintf(output_file, "Total options within the block: %d\n", total_options + otherwise_count);
    }
}

"end_select".* {
    printf("Error at Line %d: Unexpected Condition: %s\n", lineno, yytext);
    exit(1);
}

.           					{ printf("Error at Line %d: %s", lineno, yytext); exit(1);}

%%

int main()
{

    output_file = fopen("output.txt", "w");
    if (output_file == NULL) {
        perror("Error opening output file");
        return 1;
    }

    FILE *input_file = fopen("input.txt", "r");
    if (input_file == NULL) {
        perror("Error opening input file");
        return 1;
    }

    yyin = input_file;
    yylex();

    if (keyword_count)
        fprintf(output_file, "\nKeyword Count: %d\n", keyword_count);
    if (identifier_count + value_len)
        fprintf(output_file, "Identifier Count: %d\n", identifier_count + value_len);
    if (special_symbol_count)
        fprintf(output_file, "Special Symbol Count: %d\n", special_symbol_count);
    if (constant_count + value_len)
        fprintf(output_file, "Constant/Literal Count: %d\n", constant_count + value_len);
    if (operator_count)
        fprintf(output_file, "Operator Count: %d\n\n", operator_count);

    if (value_len > 0) {

        fprintf(output_file, "\n\n--SYMBOL TABLE--\n");

        fprintf(output_file, "+--------------------------------+--------------------------------+--------------------------------+\n");
        fprintf(output_file, "|          IDENTIFIER            |            DATATYPE            |             VALUE              |\n");
        fprintf(output_file, "+--------------------------------+--------------------------------+--------------------------------+\n");

        for (int i = 1; i <= value_len; i++) {

            fprintf(output_file, "| %-30s | %-30s | ", identifier[i], datatype[i]);

            if (choose[i] == 1)
                fprintf(output_file, "%-30d |\n", value[i].INT);

            else if (choose[i] == 2)
                fprintf(output_file, "%-30f |\n", value[i].FLOAT);

            else if (choose[i] == 3)
                fprintf(output_file, "%-30c |\n", value[i].CHAR);

            else if (choose[i] == 4)
                fprintf(output_file, "%-30s |\n", value[i].STRING);

            fprintf(output_file, "+--------------------------------+--------------------------------+--------------------------------+\n");
        }
    }

    fclose(input_file);
    fclose(output_file);

    return 0;
}