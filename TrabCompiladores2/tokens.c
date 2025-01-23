#include "tokens.h"

// Implementação da função hash
unsigned int hash(const char* str) {
    unsigned int hash = 0;
    while (*str)
        hash = (hash << 5) + *str++;
    return hash % HASH_SIZE;
}

// Funções para a tabela de símbolos
void init_symbol_table(SymbolTable* table) {
    for (int i = 0; i < HASH_SIZE; i++) {
        table->table[i] = NULL;
    }
}

void insert_symbol(SymbolTable* table, const char* name) {
    unsigned int index = hash(name);
    Symbol* symbol = malloc(sizeof(Symbol));
    symbol->name = strdup(name);
    symbol->next = table->table[index];
    table->table[index] = symbol;
}

Symbol* find_symbol(SymbolTable* table, const char* name) {
    unsigned int index = hash(name);
    Symbol* symbol = table->table[index];
    while (symbol != NULL) {
        if (strcmp(symbol->name, name) == 0) {
            return symbol;
        }
        symbol = symbol->next;
    }
    return NULL;
}

void free_symbol_table(SymbolTable* table) {
    for (int i = 0; i < HASH_SIZE; i++) {
        Symbol* symbol = table->table[i];
        while (symbol != NULL) {
            Symbol* temp = symbol;
            symbol = symbol->next;
            free(temp->name);
            free(temp);
        }
        table->table[i] = NULL;
    }
}

// Funções para a AST
ASTNode* create_node(const char* name) {
    ASTNode* node = malloc(sizeof(ASTNode));
    node->name = strdup(name);
    node->children = NULL;
    node->child_count = 0;
    memset(&node->value, 0, sizeof(node->value));
    return node;
}

void add_child(ASTNode* parent, ASTNode* child) {
    parent->children = realloc(parent->children, sizeof(ASTNode*) * (parent->child_count + 1));
    parent->children[parent->child_count++] = child;
}

void print_ast(ASTNode* node, int level, FILE* output) {
    for (int i = 0; i < level; i++)
        fprintf(output, "  ");
    fprintf(output, "%s\n", node->name);
    for (int i = 0; i < node->child_count; i++)
        print_ast(node->children[i], level + 1, output);
}

void free_ast(ASTNode* node) {
    for (int i = 0; i < node->child_count; i++)
        free_ast(node->children[i]);
    free(node->children);
    free(node->name);
    free(node);
}
