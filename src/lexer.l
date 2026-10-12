/* ====================================================================
 *  LABORATORIO 1 - Analizador léxico de MiniC con Flex
 *  Compiladores (707-00088) - UIP
 *
 *  Este archivo se completa paso a paso siguiendo docs/GUIA_LAB.md.
 *  Busca las marcas que dicen COMPLETAR (entre arrobas o dentro de un comentario): ahí trabajas.
 *  Todo lo demás ya está hecho y la guía te lo explica.
 *
 *  Un archivo .l tiene tres partes separadas por una línea con %%
 *     1) definiciones   opciones, nombres para patrones, código C auxiliar
 *     2) reglas         PATRON   { ACCION escrita en C }
 *     3) código C       aquí, la función main
 * ==================================================================== */

/* noyywrap  : no hay más archivos de entrada cuando se acaba el actual.
 * yylineno  : Flex cuenta las líneas por nosotros (variable yylineno).
 * nounput noinput : quita dos funciones que no usamos (evita avisos). */
%option noyywrap yylineno nounput noinput

/* Condición de inicio EXCLUSIVA = un "modo" del analizador.
 * Mientras estemos en el modo COMMENT solo se aplican las reglas que
 * empiezan con <COMMENT>. La vas a usar en el Paso 9. */
%x COMMENT

%{
#include <stdio.h>

/* emit imprime un token con el formato   <línea> <TIPO> <lexema>
 *   yytext   = el texto que coincidió con el patrón
 *   yylineno = línea actual (la lleva Flex) */
static void emit(const char *type, const char *lex) {
    printf("%d %s %s\n", yylineno, type, lex);
}

/* Paso 9 (comentarios anidados):
 *   depth        = cuántos comentarios siguen abiertos en este momento
 *   comment_line = línea donde empezó el comentario (para el error de fin de archivo) */
static int depth __attribute__((unused)) = 0;
static int comment_line __attribute__((unused)) = 0;
%}

/* Nombres reutilizables para patrones.  [0-9] = un dígito cualquiera. */
DIGIT   [0-9]
/* ID = una letra o _ , seguida de cero o más letras, dígitos o _ */
ID      [A-Za-z_][A-Za-z0-9_]*

%%

    /* ===== YA ESTÁN HECHAS (las lees y entiendes en el Paso 1) ===== */

[ \t\r\n]+      { /* espacios y saltos de línea: se ignoran; yylineno cuenta las líneas */ }

"//".*          { /* comentario de línea: de // hasta el fin de la línea; se ignora */ }

    /* Comentario de bloque SIMPLE escrito con una expresión regular (Paso 5).
     * En el Paso 9 lo reemplazarás por comentarios ANIDADOS y entonces BORRARÁS esta regla. */
"/*"([^*]|\*+[^*/])*\*+"/"      { /* comentario de bloque: se ignora */ }

    /* ===== PASO 2: palabras reservadas ===== */
"@COMPLETAR_PALABRAS_RESERVADAS@"     { emit("KEYWORD", yytext); }

    /* Identificadores (ya está). Pregunta del Paso 2: ¿por qué va DESPUÉS de las palabras reservadas? */
{ID}            { emit("IDENT", yytext); }

    /* ===== PASO 3: números ===== */
"@COMPLETAR_FLOAT_CON_PUNTO@"         { emit("FLOAT", yytext); }
"@COMPLETAR_FLOAT_CON_EXPONENTE@"     { emit("FLOAT", yytext); }
"@COMPLETAR_INT@"                     { emit("INT", yytext); }

    /* ===== PASO 4: operadores ===== */
"@COMPLETAR_OPERADORES_DE_2_CARACTERES@"      { emit("OP", yytext); }
"@COMPLETAR_OPERADORES_DE_1_CARACTER@"        { emit("OP", yytext); }

    /* ===== PASO 5: signos de puntuación ===== */
"@COMPLETAR_PUNTUACION@"              { emit("PUNCT", yytext); }

    /* ===== PASO 7: cadenas de texto y caracteres ===== */
"@COMPLETAR_CADENA@"                  { emit("STRING", yytext); }
"@COMPLETAR_CADENA_SIN_CERRAR@"       { /* COMPLETAR_ERROR_CADENA */ }
"@COMPLETAR_CARACTER@"                { emit("CHAR", yytext); }

    /* ===== PASO 9: comentarios anidados con condiciones de inicio ===== */
"/*"                { /* COMPLETAR_ENTRAR_COMENTARIO */ }
<COMMENT>"/*"       { /* COMPLETAR_ANIDAR */ }
<COMMENT>"*/"       { /* COMPLETAR_CERRAR */ }
<COMMENT>.|\n       { /* dentro de un comentario todo se ignora (ya está) */ }
<COMMENT><<EOF>>    { /* COMPLETAR_FIN_DE_ARCHIVO */ yyterminate(); }

    /* ===== PASO 10: tu variante (agrega aquí tus reglas) ===== */


    /* ===== PASO 8: carácter inválido  (SIEMPRE debe ser la ÚLTIMA regla) ===== */
"@COMPLETAR_COMODIN@"                 { /* COMPLETAR_ERROR_CARACTER */ }

%%

int main(void) {
    yylex();      /* lee la entrada estándar y aplica las reglas hasta el final */
    return 0;
}
