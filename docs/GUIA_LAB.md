# Guía del Laboratorio 1 — Construye un analizador léxico, paso a paso

Esta guía te lleva de la mano. En cada paso te decimos **qué vas a hacer, por qué, cómo, y qué deberías ver**. Tu trabajo no es adivinar: es **entender lo que ves**. Los casos de prueba (`make test`) sirven para comprobar que entendiste, no son el objetivo.

> **Cómo leer esta guía.** Cada paso tiene siempre las mismas partes:
> **¿Qué hacemos y por qué?** → **Cómo** → **Predice** (antes de ejecutar) → **Ejecuta** → **Observa** → **Explica** (con tus palabras, en tu cuaderno `NOTAS.md`).

---

## 0. Lectura previa (unos 10 minutos)

### 0.1 ¿Qué es un analizador léxico y para qué sirve?

Mira esta oración: `El gato come pescado.` Antes de entender qué significa, tu cerebro reconoce **palabras** (no letras sueltas) e ignora los espacios. Un compilador hace lo mismo con el código: antes de entender el programa, reconoce sus "palabras". Esa es la tarea del **analizador léxico** (o *lexer*).

```
 código fuente         ANALIZADOR LÉXICO          tokens            siguiente fase
 "int x = 10;"   ───►  (lo que construyes   ───►  KEYWORD int  ───►  ANALIZADOR SINTÁCTICO
                        en este laboratorio)       IDENT x           (lo verás en el siguiente módulo)
                                                   OP =
                                                   INT 10
                                                   PUNCT ;
```

Sirve para:
- **Agrupar caracteres en piezas con significado** (tokens): `1`, `0` → el número `10`.
- **Descartar lo que no importa** para compilar: espacios, saltos de línea y comentarios.
- **Llevar la cuenta de las líneas**, para poder decir "error en la línea 7".
- **Detectar errores léxicos**: un carácter que no existe en el lenguaje, una cadena que nunca se cierra.
- **Simplificar la fase siguiente**: el analizador sintáctico ya no ve letras, ve tokens.

### 0.2 ¿Qué es un token?

Un token tiene un **tipo** (de qué clase de pieza se trata) y un **lexema** (el texto exacto que se leyó). Nuestro analizador imprime un token por línea así: `<línea> <TIPO> <lexema>`

| Tipo | Qué es | Ejemplo de lexema |
|---|---|---|
| `KEYWORD` | palabra reservada del lenguaje | `if`, `while`, `int` |
| `IDENT` | nombre inventado por el programador | `x`, `total`, `_tmp` |
| `INT` / `FLOAT` | números | `42` / `3.14` |
| `STRING` / `CHAR` | texto entre comillas | `"hola"` / `'a'` |
| `OP` | operadores | `+`, `<=`, `++` |
| `PUNCT` | signos de puntuación | `;`, `(`, `{` |
| `ERROR` | algo que no se pudo reconocer | `INVALID_CHAR @` |

### 0.3 ¿Cómo lo vamos a construir? Con Flex

Escribir a mano un programa que lea caracteres y los agrupe es posible (lo viste en el Módulo 4), pero es largo y propenso a errores. **Flex** es una herramienta que lo hace por ti: tú describes **qué patrones existen** (con expresiones regulares) y **qué hacer** al encontrarlos; Flex genera un programa en C que lo hace.

```
  src/lexer.l  ──── flex ────►  build/lex.yy.c  ──── gcc ────►  build/lexer  (tu analizador)
 (tú escribes       (genera el                 (compila)
  las reglas)        código en C)
```

¿Qué hace Flex por dentro? Exactamente lo del Módulo 4: toma tus expresiones regulares, las convierte en un autómata (AFN → AFD) y genera el código C que lo simula. Tú no dibujas el autómata; lo importante es entender **qué reglas escribiste y qué efecto tienen**.

Un archivo `.l` tiene tres partes separadas por una línea con `%%`:

```
definiciones        ← opciones y nombres para patrones (ej.: DIGIT = [0-9])
%%
reglas              ← PATRÓN   { ACCIÓN en C }
%%
código C            ← aquí, la función main
```

Una **regla** es un patrón y lo que se ejecuta cuando el texto coincide con él. Ejemplo:

```
{DIGIT}+      { emit("INT", yytext); }
```
Se lee: "cuando veas uno o más dígitos, imprime un token `INT` con el texto que coincidió (`yytext`)".

### 0.4 La regla de oro del lexer (aprende esta y entenderás casi todo)

En cada posición del texto, el analizador **prueba todos los patrones a la vez** y decide así:

1. Gana el patrón que reconoce **más caracteres** (*coincidencia más larga*, o *maximal munch*).
2. Si hay **empate**, gana el que está **escrito primero** en el archivo.
3. Si **ningún** patrón reconoce el texto, Flex **copia el carácter a la salida** tal cual (comportamiento por defecto).

Casi todo lo que descubrirás en este laboratorio (`x+++y`, `iffy`, el orden de las reglas, la regla comodín) sale de estas tres frases. Volverás a ellas varias veces.

### 0.5 Cómo vamos a trabajar: Predecir → Ejecutar → Observar → Explicar

Aprender es más profundo cuando **adivinas antes de ver**. En cada paso:
1. **Predice** qué crees que va a pasar y anótalo en `NOTAS.md`. Equivocarte está bien.
2. **Ejecuta**.
3. **Observa** qué pasó realmente.
4. **Explica** por qué, con tus palabras. Si tu predicción falló, explicar la diferencia es lo más valioso del laboratorio.

