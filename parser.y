%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct symboltableslot{
    char name[100];
    char type[10];
    char content[100];
};
typedef struct symboltableslot SymbolTableSlot;

SymbolTableSlot symbolTable[50][100];

void symbolTableInit();
int findAvailable();
int copySlotData(char* field, char* data, int tablePosition, char* specifyName);
int* lookup(char* name);
void dump();

int checkIdExist();
int returnLineCount();

int symbolTableCounter = 0;

char newFunctionName[100];
%}

 /* Keyword */
%token BOOL
%token BREAK
%token CHAR
%token CONTINUE
%token DO
%token ELSE
%token ENUM
%token EXTERN
%token FALSE
%token FLOAT
%token FOR
%token FN
%token IF
%token IN
%token INT
%token LET
%token LOOP
%token MATCH
%token MUT
%token PRINT
%token PRINTLN
%token PUB
%token RETURN
%token SELF
%token STATIC
%token STR
%token STRUCT
%token TRUE
%token USE
%token WHERE
%token WHILE
%token I32
%token F32
 
 /* Operator */
%token EQUAL
%token LESS 
%token LESSEQUAL
%token GRATER
%token GRATEREQUAL
%token NOTASSIGN
%token OR
%token AND
%token ASSIGNRETURNTYPE

%union{
    int number;
    char *string;
}

 /* String */
%token STRING

 /* Numbers */
%token INTEGER
%token PLAINREAL
%token EXPREAL
%token REAL

 /* Identifiers */
%token <string> ID

 /* Operator priority*/
%left '+''-'
%left '*''/'
%nonassoc UMINUS

%token LINEBREAK
%%

PROGRAM: FUNCTION | DECLARATION | LINEBREAK | PROGRAM PROGRAM;
TYPE: BOOL | STR | STRING | INT | FLOAT | I32 | F32;
VALUE: TRUE | FALSE | STRING | INTEGER;
ASSIGNABLE: VALUE | ID;
DECLARATION: CONSTANTDECLARATION ';'
             | VARIABLEDECLARATION ';'
             | ARRAYDECLARATION ';'
             | FUNCTIONCALL ';'
             | STATEMENT ';'
             | IFBLOCK
             | WHILEBLOCK
;
CONSTANTDECLARATION: LET ID '=' ASSIGNABLE
                     {
                        int result = copySlotData("content", yylval.string, symbolTableCounter, "0");
                        if(result){
                            copySlotData("name", $2, symbolTableCounter, "0");
                        }else{
                            copySlotData("content", "0", symbolTableCounter, "0");
                            copySlotData("type", "0", symbolTableCounter, "0");
                        }
                     }
                     | LET ID ':' TYPE
                     {
                        copySlotData("type", yylval.string, symbolTableCounter, "0");
                     } '=' ASSIGNABLE
                     {
                        int result = copySlotData("content", yylval.string, symbolTableCounter, "0");
                        if(result){
                            copySlotData("name", $2, symbolTableCounter, "0");
                        }else{
                            copySlotData("content", "0", symbolTableCounter, "0");
                            copySlotData("type", "0", symbolTableCounter, "0");
                        }
                     }
;
VARIABLEDECLARATION: LET MUT ID
                     {
                        copySlotData("name", $3, symbolTableCounter, "0");
                     }
                     | LET MUT ID '=' ASSIGNABLE
                     {
                        int result = copySlotData("content", yylval.string, symbolTableCounter, "0");
                        if(result){
                            copySlotData("name", $3, symbolTableCounter, "0");
                        }else{
                            copySlotData("content", "0", symbolTableCounter, "0");
                            copySlotData("type", "0", symbolTableCounter, "0");
                        }
                     }
                     | LET MUT ID ':' TYPE
                     {
                        copySlotData("type", yylval.string, symbolTableCounter, "0");
                        copySlotData("name", $3, symbolTableCounter, "0");
                     }
                     | LET MUT ID ':' TYPE
                     {
                        copySlotData("type", yylval.string, symbolTableCounter, "0");
                     } '=' ASSIGNABLE
                     {
                        int result = copySlotData("content", yylval.string, symbolTableCounter, "0");
                        if(result){
                            copySlotData("name", $3, symbolTableCounter, "0");
                        }else{
                            copySlotData("content", "0", symbolTableCounter, "0");
                            copySlotData("type", "0", symbolTableCounter, "0");
                        }
                     }
