%{
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#define TAG_LEN 16

extern char yylex();
void yyerror (char const*);
%}
%union{
    char name[16];
}

%locations

%token HEADER 0 SPA 1 COM 2 CONT 3 CONT_NV 4
%token<name> BEGTAG 5 ENDTAG 6
%type obj colect opt
%start S

%%

S :
      HEADER opt obj opt
    | HEADER error
        {
            char msg[128];
            sprintf(msg, "Error en la linea %d, columna %d: el fichero debe tener un tag principal valido",
                    @2.first_line, @2.first_column);
            yyerror(msg);
            yyclearin;
            YYERROR;
        }
    | SPA error
        {
            yyerror("Error: el fichero debe comenzar por la cabecera");
            yyclearin;
            YYERROR;
        }
    | COM error
        {
            yyerror("Error: el fichero debe comenzar por la cabecera");
            yyclearin;
            YYERROR;
        }
    | HEADER opt obj opt error
        {
            char msg[128];
            sprintf(msg, "Error en la linea %d, columna %d: solo se admiten objetos dentro del tag principal",
                    @5.last_line, @5.first_column);
            yyerror(msg);
            yyclearin;
            YYERROR;
        }
    | HEADER opt BEGTAG colect
        {
            char msg[128];
            sprintf(msg, "Error en la linea %d, columna %d: tag sin pareja. Se esperaba </%s>, se obtuvo EOF",
                    @4.last_line, @4.last_column, $3);
            yyerror(msg);
            yyclearin;
            YYERROR;
        }
	  ;

opt : /*vacío*/
    | opt SPA 
    | opt COM 
    ;

colect : /*vacío*/
    | colect obj  
    | colect SPA  
    | colect COM  
    | colect CONT 
    | colect CONT_NV
        {
            char msg[128];
            sprintf(msg, "Error en la linea %d, columna %d: no se admite '&' ni '<' como contenido",
                    @2.last_line, @2.first_column);
            yyerror(msg);
            yyclearin;
            YYERROR;
        }
    ;

obj : 
      BEGTAG colect ENDTAG 
        {
            if(strcmp($1, $3))
            {
                char msg[128];
                sprintf(msg, "Error en la linea %d, columna %d: tag sin pareja. Se esperaba </%s>, se obtuvo </%s>",
                        @3.last_line, @3.first_column, $1, $3);
                yyerror(msg);
                yyclearin;
                YYERROR;
            }
        }
    | BEGTAG error ENDTAG
        {
            char msg[128];
            sprintf(msg, "Error en la linea %d, columna %d: objeto no valido dentro del tag <%s>",
                    @2.last_line, @2.first_column, $1);
            yyerror(msg);
            yyclearin;
            YYERROR;
        }
    ;

%%

int main() {
	if(!yyparse()) printf("Sintaxis XML correcta.\n");
	return 0;
}

void yyerror(char const *msg)
{
    if(strcmp(msg, "syntax error"))
      fprintf(stderr, "%s\n", msg);
}

