/* ============================================================
 *  Laboratorio 1 - Analizador léxico de MiniC (Flex)
 *  Compiladores (707-00088) - UIP
 *  Lee los comentarios TODO y complétalos. Todo lo que dice
 *  "ya está" funciona; no hace falta tocarlo.
 * ============================================================ */

%option noyywrap yylineno nounput noinput

/* TODO B1: declara aquí las condiciones de inicio exclusivas que necesites
 * (por ejemplo, una para los comentarios de bloque):   %x COMMENT           */

%{
#include <stdio.h>

/* Imprime un token con el formato exigido:  <línea> <TIPO> <lexema>   (ya está) */
static void emit(const char *type, const char *lex) {
    printf("%d %s %s\n", yylineno, type, lex);
}

/* TODO B2: variables para el contador de profundidad de comentarios anidados
 * y para recordar la línea donde empezó el comentario.                       */
%}

DIGIT   [0-9]
ID      [A-Za-z_][A-Za-z0-9_]*

%%

[ \t\r\n]+      { /* ya está: ignora espacios; yylineno cuenta las líneas solo */ }

    /* TODO A1: comentarios de línea  //  hasta el fin de la línea (se descartan). */

    /* TODO A2: comentarios de bloque simples  / * ... * /  (se descartan).
     *          En la Parte B los reemplazarás por comentarios ANIDADOS.          */

    /* TODO A3: palabras reservadas:
     *   if else while for return int float char void break continue
     *   -> emit("KEYWORD", yytext);
     *   Pregunta: ¿importa si esta regla va antes o después de la de IDENT?        */

{ID}            { emit("IDENT", yytext); }

    /* TODO A4: números.  INT  = dígitos+
     *                    FLOAT = dígitos "." dígitos [exponente]  |  dígitos exponente
     *                    exponente = (e|E) [+|-] dígitos+
     *          Prueba mentalmente: ¿qué hace tu lexer con  12abc  y  3.x ?          */

    /* TODO A5: operadores (tipo OP):
     *   ++ -- += -= *= /= == != <= >= && ||   y   + - * / % = < > !
     *   Recuerda la regla de la coincidencia más larga: ¿qué pasa con  x+++y ?      */

    /* TODO A6: signos de puntuación (tipo PUNCT):   ( ) { } [ ] ; , .             */

    /* TODO B3: cadenas "..." con secuencias de escape (tipo STRING; el lexema
     *          incluye las comillas) y constantes de carácter 'x' (tipo CHAR).      */

    /* TODO B4: cadena sin cerrar (llega un salto de línea antes de la comilla final):
     *          imprime  "<línea> ERROR UNTERMINATED_STRING"  y continúa.            */

    /* TODO B5: comentarios anidados con condiciones de inicio (ver B1/B2) y
     *          comentario sin cerrar al llegar a fin de archivo (<<EOF>>):
     *          imprime  "<línea donde empezó> ERROR UNTERMINATED_COMMENT".          */

    /* TODO B6: regla comodín (debe ir al final): cualquier otro carácter ->
     *          imprime  "<línea> ERROR INVALID_CHAR <carácter>"  y continúa.        */

%%

int main(void) {
    yylex();
    return 0;
}