;
ARRAYDECLARATION: LET MUT ID '[' TYPE ',' INTEGER ']';
FUNCTION: FUNCTIONATTR '(' ')' BLOCKSTATEMENT
          | FUNCTIONATTR '(' ')' ASSIGNRETURNTYPE TYPE 
          {
              copySlotData("type", yylval.string, 0, newFunctionName);
          }
          BLOCKSTATEMENT
          | FUNCTIONATTR '(' FUNCTIONDEFINEPARAMETER ')' BLOCKSTATEMENT 
          | FUNCTIONATTR '(' FUNCTIONDEFINEPARAMETER ')' ASSIGNRETURNTYPE TYPE
          {
              copySlotData("type", yylval.string, 0, newFunctionName);
          }
          BLOCKSTATEMENT
          
;
FUNCTIONATTR: FN ID 
              {
                  symbolTableCounter++;

                  /* Function's content field represent variable inside function position*/
                  char symbolTablePosition[10];
                  sprintf(symbolTablePosition, "%d", symbolTableCounter);
                  copySlotData("content", symbolTablePosition, 0, "0");

                  copySlotData("name", $2, 0, "0");
                  strcpy(newFunctionName, $2);
              }
;
FUNCTIONDEFINEPARAMETER: ID ':' TYPE
                         {
                              copySlotData("type", yylval.string, symbolTableCounter, "0");
                              copySlotData("name", $1, symbolTableCounter, "0");
                         }
                         | ID ':' TYPE
                         {
                              copySlotData("type", yylval.string, symbolTableCounter, "0");
                              copySlotData("name", $1, symbolTableCounter, "0");
                         }
                         ',' FUNCTIONDEFINEPARAMETER
                         
;
BLOCKSTATEMENT: '{' PROGRAM '}' | LINEBREAK '{' PROGRAM '}';
STATEMENT: ID '=' EXPRESSION
           {
              if(!checkIdExist($1)){
                  yyerror(strcat($1, " not define\n"));
              }
           }
           | ID '[' INTEGEREXPRESSION ']' '=' EXPRESSION
           {
              if(!checkIdExist($1)){
                  yyerror(strcat($1, " not define\n"));
              }
           }
           | RETURN EXPRESSION
           | PRINT '(' EXPRESSION ')'
           | PRINTLN '(' EXPRESSION ')'
           | PRINT EXPRESSION
           | PRINTLN EXPRESSION
;
EXPRESSION: EXPRESSION EQUAL EXPRESSION
            | EXPRESSION LESS EXPRESSION
            | EXPRESSION LESSEQUAL EXPRESSION
            | EXPRESSION GRATER EXPRESSION
            | EXPRESSION GRATEREQUAL EXPRESSION
            | EXPRESSION NOTASSIGN EXPRESSION
            | EXPRESSION OR EXPRESSION
            | EXPRESSION AND EXPRESSION
            | INTEGEREXPRESSION
            | FUNCTIONCALL
            | '!' EXPRESSION
            | VALUE
            | ID 
            {
                if(!checkIdExist($1)){
                    yyerror(strcat($1, " not define\n"));
                }
            }
;
INTEGEREXPRESSION: '-' EXPRESSION %prec UMINUS
                   | EXPRESSION '+' EXPRESSION 
                   | EXPRESSION '-' EXPRESSION
                   | EXPRESSION '*' EXPRESSION
                   | EXPRESSION '/' EXPRESSION
                   | EXPRESSION '%' EXPRESSION