### 0.6 Comandos que usarás

| Comando | Para qué sirve |
|---|---|
| `make ver F=ejemplos/ej01_hola.src` | Compila tu analizador y muestra **tu código fuente con los tokens debajo de cada línea**. Es tu herramienta principal para *ver* qué hace tu lexer. |
| `make test` | Corre todos los casos de prueba y dice cuántos pasan. |
| `make test-one T=a02` | Corre solo los casos cuyo nombre contiene `a02`. |
| `make run F=archivo.src` | Muestra la salida cruda del analizador. |

Puedes crear tus propios archivos de prueba (por ejemplo `prueba.src`) y verlos con `make ver F=prueba.src`.

### 0.7 Mapa del laboratorio

| Paso | Qué haces | Qué entiendes al terminar |
|---|---|---|
| 1 | Lees y ejecutas el punto de partida | cómo es una regla y qué ocurre cuando ninguna coincide |
| 2 | Palabras reservadas | por qué importa el **orden** de las reglas (empates) |
| 3 | Números | construir una expresión regular por piezas |
| 4 | Operadores | la **coincidencia más larga** (`x+++y`) |
| 5 | Puntuación y comentarios simples | por qué las expresiones regulares tienen límites |
| 6 | **Checkpoint de la Parte A** | |
| 7 | Cadenas y caracteres | patrones con exclusiones y escapes |
| 8 | Errores léxicos | por qué la regla comodín va **al final** |
| 9 | Comentarios anidados | **condiciones de inicio** (modos) y por qué una ER no puede contar |
| 10 | Tu variante | aplicar lo aprendido a un caso nuevo |
| 11 | Cierre | repasar y prepararte para la defensa |

---

# PARTE A — Semana 6 (checkpoint)

## Paso 1 — Conoce el punto de partida

**¿Qué hacemos y por qué?** Antes de escribir nada, vamos a **leer** el archivo `src/lexer.l` y **ver qué hace tal como está**. Así sabrás de dónde partes y verás qué pasa cuando el analizador no sabe reconocer algo.

**Cómo.** Abre `src/lexer.l`. Lee los comentarios de arriba (explican las tres partes del archivo) y fíjate en estas tres reglas que **ya están hechas**:

```
[ \t\r\n]+     { /* espacios y saltos de línea: se ignoran */ }
"//".*         { /* comentario de línea: se ignora */ }
{ID}           { emit("IDENT", yytext); }
```

- `[ \t\r\n]+` — un **conjunto** `[...]` con espacio, tabulador y saltos de línea, y el `+` significa "una o más veces". La acción está vacía: el texto se reconoce y se **descarta**. (Los saltos de línea los cuenta Flex solo en `yylineno`.)
- `"//".*` — la cadena literal `//` seguida de `.*` ("cualquier carácter, cero o más veces", hasta el fin de la línea). Es el comentario de línea: se reconoce y se descarta.
- `{ID}` — usa el nombre `ID` definido arriba: `[A-Za-z_][A-Za-z0-9_]*` = una letra o `_` seguida de letras, dígitos o `_`. Es un **identificador**. Su acción llama a `emit`, que imprime el token.

**Predice** (anótalo en `NOTAS.md`). Con solo esas reglas, mira el archivo `ejemplos/ej01_hola.src`:
```
int x = 10;   // contador
if (x <= 42) y = x + 1;
```
¿Qué crees que imprimirá el analizador? ¿Qué pasará con `=`, `10`, `;`, `(`, `<=`?

**Ejecuta.**
```bash
make ver F=ejemplos/ej01_hola.src
```

**Observa.** Deberías ver algo así:

```
================================================================
 ejemplos/ej01_hola.src
================================================================
  1 | int x = 10;   // contador
      -> IDENT(int)  IDENT(x)
  2 | if (x <= 42) y = x + 1;
      -> IDENT(if)  IDENT(x)  IDENT(y)  IDENT(x)
----------------------------------------------------------------
 6 tokens reconocidos

 Salida que NO tiene formato de token (texto que Flex copió tal cual):
   |=10;
   |(
   |<=42)
   |=
   |+1;
```

**Explica.**
- `int`, `x`, `if`, `y` salieron como `IDENT`: la regla de identificadores los reconoció. Pero `int` e `if` **no son** identificadores, son palabras reservadas: todavía no le enseñamos eso al analizador (Paso 2).
- Los espacios y el comentario `// contador` desaparecieron: sus reglas los descartan.
- Todo lo demás (`=`, `10`, `;`, `(`, `<=`, `42`...) aparece en "texto que Flex copió tal cual". Esa es la **tercera frase de la regla de oro**: cuando ningún patrón reconoce el texto, Flex lo copia a la salida. Por eso la salida está "sucia". Una de las tareas del laboratorio es evitar esto: o reconocer todo, o avisar con un error.

**Por qué importa.** Un compilador no puede "copiar lo que no entiende": tiene que reconocer cada carácter o reportar un error. Eso lo resolverás en el Paso 8.

---

## Paso 2 — Palabras reservadas (y por qué importa el orden)

**¿Qué hacemos y por qué?** `if`, `while`, `int`... son palabras con significado especial en el lenguaje. Deben salir como `KEYWORD`, no como `IDENT`. Vas a escribir tu primera regla propia.

