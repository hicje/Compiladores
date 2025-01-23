%{
#include <stdio.h>
#include <stdlib.h>
#include "tokens.h"

extern int yylex();
extern FILE* yyin;
extern int yylineno;
extern char* yytext;

ASTNode* root;

void yyerror(const char* s);
%}

/* Definição da precedência dos operadores */
%left ASSIGN PLUS_ASSIGN MINUS_ASSIGN MUL_ASSIGN DIV_ASSIGN
%left OR
%left AND
%left EQ NEQ
%left LT GT LE GE
%left PLUS MINUS
%left MUL DIV MOD
%right NOT

%token '#' INCLUDE IF ELSE WHILE RETURN IDENTIFIER INTEGER REAL PLUS MINUS MUL DIV MOD
%token EQ NEQ LT GT LE GE AND OR NOT SEMICOLON COMMA LPAREN RPAREN LBRACE RBRACE
%token STRING CHAR ASSIGN PLUS_ASSIGN MINUS_ASSIGN MUL_ASSIGN DIV_ASSIGN
%token INT_TYPE FLOAT_TYPE CHAR_TYPE VOID_TYPE FOR PRINTF SCANF

%start program

%debug

%%

program:
        /* vazio */ { root = create_node("program"); }
    |   program element {
            add_child(root, $2);
        }
    ;

element:
        include_statement { $$ = $1; }
    |   function_definition { $$ = $1; }
    |   declaration_statement { $$ = $1; }
    ;

include_statement:
    '#' INCLUDE STRING {
        $$ = create_node("include_statement");
        add_child($$, $3);
    }
;

function_definition:
    type_specifier IDENTIFIER LPAREN parameter_list RPAREN compound_statement {
        $$ = create_node("function_definition");
        add_child($$, $1);
        add_child($$, $2);
        add_child($$, $4);
        add_child($$, $6);
    }
;

type_specifier:
        INT_TYPE { $$ = create_node("int"); }
    |   FLOAT_TYPE { $$ = create_node("float"); }
    |   CHAR_TYPE { $$ = create_node("char"); }
    |   VOID_TYPE { $$ = create_node("void"); }
    ;

parameter_list:
        parameter_list COMMA parameter {
            $$ = $1;
            add_child($$, $3);
        }
    |   parameter {
            $$ = create_node("parameter_list");
            add_child($$, $1);
        }
    |   /* vazio */ { $$ = create_node("parameter_list"); }
    ;

parameter:
    type_specifier IDENTIFIER {
        $$ = create_node("parameter");
        add_child($$, $1);
        add_child($$, $2);
    }
;

declaration:
    type_specifier init_declarator_list_opt {
        $$ = create_node("declaration");
        add_child($$, $1);
        if ($2 != NULL) add_child($$, $2);
    }
;

declaration_statement:
    declaration SEMICOLON {
        $$ = create_node("declaration_statement");
        add_child($$, $1);
    }
;

init_declarator_list_opt:
        init_declarator_list { $$ = $1; }
    |   /* vazio */ { $$ = NULL; }
    ;

init_declarator_list:
        init_declarator_list COMMA init_declarator {
            $$ = $1;
            add_child($$, $3);
        }
    |   init_declarator {
            $$ = create_node("init_declarator_list");
            add_child($$, $1);
        }
    ;

init_declarator:
        IDENTIFIER {
            $$ = create_node("init_declarator");
            add_child($$, $1);
        }
    |   IDENTIFIER ASSIGN assignment_expression {
            $$ = create_node("init_declarator");
            add_child($$, $1);
            add_child($$, $3);
        }
    ;

statement_list:
        statement_list statement {
            $$ = $1;
            add_child($$, $2);
        }
    |   /* vazio */ { $$ = create_node("statement_list"); }
    ;

statement:
        expression_statement { $$ = $1; }
    |   compound_statement { $$ = $1; }
    |   selection_statement { $$ = $1; }
    |   iteration_statement { $$ = $1; }
    |   jump_statement { $$ = $1; }
    |   input_statement { $$ = $1; }
    |   output_statement { $$ = $1; }
    |   declaration_statement { $$ = $1; }
    ;

compound_statement:
    LBRACE declaration_list statement_list RBRACE {
        $$ = create_node("compound_statement");
        add_child($$, $2);
        add_child($$, $3);
    }
;

declaration_list:
        declaration_list declaration_statement {
            $$ = $1;
            add_child($$, $2);
        }
    |   /* vazio */ { $$ = create_node("declaration_list"); }
    ;

expression_statement:
    expression_opt SEMICOLON {
        $$ = create_node("expression_statement");
        if ($1 != NULL) {
            add_child($$, $1);
        }
    }
;

expression_opt:
        expression { $$ = $1; }
    |   /* vazio */ { $$ = NULL; }
    ;

selection_statement:
        IF LPAREN expression RPAREN statement {
            $$ = create_node("if_statement");
            add_child($$, $3);
            add_child($$, $5);
        }
    |   IF LPAREN expression RPAREN statement ELSE statement {
            $$ = create_node("if_else_statement");
            add_child($$, $3);
            add_child($$, $5);
            add_child($$, $7);
        }
    ;

iteration_statement:
        WHILE LPAREN expression RPAREN statement {
            $$ = create_node("while_statement");
            add_child($$, $3);
            add_child($$, $5);
        }
    |   FOR LPAREN for_init_statement_opt SEMICOLON expression_opt SEMICOLON expression_opt RPAREN statement {
            $$ = create_node("for_statement");
            if ($3 != NULL) add_child($$, $3); // Inicialização
            if ($5 != NULL) add_child($$, $5); // Condição
            if ($7 != NULL) add_child($$, $7); // Incremento
            add_child($$, $9); // Corpo
        }
    ;

