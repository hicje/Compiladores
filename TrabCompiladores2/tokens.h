#ifndef TOKENS_H
#define TOKENS_H

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define YYSTYPE ASTNode*    // Definir YYSTYPE aqui

#define HASH_SIZE 101

// Definição da estrutura para a tabela de símbolos (identificadores)
typedef struct Symbol {
    char* name;
    // Você pode adicionar informações adicionais aqui (tipo, escopo, etc.)
    struct Symbol* next;
} Symbol;

typedef struct {
    Symbol* table[HASH_SIZE];
} SymbolTable;

// Funções para manipulação da tabela de símbolos
void init_symbol_table(SymbolTable* table);
void insert_symbol(SymbolTable* table, const char* name);
Symbol* find_symbol(SymbolTable* table, const char* name);
void free_symbol_table(SymbolTable* table);

// Definição da estrutura para os nós da árvore sintática abstrata (AST)
typedef struct ASTNode {
    char* name;
    union {
        int integer;
        float real;
        char character;
        char* string;
    } value;
    struct ASTNode** children;
    int child_count;
} ASTNode;

// Funções para manipulação da AST
ASTNode* create_node(const char* name);
void add_child(ASTNode* parent, ASTNode* child);
void print_ast(ASTNode* node, int level, FILE* output);
void free_ast(ASTNode* node);

// Função hash
unsigned int hash(const char* str);

#endif /* TOKENS_H */