**Cómo.** Busca en `lexer.l` esta línea y reemplaza el texto entre comillas por el patrón:
```
"@COMPLETAR_PALABRAS_RESERVADAS@"     { emit("KEYWORD", yytext); }
```
El patrón es una **lista de alternativas** separadas por `|` (que significa "o"):
```
if|else|while|for|return|int|float|char|void|break|continue
```
Queda así (sin las comillas del marcador):
```
if|else|while|for|return|int|float|char|void|break|continue     { emit("KEYWORD", yytext); }
```
Fíjate en que esta regla está **antes** de la de `{ID}`.

**Predice.** Mira `ejemplos/ej02_palabras.src`:
```
if iffy else elsewhere
int int2 while whiles return
```
¿Cuáles de esas palabras crees que serán `KEYWORD` y cuáles `IDENT`? ¿Qué pasa con `iffy` si empieza con `if`?

**Ejecuta.** `make ver F=ejemplos/ej02_palabras.src`

**Observa.**

```
================================================================
 ejemplos/ej02_palabras.src
================================================================
  1 | if iffy else elsewhere
      -> KEYWORD(if)  IDENT(iffy)  KEYWORD(else)  IDENT(elsewhere)
  2 | int int2 while whiles return
      -> KEYWORD(int)  IDENT(int2)  KEYWORD(while)  IDENT(whiles)  KEYWORD(return)
----------------------------------------------------------------
 9 tokens reconocidos
```

**Explica.** `if` es `KEYWORD`, pero `iffy` es `IDENT`. ¿Por qué, si `iffy` empieza con `if`? Por la **primera frase de la regla de oro**: en `iffy`, la regla de palabras reservadas reconoce 2 caracteres (`if`) pero la de `{ID}` reconoce 4 (`iffy`). **Gana la más larga.**

Y con `if` solo, ambas reglas reconocen exactamente 2 caracteres: hay **empate**. Gana la que está escrita primero: por eso las palabras reservadas van *antes* de `{ID}`.

### Experimento: ¿qué pasa si cambio el orden?

1. Corta la línea de las palabras reservadas y pégala **debajo** de la regla `{ID}`.
2. Predice: ¿qué saldrá ahora para `if`?
3. Ejecuta `make ver F=ejemplos/ej02_palabras.src` y luego `make test-one T=a01`.

Deberías ver:

```
================================================================
 ejemplos/ej02_palabras.src
================================================================
  1 | if iffy else elsewhere
      -> IDENT(if)  IDENT(iffy)  IDENT(else)  IDENT(elsewhere)
  2 | int int2 while whiles return
      -> IDENT(int)  IDENT(int2)  IDENT(while)  IDENT(whiles)  IDENT(return)
----------------------------------------------------------------
 9 tokens reconocidos
```

y en las pruebas:

```
  FAIL  a01_idents_keywords
    línea 1: obtuviste  [1 IDENT int]
             esperado   [1 KEYWORD int]
    línea 3: obtuviste  [2 IDENT if]
             esperado   [2 KEYWORD if]
    línea 5: obtuviste  [2 IDENT else]
             esperado   [2 KEYWORD else]
```

Todas las palabras reservadas salen como `IDENT`: en cada empate ahora gana `{ID}` porque está primero. **Devuelve la regla a su lugar** (antes de `{ID}`).

**Por qué importa.** Este es el problema real que resuelven todos los compiladores: distinguir `if` de `iffy`. Hay dos soluciones (esta, usando el orden de las reglas, o reconocer todo como identificador y buscar en una tabla de palabras reservadas, lo del Módulo 6). Ahora sabes por qué funcionan.

📔 **Cuaderno:** anota tu predicción, qué viste y por qué `iffy` es `IDENT`. Anota también el experimento del orden.

---

## Paso 3 — Números

**¿Qué hacemos y por qué?** Los números son de dos clases: enteros (`42`) y reales (`3.14`, `1e5`). Aprenderás a **construir una expresión regular por piezas**, que es la habilidad central del análisis léxico.

**Cómo.** Hay tres reglas por completar. Piensa en cada número como piezas:

| Qué reconoce | Piezas | Patrón |
|---|---|---|
| `INT` | uno o más dígitos | `{DIGIT}+` |
| `FLOAT` con punto | dígitos, un punto, dígitos, y **opcionalmente** un exponente | `{DIGIT}+"."{DIGIT}+([eE][+-]?{DIGIT}+)?` |
| `FLOAT` con exponente (sin punto) | dígitos y un exponente obligatorio | `{DIGIT}+[eE][+-]?{DIGIT}+` |

Lee el patrón de `FLOAT` con punto despacio, pieza por pieza:
- `{DIGIT}+` → uno o más dígitos (la parte entera).
- `"."` → un punto literal (entre comillas, para que no signifique "cualquier carácter").
- `{DIGIT}+` → uno o más dígitos (la parte decimal).
- `( ... )?` → el paréntesis agrupa y el `?` significa **opcional**: puede haber o no un exponente.
- `[eE]` → una `e` o una `E`; `[+-]?` → un signo opcional; `{DIGIT}+` → los dígitos del exponente.

Reemplaza los tres marcadores `@COMPLETAR_FLOAT_CON_PUNTO@`, `@COMPLETAR_FLOAT_CON_EXPONENTE@` y `@COMPLETAR_INT@` por estos patrones. Observa que ahora sí aparecen los números en la salida.