;
FUNCTIONCALL: ID '(' ')'
              {
                  if(!checkIdExist($1)){
                      yyerror(strcat($1, " not define\n"));
                  }
              }
              | ID '(' FUNCTIONCALLPARAMETER ')'
              {
                  if(!checkIdExist($1)){
                      yyerror(strcat($1, " not define\n"));
                  }
              }
;
FUNCTIONCALLPARAMETER: BOOL | STRING | INTEGER | ID
{
    checkIdExist($1);
}
| FUNCTIONCALLPARAMETER ',' FUNCTIONCALLPARAMETER;
IFBLOCK: IF '(' EXPRESSION ')' EXPRESSION
         | IF '(' EXPRESSION ')' BLOCKSTATEMENT
         | IF '(' EXPRESSION ')' BLOCKSTATEMENT ELSE BLOCKSTATEMENT
;
WHILEBLOCK: WHILE '(' EXPRESSION ')' BLOCKSTATEMENT;

%%
int main(){
    symbolTableInit();
    if(!yyparse()){
        printf("\nParsing complete\n");
    }else{
        printf("\nParsing failed\n");
    }
    printf("\n");
    dump();
}

void yyerror (char const *s) {
    int line = returnLineCount();
    printf ("line %d: %s", line, s);
}

void symbolTableInit(){
    for(int i=0;i<50;i++){
        for(int j=0;j<100;j++){
            strcpy(symbolTable[i][j].name, "0");
            strcpy(symbolTable[i][j].type, "0");
            strcpy(symbolTable[i][j].content, "0");
        }
    }
}

int findAvailable(int table){
    int position = 0;

    while(1){
        if(!strcmp(symbolTable[table][position].name, "0")){
            break;
        }else{
            position++;
        }
    }

    return position;
}

int copySlotData(char* field, char* data, int tablePosition, char* specifyName){     
    int position = findAvailable(tablePosition);
    int copyAvailable = 1;

    if(!strcmp(field, "name")){
        strcpy(symbolTable[tablePosition][position].name, data);
    }else if(!strcmp(field, "type")){
        if(!strcmp(specifyName, "0")){
            strcpy(symbolTable[tablePosition][position].type, data);
        }else{
            int* functionPosition = lookup(specifyName);
            strcpy(symbolTable[0][functionPosition[1]].type, data);
        }
    }else if(!strcmp(field, "content")){
        /* If data is ID, check before copy */
        int first = data[0];
        if((first == 34) || (first >= 48 && first <= 57)){
            strcpy(symbolTable[tablePosition][position].content, data);
        }else{
            if(checkIdExist(data)){
                strcpy(symbolTable[tablePosition][position].content, data);
            }else{
                yyerror(strcat(data, " not define\n"));
                copyAvailable = 0;
            }
        }
    }else{
        /* do nothing */
    }

    return copyAvailable;
}

int checkIdExist(char* name){
    int* result = lookup(name);
    int hint = 0;
    if(result[0] == -1){
        hint = 0;
    }else{
        hint = 1;
    }
    return hint;
}

int* lookup(char* name){
    int static result[2];

    /* Only search current table and root table */
    for(int i=0;i<100;i++){
        result[0] = -1;
        result[1] = -1;

        if(!strcmp(symbolTable[symbolTableCounter][i].name, name)){
            result[0] = symbolTableCounter;
            result[1] = i;
            break;
        }

        if(!strcmp(symbolTable[0][i].name, name)){
            result[0] = 0;
            result[1] = i;
            break;
        }
    }

    return result;
}

void dump(){
    for(int i=0;i<50;i++){
        if(strcmp(symbolTable[i][0].name, "0")){
            printf("Level: %d\n-------------------\n", i);
        }else{
            continue;
        }

        for(int j=0;j<100;j++){
            if(strcmp(symbolTable[i][j].name, "0")){
                printf("name: %s\n", symbolTable[i][j].name);
                printf("type: %s\n", symbolTable[i][j].type);
                printf("content: %s\n\n", symbolTable[i][j].content);
            }else{
                continue;
            }
        }
    }
}