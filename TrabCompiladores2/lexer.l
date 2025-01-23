%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tokens.h"
#include "parser.tab.h"

extern void yyerror(const char* s);

// Variáveis globais
int yylineno = 1;
int yycolumn = 1;
SymbolTable symbol_table; // Tabela de símbolos para identificadores

// Inicialização da tabela de símbolos
void initialize() {
    init_symbol_table(&symbol_table);
}

// Função para reportar erros de tokens inválidos
void report_error(const char* msg, const char* lexeme, int line, int col);

%}

%option noyywrap

%x COMMENT

%%
[ \t]+          { yycolumn += yyleng; }  // Ignorar espaços e tabulações

"//".*          { yycolumn += yyleng; }  // Comentários de linha única

"/*"            { yycolumn += yyleng; BEGIN(COMMENT); }
<COMMENT>"*/"   { yycolumn += yyleng; BEGIN(INITIAL); }
<COMMENT>[^*\n]* { yycolumn += yyleng; }
<COMMENT>\n     { yylineno++; yycolumn = 1; }
<COMMENT>.      { yycolumn += yyleng; }
<COMMENT><<EOF>> {
                    report_error("Comentário não fechado", "", yylineno, yycolumn);
                }

\n              { yylineno++; yycolumn = 1; }

"=="            { yycolumn += yyleng; return EQ; }
"!="            { yycolumn += yyleng; return NEQ; }
"<="            { yycolumn += yyleng; return LE; }
">="            { yycolumn += yyleng; return GE; }
"&&"            { yycolumn += yyleng; return AND; }
"||"            { yycolumn += yyleng; return OR; }
"+="            { yycolumn += yyleng; return PLUS_ASSIGN; }
"-="            { yycolumn += yyleng; return MINUS_ASSIGN; }
"*="            { yycolumn += yyleng; return MUL_ASSIGN; }
"/="            { yycolumn += yyleng; return DIV_ASSIGN; }
"+"             { yycolumn += yyleng; return PLUS; }
"-"             { yycolumn += yyleng; return MINUS; }
"*"             { yycolumn += yyleng; return MUL; }
"/"             { yycolumn += yyleng; return DIV; }
"%"             { yycolumn += yyleng; return MOD; }
"="             { yycolumn += yyleng; return ASSIGN; }
";"             { yycolumn += yyleng; return SEMICOLON; }
","             { yycolumn += yyleng; return COMMA; }
"("             { yycolumn += yyleng; return LPAREN; }
")"             { yycolumn += yyleng; return RPAREN; }
"{"             { yycolumn += yyleng; return LBRACE; }
"}"             { yycolumn += yyleng; return RBRACE; }
"<"             { yycolumn += yyleng; return LT; }
">"             { yycolumn += yyleng; return GT; }
"!"             { yycolumn += yyleng; return NOT; }
"&"             { yycolumn += yyleng; return '&'; }
"#"             { yycolumn += yyleng; return '#'; }

[0-9]+(\.[0-9]+)? {
    yycolumn += yyleng;
    ASTNode* node;
    if (strchr(yytext, '.')) {
        node = create_node("REAL");
        node->value.real = atof(yytext);
        yylval = node;
        return REAL;
    } else {
        node = create_node("INTEGER");
        node->value.integer = atoi(yytext);
        yylval = node;
        return INTEGER;
    }
}

"\"".*?"\""     {
    yycolumn += yyleng;
    ASTNode* node = create_node("STRING");
    node->value.string = strdup(yytext);
    yylval = node;
    return STRING;
}

"'"[^'\n]"'"    {
    yycolumn += yyleng;
    ASTNode* node = create_node("CHAR");
    node->value.character = yytext[1];
    yylval = node;
    return CHAR;
}

[0-9]+[a-zA-Z_][a-zA-Z0-9_]* {
    report_error("Identificador malformado", yytext, yylineno, yycolumn);
    yycolumn += yyleng;
}

[a-zA-Z_][a-zA-Z0-9_]* {
    yycolumn += yyleng;
    int token;
    if (strcmp(yytext, "if") == 0) token = IF;
    else if (strcmp(yytext, "else") == 0) token = ELSE;
    else if (strcmp(yytext, "while") == 0) token = WHILE;
    else if (strcmp(yytext, "for") == 0) token = FOR;
    else if (strcmp(yytext, "return") == 0) token = RETURN;
    else if (strcmp(yytext, "int") == 0) token = INT_TYPE;
    else if (strcmp(yytext, "float") == 0) token = FLOAT_TYPE;
    else if (strcmp(yytext, "char") == 0) token = CHAR_TYPE;
    else if (strcmp(yytext, "void") == 0) token = VOID_TYPE;
    else if (strcmp(yytext, "include") == 0) token = INCLUDE;
    else if (strcmp(yytext, "scanf") == 0) token = SCANF;
    else if (strcmp(yytext, "printf") == 0) token = PRINTF;
    else {
        token = IDENTIFIER;
        insert_symbol(&symbol_table, yytext);
    }
    ASTNode* node = create_node(yytext);
    yylval = node;
    return token;
}

. {
    report_error("Token inválido", yytext, yylineno, yycolumn);
    yycolumn += yyleng;
}

%%

void report_error(const char* msg, const char* lexeme, int line, int col) {
    fprintf(stderr, "Erro léxico: %s em '%s' (linha %d, coluna %d)\n", msg, lexeme, line, col);
}