**Predice.** Mira `ejemplos/ej03_numeros.src`:
```
42 3.14 0.5
1e5 2E10 6.02e23 1.5e-3
12abc 3.x 7.
```
Para la última línea piensa con la regla de oro: ¿qué crees que hace el lexer con `12abc`? ¿Será un error? ¿Y con `3.x`? ¿Y con `7.`?

**Ejecuta.** `make ver F=ejemplos/ej03_numeros.src`

**Observa.**

```
================================================================
 ejemplos/ej03_numeros.src
================================================================
  1 | 42 3.14 0.5
      -> INT(42)  FLOAT(3.14)  FLOAT(0.5)
  2 | 1e5 2E10 6.02e23 1.5e-3
      -> FLOAT(1e5)  FLOAT(2E10)  FLOAT(6.02e23)  FLOAT(1.5e-3)
  3 | 12abc 3.x 7.
      -> INT(12)  IDENT(abc)  INT(3)  PUNCT(.)  IDENT(x)  INT(7)  PUNCT(.)
----------------------------------------------------------------
 14 tokens reconocidos
```

**Explica.**
- `12abc` salió como **dos tokens**: `INT(12)` y `IDENT(abc)`. El lexer no se queja: en la posición del `1`, el patrón de entero reconoce `12` (y `12a` no encaja con ningún número). Luego `abc` empieza otro token. Que eso sea o no un error **no lo decide el lexer**: lo decidirá una fase posterior.
- `3.x` → `INT(3)`, `PUNCT(.)`, `IDENT(x)`: un `FLOAT` necesita dígitos *después* del punto, así que `3.` no lo es. Gana la coincidencia más larga posible: `3`.
- `1e5` es `FLOAT` (por la regla del exponente sin punto).

**Por qué importa.** El lexer **no entiende el significado** del programa; solo corta texto con patrones. Dos tokens pegados (`12abc`) son válidos para él, aunque no para el lenguaje.

📔 **Cuaderno:** tu predicción para `12abc`, `3.x` y `7.`, y qué viste.

---

## Paso 4 — Operadores y la coincidencia más larga

**¿Qué hacemos y por qué?** Hay operadores de un carácter (`+`) y de dos (`++`, `<=`). Esto nos permite ver la **regla de oro #1** en acción.

**Cómo.** Completa dos reglas con estas listas de alternativas:
```
"++"|"--"|"+="|"-="|"*="|"/="|"=="|"!="|"<="|">="|"&&"|"||"      ← dos caracteres
"+"|"-"|"*"|"/"|"%"|"="|"<"|">"|"!"                              ← un carácter
```
(Las comillas hacen que cada símbolo se lea literalmente; sin ellas, `+` o `|` tendrían significado especial en las expresiones regulares.)

**Predice.** Mira `ejemplos/ej04_munch.src`:
```
x+++y
a---b
p<=q
p< =q
m=-1
```
¿Cómo crees que se partirá `x+++y`? Hay varias posibilidades: `x + + + y`, `x ++ + y`, `x + ++ y`. ¿Cuál elegirá el lexer según la regla de oro?

**Ejecuta.** `make ver F=ejemplos/ej04_munch.src`

**Observa.**

```
================================================================
 ejemplos/ej04_munch.src
================================================================
  1 | x+++y
      -> IDENT(x)  OP(++)  OP(+)  IDENT(y)
  2 | a---b
      -> IDENT(a)  OP(--)  OP(-)  IDENT(b)
  3 | p<=q
      -> IDENT(p)  OP(<=)  IDENT(q)
  4 | p< =q
      -> IDENT(p)  OP(<)  OP(=)  IDENT(q)
  5 | m=-1
      -> IDENT(m)  OP(=)  OP(-)  INT(1)
----------------------------------------------------------------
 19 tokens reconocidos
```

**Explica.**
- `x+++y` → `x`, `++`, `+`, `y`. El lexer, de izquierda a derecha, toma **lo más largo posible**: primero `++` (2 caracteres) en vez de `+` (1). Luego queda un `+`. Aunque un programador quisiera `x + ++y`, el lexer **no puede adivinarlo**: aplica siempre la misma regla.
- `p<=q` es un solo `<=`, pero `p< =q` (con un espacio) son `<` y `=` por separado: el espacio **corta** el token.

### Experimento: ¿qué pasaría sin la regla de dos caracteres?

1. Quita `"++"|"--"|` de la regla de dos caracteres (déjala sin `++` ni `--`).
2. Predice qué saldrá para `x+++y`.
3. Ejecuta `make ver F=ejemplos/ej04_munch.src`.

Verás:

```
================================================================
 ejemplos/ej04_munch.src
================================================================
  1 | x+++y
      -> IDENT(x)  OP(+)  OP(+)  OP(+)  IDENT(y)
  2 | a---b
      -> IDENT(a)  OP(-)  OP(-)  OP(-)  IDENT(b)
  3 | p<=q
      -> IDENT(p)  OP(<=)  IDENT(q)
  4 | p< =q
      -> IDENT(p)  OP(<)  OP(=)  IDENT(q)
  5 | m=-1
      -> IDENT(m)  OP(=)  OP(-)  INT(1)
----------------------------------------------------------------
 21 tokens reconocidos
```

Ahora `x+++y` sale como tres `+` separados. La diferencia entre `x ++ + y` y `x + + + y` **es solo la regla de la coincidencia más larga**. **Devuelve `++` y `--` a la regla.**

**Por qué importa.** Esta regla explica rarezas conocidas de lenguajes reales (`x+++y` en C, o `>>` contra `> >` en las plantillas de C++).

