# Trabalho de Compiladores - Analisador Sintático com Yacc
Este repositório contém um projeto de Compiladores que utiliza o Yacc para implementar um analisador sintático. O objetivo principal é demonstrar o processo de compilação de uma linguagem simples, desde a definição das regras gramaticais até a análise sintática do código-fonte.<br/>

Descrição:<br/>
## Yacc (Yet Another Compiler-Compiler): 
- Ferramenta que gera um analisador sintático (parser) a partir de uma gramática formal.<br/>
## Objetivo:<br/>
- Implementar um parser capaz de reconhecer construções específicas de uma linguagem hipotética(Semelhante ao C).<br/>
## Fluxo:<br/>
- Lex realiza a análise léxica.<br/>
- Yacc utiliza as regras gramaticais definidas em um arquivo .y para gerar o analisador sintático.<br/>
- O código gerado é compilado junto com as demais partes do projeto, resultando em um executável capaz de ler um arquivo de código-fonte e verificar se ele está sintaticamente correto.<br/>
## Pré-requisitos
GCC ou outro compilador C/C++ instalado.<br/>
Yacc.<br/>
Lex/Flex .<br/>