for_init_statement_opt:
        declaration { $$ = $1; }
    |   expression_opt { $$ = $1; }
    |   /* vazio */ { $$ = NULL; }
    ;

jump_statement:
    RETURN expression_opt SEMICOLON {
        $$ = create_node("return_statement");
        if ($2 != NULL) add_child($$, $2);
    }
;

input_statement:
    SCANF LPAREN STRING COMMA '&' IDENTIFIER RPAREN SEMICOLON {
        $$ = create_node("input_statement");
        add_child($$, $3);
        add_child($$, $6);
    }
;

output_statement:
        PRINTF LPAREN STRING RPAREN SEMICOLON {
            $$ = create_node("output_statement");
            add_child($$, $3);
        }
    |   PRINTF LPAREN STRING COMMA argument_expression_list RPAREN SEMICOLON {
            $$ = create_node("output_statement");
            add_child($$, $3);
            add_child($$, $5);
        }
    ;

expression:
        assignment_expression { $$ = $1; }
    ;

assignment_expression:
        logical_or_expression { $$ = $1; }
    |   unary_expression assignment_operator assignment_expression {
            $$ = create_node("assignment");
            add_child($$, $1);
            add_child($$, $2);
            add_child($$, $3);
        }
    ;

assignment_operator:
        ASSIGN { $$ = create_node("="); }
    |   PLUS_ASSIGN { $$ = create_node("+="); }
    |   MINUS_ASSIGN { $$ = create_node("-="); }
    |   MUL_ASSIGN { $$ = create_node("*="); }
    |   DIV_ASSIGN { $$ = create_node("/="); }
    ;

logical_or_expression:
        logical_or_expression OR logical_and_expression {
            $$ = create_node("or");
            add_child($$, $1);
            add_child($$, $3);
        }
    |   logical_and_expression { $$ = $1; }
    ;

logical_and_expression:
        logical_and_expression AND equality_expression {
            $$ = create_node("and");
            add_child($$, $1);
            add_child($$, $3);
        }
    |   equality_expression { $$ = $1; }
    ;

equality_expression:
        equality_expression EQ relational_expression {
            $$ = create_node("eq");
            add_child($$, $1);
            add_child($$, $3);
        }
    |   equality_expression NEQ relational_expression {
            $$ = create_node("neq");
            add_child($$, $1);
            add_child($$, $3);
        }
    |   relational_expression { $$ = $1; }
    ;

relational_expression:
        relational_expression LT additive_expression {
            $$ = create_node("lt");
            add_child($$, $1);
            add_child($$, $3);
        }
    |   relational_expression GT additive_expression {
            $$ = create_node("gt");
            add_child($$, $1);
            add_child($$, $3);
        }
    |   relational_expression LE additive_expression {
            $$ = create_node("le");
            add_child($$, $1);
            add_child($$, $3);
        }
    |   relational_expression GE additive_expression {
            $$ = create_node("ge");
            add_child($$, $1);
            add_child($$, $3);
        }
    |   additive_expression { $$ = $1; }
    ;

additive_expression:
        additive_expression PLUS multiplicative_expression {
            $$ = create_node("add");
            add_child($$, $1);
            add_child($$, $3);
        }
    |   additive_expression MINUS multiplicative_expression {
            $$ = create_node("sub");
            add_child($$, $1);
            add_child($$, $3);
        }
    |   multiplicative_expression { $$ = $1; }
    ;

multiplicative_expression:
        multiplicative_expression MUL unary_expression {
            $$ = create_node("mul");
            add_child($$, $1);
            add_child($$, $3);
        }
    |   multiplicative_expression DIV unary_expression {
            $$ = create_node("div");
            add_child($$, $1);
            add_child($$, $3);
        }
    |   multiplicative_expression MOD unary_expression {
            $$ = create_node("mod");
            add_child($$, $1);
            add_child($$, $3);
        }
    |   unary_expression { $$ = $1; }
    ;

unary_expression:
        NOT unary_expression {
            $$ = create_node("not");
            add_child($$, $2);
        }
    |   primary_expression { $$ = $1; }
    ;

primary_expression:
        IDENTIFIER {
            $$ = $1;
        }
    |   INTEGER {
            $$ = $1;
        }
    |   REAL {
            $$ = $1;
        }
    |   STRING {
            $$ = $1;
        }
    |   CHAR {
            $$ = $1;
        }
    |   LPAREN expression RPAREN {
            $$ = $2;
        }
    ;

argument_expression_list:
        argument_expression_list COMMA assignment_expression {
            $$ = $1;
            add_child($$, $3);
        }
    |   assignment_expression {
            $$ = create_node("arguments");
            add_child($$, $1);
        }
    ;

%%

void yyerror(const char* s) {
    fprintf(stderr, "Erro sintático na linha %d: %s próximo a '%s'\n", yylineno, s, yytext);
}

int main() {
    char filename[256];
    printf("Digite o nome do arquivo fonte: ");
    scanf("%s", filename);

    FILE* file = fopen(filename, "r");
    if (!file) {
        perror("Não foi possível abrir o arquivo fonte");
        return 1;
    }

    yyin = file;
    root = NULL;
    if (yyparse() == 0 && root != NULL) {
        printf("Análise sintática concluída com sucesso.\n");
        // Gerar a árvore sintática em um arquivo
        FILE* output = fopen("arvore_sintatica.txt", "w");
        if (output) {
            print_ast(root, 0, output);
            fclose(output);
            printf("Árvore sintática gerada no arquivo 'arvore_sintatica.txt'.\n");
        } else {
            perror("Não foi possível criar o arquivo da árvore sintática");
        }
        free_ast(root);
    } else {
        printf("Ocorreram erros durante a análise sintática.\n");
    }

    fclose(file);
    return 0;
}