📔 **Cuaderno:** tu predicción para `x+++y`, el resultado y la explicación con tus palabras.

---

## Paso 5 — Puntuación y comentarios de bloque simples

**¿Qué hacemos y por qué?** Dos cosas: completar los signos de puntuación y **entender una regla que ya está hecha** y es bastante difícil de leer.

**Cómo (puntuación).** Reemplaza el marcador `@COMPLETAR_PUNTUACION@` por:
```
"("|")"|"{"|"}"|"["|"]"|";"|","|"."
```
Es otra lista de alternativas, igual que las anteriores.

**Cómo (comentarios).** Ya hay una regla que descarta comentarios de bloque `/* ... */`:
```
"/*"([^*]|\*+[^*/])*\*+"/"      { /* comentario de bloque: se ignora */ }
```
Léela pieza por pieza:
1. `"/*"` → el comienzo del comentario.
2. `( ... )*` → repetido cero o más veces:
   - `[^*]` → cualquier carácter que **no** sea `*`, **o**
   - `\*+[^*/]` → uno o más asteriscos seguidos de un carácter que no sea `*` ni `/` (un asterisco "falso", que no cierra el comentario).
3. `\*+"/"` → uno o más asteriscos y una `/`: el cierre `*/`.

Es difícil de leer y de escribir. Guarda esta sensación: la vas a necesitar en el Paso 9.

**Predice.** Mira `ejemplos/ej01_hola.src` otra vez: ahora que ya tienes palabras reservadas, números, operadores y puntuación, ¿cómo saldrá cada línea?

**Ejecuta.** `make ver F=ejemplos/ej01_hola.src`

**Observa.**

```
================================================================
 ejemplos/ej01_hola.src
================================================================
  1 | int x = 10;   // contador
      -> KEYWORD(int)  IDENT(x)  OP(=)  INT(10)  PUNCT(;)
  2 | if (x <= 42) y = x + 1;
      -> KEYWORD(if)  PUNCT(()  IDENT(x)  OP(<=)  INT(42)  PUNCT())  IDENT(y)  OP(=)  IDENT(x)  OP(+)  INT(1)  PUNCT(;)
----------------------------------------------------------------
 17 tokens reconocidos
```

Todo está reconocido: ya no hay "texto copiado tal cual". Compáralo con lo que viste en el Paso 1.

**Por qué importa.** Ya tienes un analizador capaz de leer programas pequeños. Los comentarios y los espacios desaparecieron, y cada pieza tiene un tipo.

📔 **Cuaderno:** compara la salida del Paso 1 con la de ahora. ¿Qué cambió y por qué?

---

## Paso 6 — Checkpoint de la Parte A

**Qué hacer.**
```bash
make test
```
Fíjate **solo** en los casos que empiezan con `a` (`a01` a `a07`). Los casos `b...` y `v_...` todavía fallan: son de la Parte B.

Para ver cómo se comporta con un programa real, prueba:
```bash
make ver F=ejemplos/ej08_programa.src
```

Cuando los siete casos `a` pasen:
1. Completa tu cuaderno `NOTAS.md` hasta el Paso 5.
2. Guarda tu trabajo: `git add -A`, `git commit -m "Parte A completa"`, `git push`.
3. Entrega el enlace de tu repositorio en Moodle (checkpoint).

Si algún caso falla, el corredor te muestra la primera línea donde tu salida difiere de la esperada. **Léela con calma**: casi siempre te dice exactamente qué token está mal. Compara con lo que viste en los pasos anteriores.

---

# PARTE B — Semana 7 (entrega final)

## Paso 7 — Cadenas de texto y caracteres

**¿Qué hacemos y por qué?** Hasta ahora, un texto entre comillas se parte en trocitos sin sentido. Una cadena (`"hola mundo"`) es **un solo token**, y debe poder contener espacios, palabras reservadas, `//`, comillas escapadas (`\"`)...

**Cómo.** Completa estos tres marcadores:

```
\"([^"\\\n]|\\.)*\"          ← CADENA completa
\"([^"\\\n]|\\.)*            ← CADENA SIN CERRAR (llega al fin de línea sin la comilla final)
'([^'\\\n]|\\.)'             ← CARÁCTER
```

Pieza por pieza, para la cadena completa:
- `\"` → una comilla doble literal.
- `( ... )*` → repetido cero o más veces, donde cada repetición es **una de dos cosas**:
  - `[^"\\\n]` → cualquier carácter que **no** sea comilla, barra invertida ni salto de línea; **o**
  - `\\.` → una barra invertida seguida de **cualquier** carácter (una **secuencia de escape**, como `\"` o `\n`).
- `\"` → la comilla de cierre.

La idea: dentro de una cadena, la única forma de aceptar una comilla es que venga escapada (`\"`). Por eso `"hola \"mundo\""` es **una** cadena.

En la regla de **cadena sin cerrar** (`CADENA_SIN_CERRAR`), cambia el hueco de la acción `COMPLETAR_ERROR_CADENA` por:
```
printf("%d ERROR UNTERMINATED_STRING\n", yylineno);
```
Es el segundo tipo de salida que tiene nuestro analizador: un **error léxico**.

**Predice.** Mira `ejemplos/ej06_cadenas.src`:
```
msg = "hola \"mundo\"";
c = 'x';
t = "esta no cierra
u = 1;
```
Antes de agregar estas reglas, ¿qué hace tu lexer con `"hola \"mundo\""`? Después de agregarlas, ¿cómo saldrá la línea 3 (la cadena que nunca cierra)? Piensa en las **dos** reglas de cadena: ¿cuál gana en la línea 3 y por qué?

