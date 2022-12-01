%{
#include <string.h>
#include "practica2.tab.h"

#define UPDT_1ST_LOC do \
    { \
        yylloc.first_line = yylloc.last_line; \
        yylloc.first_column = yylloc.last_column; \
    } while(0) 

%}

s       [ \t\r\n]+

eq      {s}?={s}?
qu      "\""|"\'"

com     "<!--"("-"?[^\-])*"-->"

ver     {s}version{eq}{qu}"1."[0-9]+{qu}
cod     {s}encoding{eq}{qu}[A-Za-z]([A-Za-z0-9._]|"-")*{qu}
header  "<?xml"{ver}{cod}?{s}?"?>"

name    [a-zA-Z:_][0-9a-zA-Z:_\-.]*
begTag  "<"{name}{s}?">"
endTag  "</"{name}{s}?">"

ref     &(#([0-9]+|x[0-9a-fA-F]+)|{name});
cont    ([^<&\n]|{ref})*

%%

{header} { 
    UPDT_1ST_LOC;
    yylloc.last_column += yyleng;
    return HEADER;
}
{begTag} {
    char *end;

    UPDT_1ST_LOC;
    yylloc.last_column += yyleng;

    strcpy(yylval.name, yytext+1);

    end = strchr(yylval.name, ' ');

    if(end == NULL)
        end = yylval.name + strlen(yytext)-2;

    *end = '\0';

    return BEGTAG;
}
{endTag} {
    char *end;

    UPDT_1ST_LOC;
    yylloc.last_column += yyleng;    

    strcpy(yylval.name, yytext+2);

    end = strchr(yylval.name, ' ');

    if(end == NULL)
        end = yylval.name + strlen(yytext)-3;

    *end = '\0';
    
    return ENDTAG;
}
{com}    {
    UPDT_1ST_LOC;
    yylloc.last_column += yyleng;
    return COM;
}
{s}      {
    int i = 0, nl = 0;

    UPDT_1ST_LOC;
    
    for(; i < yyleng; i++) if(yytext[i] == '\n') nl++;
    
    yylloc.last_column = i? yyleng - nl + 1:
                            yylloc.last_column + yyleng;
    yylloc.last_line += nl;

    return SPA;
}
{cont}   {
    UPDT_1ST_LOC;
    yylloc.last_column += yyleng;

    return CONT;
}

.        {
    UPDT_1ST_LOC;
    yylloc.last_column++;
    return CONT_NV;
}

%%

int yywrap() { return 1; }

