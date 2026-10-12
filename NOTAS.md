# Cuaderno del Laboratorio 1

**Equipo / integrantes:**
**Variante:**

> Este cuaderno es **parte de tu aprendizaje y de tu nota**. Escribe con tus propias palabras (2–4 líneas por punto). No se evalúa que aciertes siempre: se evalúa que **pienses antes de ejecutar** y que **expliques lo que viste**. Si tu predicción falló, mejor: explica por qué.

---

## Paso 1 — El punto de partida
**Predicción** (¿qué saldrá para `ej01_hola.src` con solo las reglas iniciales?):

**Observación** (¿qué salió?):

**Explicación** (¿por qué `int` sale como IDENT? ¿qué es el "texto copiado tal cual" y por qué aparece?):

## Paso 2 — Palabras reservadas
**Predicción** (`iffy`, `int2`, `while`):

**Observación:**

**Explicación** (¿por qué `iffy` es IDENT aunque empieza con `if`?):

**Experimento del orden** (¿qué pasó al mover la regla debajo de `{ID}` y por qué?):

## Paso 3 — Números
**Predicción** (`12abc`, `3.x`, `7.`):

**Observación:**

**Explicación** (¿por qué el lexer no marca `12abc` como error?):

## Paso 4 — Operadores
**Predicción** (cómo se parte `x+++y`):

**Observación:**

**Explicación** (con la regla de la coincidencia más larga; y qué pasó en el experimento sin `++`):

## Paso 5 — Puntuación y comentarios simples
**Compara** la salida del Paso 1 con la de ahora para `ej01_hola.src`. ¿Qué cambió?

**¿Qué te pareció la expresión regular del comentario de bloque? ¿Fácil o difícil de leer? Explica una de sus partes con tus palabras:**

## Paso 7 — Cadenas
**Predicción** (¿cómo sale `"hola \"mundo\""` antes y después de agregar las reglas?):

**Explicación** (¿por qué la cadena sin cerrar no rompe el resto del análisis? ¿qué regla gana cuando la cadena sí cierra?):

## Paso 8 — Errores léxicos
**Predicción** (¿por qué la regla comodín debe ir al final?):

**Observación** (¿qué hizo el lexer con `@`, `^`, `?` antes y después de la regla comodín?):

**Explicación:**

## Paso 9 — Comentarios anidados
**Predicción** (línea 2 de `ej05_comentarios.src` con la expresión regular):

**Observación** (¿qué salió mal?):

**Explicación 1:** ¿por qué una expresión regular no puede resolver los comentarios anidados?

**Explicación 2:** ¿cómo funciona el modo `COMMENT`? ¿qué hace la variable `depth`?

## Paso 10 — Tu variante
**¿Qué regla agregaste y por qué funciona?** ¿Importa en qué lugar del archivo la pusiste? (responde con la regla de oro)

**Responde la pregunta de tu variante** (la que aparece en la guía):

---

## Preguntas finales

1. Con tus palabras: ¿qué hace un analizador léxico y por qué un compilador lo necesita antes del analizador sintáctico?

2. Enuncia la "regla de oro" del lexer (las tres frases) y da un ejemplo de este laboratorio para cada una.

3. ¿Qué fue lo más difícil de entender? ¿Cómo lo resolviste?

4. ¿Qué cambiarías o qué te gustaría que se explicara mejor?

## Ayudas externas utilizadas

(Documentación, foros, asistentes de IA, compañeros, etc. Si no usaste ninguna, escribe "Ninguna".)

## Reparto del trabajo

(¿Quién hizo qué? Debe coincidir con los commits del repositorio.)