**Ejecuta.** Primero **sin** las reglas nuevas, `make ver F=ejemplos/ej06_cadenas.src`:

```
================================================================
 ejemplos/ej06_cadenas.src
================================================================
  1 | msg = "hola \"mundo\"";
      -> IDENT(msg)  OP(=)  IDENT(hola)  IDENT(mundo)  PUNCT(;)
  2 | c = 'x';
      -> IDENT(c)  OP(=)  IDENT(x)  PUNCT(;)
  3 | t = "esta no cierra
      -> IDENT(t)  OP(=)  IDENT(esta)  IDENT(no)  IDENT(cierra)
  4 | u = 1;
      -> IDENT(u)  OP(=)  INT(1)  PUNCT(;)
----------------------------------------------------------------
 18 tokens reconocidos

 Salida que NO tiene formato de token (texto que Flex copió tal cual):
   |"
   |\"
   |\""
   |'
   |'
   |"
```

Mira qué desastre: la cadena se partió en `IDENT(hola)`, `IDENT(mundo)` y sobraron comillas "copiadas tal cual". Ahora agrega las reglas y ejecuta de nuevo:

```
================================================================
 ejemplos/ej06_cadenas.src
================================================================
  1 | msg = "hola \"mundo\"";
      -> IDENT(msg)  OP(=)  STRING("hola \"mundo\"")  PUNCT(;)
  2 | c = 'x';
      -> IDENT(c)  OP(=)  CHAR('x')  PUNCT(;)
  3 | t = "esta no cierra
      -> IDENT(t)  OP(=)  ERROR(UNTERMINATED_STRING)
  4 | u = 1;
      -> IDENT(u)  OP(=)  INT(1)  PUNCT(;)
----------------------------------------------------------------
 15 tokens reconocidos
```

**Explica.**
- `"hola \"mundo\""` ahora es **un solo `STRING`**, incluyendo las comillas y los escapes.
- En la línea 3, la cadena nunca cierra: la regla de cadena completa **no puede** coincidir (no hay comilla final), pero la regla de cadena sin cerrar sí reconoce todo hasta el fin de la línea. Ese es el error `UNTERMINATED_STRING`, y el análisis **sigue** en la línea 4 como si nada.
- ¿Y si la cadena sí cierra? Entonces las dos reglas coinciden, pero la completa reconoce **un carácter más** (la comilla final). Gana la más larga (regla de oro #1).

**Por qué importa.** Un compilador real **nunca se detiene en el primer error**: reporta, se recupera y sigue, para mostrar todos los errores de una vez.

📔 **Cuaderno:** explica con tus palabras por qué la cadena sin cerrar no "rompe" el resto del análisis.

---

## Paso 8 — Errores léxicos: la regla comodín

**¿Qué hacemos y por qué?** En el Paso 1 vimos que, si ninguna regla coincide, Flex copia el carácter. Un compilador debe en cambio **avisar**: "este carácter no pertenece al lenguaje". Para eso se usa una regla que coincide con **cualquier** carácter.

**Cómo.** En el último marcador, reemplaza `@COMPLETAR_COMODIN@` por un punto (`.` = cualquier carácter menos el salto de línea) y la acción `COMPLETAR_ERROR_CARACTER` por:
```
printf("%d ERROR INVALID_CHAR %s\n", yylineno, yytext);
```
Queda:
```
.      { printf("%d ERROR INVALID_CHAR %s\n", yylineno, yytext); }
```

**Predice.** `ejemplos/ej07_errores.src` tiene caracteres que MiniC no conoce (`@`, `^`, `?`, `:`):
```
x = 5 @ 3;
y = 7 ^ 2;
z = 1 ? 2 : 3;
```
Pregunta clave: **¿por qué esta regla debe ir al final?** Piensa: el punto coincide con **cualquier** carácter. Si estuviera al principio, ¿qué pasaría con `+`? Los dos patrones reconocen 1 carácter: empate... ¿quién gana?

**Ejecuta.** Primero sin la regla comodín:

```
================================================================
 ejemplos/ej07_errores.src
================================================================
  1 | x = 5 @ 3;
      -> IDENT(x)  OP(=)  INT(5)  INT(3)  PUNCT(;)
  2 | y = 7 ^ 2;
      -> IDENT(y)  OP(=)  INT(7)  INT(2)  PUNCT(;)
  3 | z = 1 ? 2 : 3;
      -> IDENT(z)  OP(=)  INT(1)  INT(2)  INT(3)  PUNCT(;)
----------------------------------------------------------------
 16 tokens reconocidos

 Salida que NO tiene formato de token (texto que Flex copió tal cual):
   |@
   |^
   |?
   |:
```

Ahora con ella (al final del archivo):

```
================================================================
 ejemplos/ej07_errores.src
================================================================
  1 | x = 5 @ 3;
      -> IDENT(x)  OP(=)  INT(5)  ERROR(INVALID_CHAR @)  INT(3)  PUNCT(;)
  2 | y = 7 ^ 2;
      -> IDENT(y)  OP(=)  INT(7)  ERROR(INVALID_CHAR ^)  INT(2)  PUNCT(;)
  3 | z = 1 ? 2 : 3;
      -> IDENT(z)  OP(=)  INT(1)  ERROR(INVALID_CHAR ?)  INT(2)  ERROR(INVALID_CHAR :)  INT(3)  PUNCT(;)
----------------------------------------------------------------
 20 tokens reconocidos
```

**Explica.**
- Sin la regla, los caracteres desconocidos se copian sin avisar. Con ella, cada uno genera una línea `ERROR INVALID_CHAR`, y **el análisis continúa** con el resto.
- La regla comodín va **al final** por la regla de oro #2: cuando hay empate, gana la primera. Si el punto estuviera arriba, ganaría siempre a las demás reglas de un carácter (`+`, `;`, ...). Al final, solo actúa cuando **ninguna otra** reconoce el carácter.

**Experimento (opcional).** Mueve la regla `.` al principio de las reglas y ejecuta `make test`. Observa y explica qué se rompió. Devuélvela al final.

📔 **Cuaderno:** explica con tus palabras por qué la comodín debe ir última.

---

## Paso 9 — Comentarios anidados: condiciones de inicio

**¿Qué hacemos y por qué?** Este es el paso más importante de la Parte B. Hasta ahora los comentarios `/* ... */` no se pueden **anidar**. Veamos qué pasa:

**Predice.** Mira `ejemplos/ej05_comentarios.src`:
```
a /* simple */ b
c /* abre /* anidado */ todavia es comentario */ d
e
```
La línea 2 abre un comentario, abre **otro dentro**, cierra el interno, y luego el externo. Con la regla actual (la expresión regular del Paso 5), ¿qué crees que reconocerá en la línea 2?

**Ejecuta.** `make ver F=ejemplos/ej05_comentarios.src` (con el lexer del Paso 8, todavía con la expresión regular).

**Observa.**

```
================================================================
 ejemplos/ej05_comentarios.src
================================================================
  1 | a /* simple */ b
      -> IDENT(a)  IDENT(b)
  2 | c /* abre /* anidado */ todavia es comentario */ d
      -> IDENT(c)  IDENT(todavia)  IDENT(es)  IDENT(comentario)  OP(*)  OP(/)  IDENT(d)
  3 | e
      -> IDENT(e)
----------------------------------------------------------------
 10 tokens reconocidos
```

**Explica el problema.** La expresión regular termina el comentario en el **primer** `*/`. Entonces `todavia es comentario */ d` queda **fuera** del comentario: aparecen como `IDENT(todavia)`, `IDENT(es)`, `IDENT(comentario)` y hasta un `*` y un `/` sueltos. Es un resultado **incorrecto**.

**¿Por qué una expresión regular no puede resolverlo?** Para saber si un `*/` cierra el comentario externo o uno interno, hay que **contar** cuántos comentarios siguen abiertos. Un autómata finito tiene un número fijo de estados y **no puede contar sin límite**. Ninguna expresión regular puede resolver este problema (lo viste en el Módulo 6).

**La solución: un modo del analizador + un contador.** Flex permite definir **condiciones de inicio**: modos distintos del analizador, cada uno con sus propias reglas. Haremos dos modos:

```
                  "/*"  (depth = 1)
   ┌─────────────┐ ─────────────────────► ┌──────────────────────────┐
   │  INITIAL    │                        │  COMMENT                 │
   │ (modo normal│ ◄───────────────────── │ "/*" → depth++           │
   │  tokens)    │   "*/" y depth == 0    │ "*/" → depth--           │
   └─────────────┘                        │ otro carácter: se ignora │
                                          └──────────────────────────┘
```

Estas son las ideas:
- Al encontrar `/*` en el modo normal: pon `depth = 1`, guarda la línea y **cambia al modo `COMMENT`** con `BEGIN(COMMENT)`.
- Dentro de `COMMENT`: otro `/*` suma uno (`depth++`); un `*/` resta uno (`depth--`) y, **si llegó a 0**, vuelve al modo normal con `BEGIN(INITIAL)`. Cualquier otro carácter se ignora.
- Si el archivo termina estando en modo `COMMENT`, el comentario nunca cerró: error (`<<EOF>>` es la regla para "fin de archivo").

**Cómo.** El archivo ya tiene declarado `%x COMMENT` (el modo), las variables `depth` y `comment_line`, y las cinco reglas con el hueco por completar. Complétalos así:

| Marcador | Reemplázalo por |
|---|---|
| `COMPLETAR_ENTRAR_COMENTARIO` | `depth = 1; comment_line = yylineno; BEGIN(COMMENT);` |
| `COMPLETAR_ANIDAR` | `depth++;` |
| `COMPLETAR_CERRAR` | `depth--; if (depth == 0) BEGIN(INITIAL);` |
| `COMPLETAR_FIN_DE_ARCHIVO` | `printf("%d ERROR UNTERMINATED_COMMENT\n", comment_line); BEGIN(INITIAL);` |

(La última regla ya trae `yyterminate();` al final: significa "termina el análisis".)

**Importante:** ahora **borra** la regla de la expresión regular del Paso 5 (la de `"/*"([^*]|\*+[^*/])*\*+"/"`), porque el nuevo mecanismo la reemplaza. Si la dejas, para comentarios completos ganaría ella por ser más larga y los anidados volverían a fallar.

**Ejecuta.** `make ver F=ejemplos/ej05_comentarios.src`

**Observa.**

```
================================================================
 ejemplos/ej05_comentarios.src
================================================================
  1 | a /* simple */ b
      -> IDENT(a)  IDENT(b)
  2 | c /* abre /* anidado */ todavia es comentario */ d
      -> IDENT(c)  IDENT(d)
  3 | e
      -> IDENT(e)
----------------------------------------------------------------
 5 tokens reconocidos
```

**Explica.** Ahora la línea 2 es `c` y `d`: todo lo del medio fue un comentario anidado. Dentro del modo `COMMENT`, el contador `depth` subió a 2 con el segundo `/*`, bajó a 1 con el primer `*/`, y bajó a 0 con el segundo `*/`, que fue el que cerró el comentario externo.

Pruébalo tú mismo: crea un archivo con un comentario que nunca cierra (y otro con tres niveles de anidamiento) y mira qué reporta.

**Por qué importa.** Es el ejemplo clásico de que **los límites de la teoría se resuelven con ingeniería**: la teoría dice que una ER no puede contar; la herramienta agrega modos y un contador y lo resuelve. Así lo hacen los compiladores reales.

📔 **Cuaderno:** explica con tus palabras por qué una ER no basta, cómo funciona el modo `COMMENT` y qué hace `depth`.

---

## Paso 10 — Tu variante

**¿Qué hacemos y por qué?** Cada equipo tiene una **variante** (A, B, C o D): una pequeña extensión al lenguaje. El objetivo es comprobar que puedes **aplicar lo que aprendiste a un caso nuevo**. La solución es corta, y lo importante es que expliques por qué funciona.

Primero escribe tu letra en el archivo `VARIANT`. Después agrega tus reglas en la zona marcada `PASO 10` de `lexer.l`.

| Variante | Qué agregar |
|---|---|
| **A** | enteros hexadecimales `0x1F` o `0X1f` → tipo `HEXINT` |
| **B** | comentarios `# ...` hasta fin de línea (se descartan) |
| **C** | operadores `**` y `->` (tipo `OP`) |
| **D** | enteros binarios `0b101` → tipo `BININT`, y el símbolo `$` permitido en identificadores |

Reglas sugeridas (pégalas en la zona `PASO 10` y **explica por qué funcionan**):

```
Variante A:   0[xX][0-9a-fA-F]+      { emit("HEXINT", yytext); }
Variante B:   "#".*                  { /* comentario: se ignora */ }
Variante C:   "**"|"->"              { emit("OP", yytext); }
Variante D:   0[bB][01]+             { emit("BININT", yytext); }
```

Para la **D** necesitas además un segundo cambio: la definición `ID` (arriba del archivo) debe aceptar `$`:
```
ID      [A-Za-z_$][A-Za-z0-9_$]*
```

Escribe un archivo de prueba pequeño con tu variante (el repositorio ya trae un caso de ejemplo en `tests/cases/v_<tu letra>_...`) y míralo con `make ver`.

**Preguntas para tu cuaderno** (la defensa oral las incluirá):
- **A, C y D:** tu regla nueva puede competir con otra regla existente (por ejemplo, `0x1F` contra `0` entero seguido del identificador `x1F`). ¿Qué regla de oro decide quién gana? ¿Importa dónde pongas tu regla?
- **B:** ¿qué pasa con `#` dentro de una cadena, como `"# no es comentario"`? ¿Por qué no se rompe?
- **C:** ¿cómo se lee `a***b` con tu lexer? ¿Y `a-->b`? Explica con la regla de la coincidencia más larga.
- **D:** ¿por qué `0b2` no es un binario? ¿Cómo lo lee tu lexer?

---

## Paso 11 — Cierre

1. Ejecuta `make test`: deberías tener **todos** los casos visibles pasando.
2. Completa tu cuaderno `NOTAS.md` (incluye las preguntas finales).
3. Guarda y sube tu trabajo: `git add -A`, `git commit -m "Lab 1 completo"`, `git push`. Comprueba en la pestaña **Actions** de tu repositorio que aparece la marca verde.
4. Entrega en Moodle el enlace del repositorio.

### Cómo prepararte para la defensa oral (5 minutos)

Te pedirán que expliques tu propio código y que hagas un cambio pequeño en vivo. Prepárate para poder:
- **Explicar una regla cualquiera** de tu `lexer.l`: qué patrón es, qué reconoce y qué hace su acción.
- Decir **qué pasa si cambias el orden** de dos reglas, y por qué.
- Explicar con un ejemplo la **coincidencia más larga** (`x+++y`).
- Explicar **por qué los comentarios anidados necesitan un modo y un contador**.
- Explicar **por qué la regla comodín va al final**.

Si hiciste los experimentos y escribiste tu cuaderno con tus propias palabras, ya sabes todo esto.

---

## Si te trabas

| Qué ves | Qué hacer |
|---|---|
| Error de Flex al compilar (`bad character`, `unrecognized rule`) | Mira el **número de línea** del mensaje y revisa esa línea en `lexer.l`: suele ser una comilla o un paréntesis sin cerrar. |
| `make test` falla pero no sabes por qué | Lee la primera diferencia que muestra el corredor. Luego corre `make ver F=tests/cases/<ese caso>.src` y compara tokens línea por línea. |
| Una regla "no se aplica" | Piensa en la regla de oro: ¿otra regla reconoce **más caracteres**? ¿O empata y está **escrita antes**? |
| Salen caracteres "copiados tal cual" | Falta una regla (o no coincide). Revisa el Paso 1 y el Paso 8. |
| Ya no sabes cómo estaba el archivo | `git diff` te muestra lo que cambiaste. |

Pregunta en clase o por Moodle. No pasa nada por atascarse: es parte de aprender.
