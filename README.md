# Laboratorio 1 — Analizador léxico de MiniC con Flex

**Compiladores (707-00088) · Universidad Interamericana de Panamá**
Duración: 2 semanas (semanas 6 y 7) · Equipos de 2 o 3 estudiantes

## ¿De qué trata este laboratorio?

Un compilador no lee un programa como lo lees tú. Lo primero que hace es **cortar el texto en piezas con significado** (palabras reservadas, nombres, números, operadores) y descartar lo que no importa (espacios, comentarios). Esa fase se llama **análisis léxico**, y es lo que vas a construir, con una herramienta real: **Flex**.

Ejemplo de lo que hará tu programa:

```
Entrada:                              Salida:
  int x = 10;   // contador             1 KEYWORD int
  if (x <= 42) y = x + 1;              1 IDENT x
                                       1 OP =
                                       1 INT 10
                                       1 PUNCT ;
                                       2 KEYWORD if
                                       ...
```

## Este laboratorio es guiado: aprendes viendo

Aquí **no** se trata de adivinar ni de programar a ciegas. Vas a ir paso a paso, y en cada paso:

1. **Predices** qué va a pasar.
2. **Ejecutas** y **observas** qué pasó de verdad.
3. **Explicas** con tus palabras por qué.

Todo esto lo tienes explicado en la guía. Lo que aprendes: cómo se escriben y leen las expresiones regulares en un caso real, por qué importa el orden de las reglas, qué es la coincidencia más larga, cómo se manejan los errores sin detener el análisis, y por qué los comentarios anidados necesitan algo más que una expresión regular.

## Por dónde empezar

1. **`docs/GUIA_ESTUDIANTE.md`** — cómo crear tu repositorio, abrir Codespaces y entregar (10 minutos).
2. **`docs/GUIA_LAB.md`** — la guía del laboratorio, de principio a fin. **Empieza por la sección 0.**
3. **`NOTAS.md`** — tu cuaderno: ahí anotas predicciones, observaciones y explicaciones.

## Archivos del repositorio

```
src/lexer.l          <- aquí trabajas (tiene marcas COMPLETAR que la guía te explica)
ejemplos/            <- archivos de ejemplo para observar (los usa la guía)
tests/cases/         <- casos de prueba (.src entrada, .out salida esperada)
tools/ver.py         <- muestra tu código con los tokens debajo de cada línea
VARIANT              <- tu letra de variante (A, B, C o D)
NOTAS.md             <- tu cuaderno de laboratorio
docs/                <- guías
Makefile             <- comandos: make ver / make test / make run
```

## Comandos

```bash
make ver F=ejemplos/ej01_hola.src   # tu código con los tokens al lado
make test                            # corre todos los casos de prueba
make test-one T=a02                  # solo los casos cuyo nombre contiene a02
make run F=archivo.src               # salida cruda
```

## Entregas

| Cuándo | Qué | Qué cubre |
|---|---|---|
| **Fin de la semana 6** (checkpoint) | enlace del repositorio en Moodle | Parte A: pasos 1–6 (casos `a01`–`a07`) |
| **Fin de la semana 7** | enlace del repositorio + `NOTAS.md` completo | Parte B y variante: pasos 7–11 |
| **Semana 7 u 8** | defensa oral de 5 minutos (video llamada) | explicar tu propio código |

Las fechas exactas las indica el instructor en Moodle.

## Calificación (100 puntos)

| Componente | Puntos |
|---|---|
| Pruebas automáticas — Parte A (15) + Parte B (25) + variante (10) | 50 |
| Defensa oral individual | 30 |
| Cuaderno `NOTAS.md`, calidad del código y uso del repositorio (commits de todos) | 20 |

## El lenguaje MiniC (referencia)

Tu programa lee código por la entrada estándar y escribe **un token por línea**: `<línea> <TIPO> <lexema>`.

| Tipo | Qué reconoce | Ejemplos |
|---|---|---|
| `KEYWORD` | `if else while for return int float char void break continue` | `while` |
| `IDENT` | letra o `_`, seguida de letras, dígitos o `_` | `x1`, `_tmp` |
| `INT` | uno o más dígitos | `42` |
| `FLOAT` | `dígitos . dígitos [exp]` o `dígitos exp` | `3.14`, `1e5` |
| `STRING` | texto entre comillas dobles, con escapes; el lexema incluye las comillas | `"hola\n"` |
| `CHAR` | un carácter (o escape) entre comillas simples | `'a'` |
| `OP` | `++ -- += -= *= /= == != <= >= && \|\|` y `+ - * / % = < > !` | `<=` |
| `PUNCT` | `( ) { } [ ] ; , .` | `;` |

Se descartan: espacios, saltos de línea, comentarios `// ...` y comentarios `/* ... */` (que en la Parte B pueden anidarse).

Errores (el análisis **nunca** se detiene):

| Situación | Salida |
|---|---|
| Carácter que no pertenece al lenguaje | `<línea> ERROR INVALID_CHAR <carácter>` |
| Cadena sin cerrar al llegar a fin de línea | `<línea> ERROR UNTERMINATED_STRING` |
| Comentario sin cerrar al llegar a fin de archivo | `<línea donde empezó> ERROR UNTERMINATED_COMMENT` |

## Variantes por equipo

| Variante | Requisito adicional |
|---|---|
| **A** | enteros hexadecimales `0x1F` → `HEXINT` |
| **B** | comentarios `# ...` hasta fin de línea |
| **C** | operadores `**` y `->` |
| **D** | enteros binarios `0b101` → `BININT`, y `$` permitido en identificadores |

## Integridad académica

El código debe ser del equipo. En la defensa oral deberás explicar cualquier línea de tu analizador y modificarlo en vivo. Si usas ayudas externas (documentación, foros, asistentes de IA), indícalo en `NOTAS.md` y asegúrate de entender cada línea que entregas: el laboratorio está diseñado para que **entiendas**, no solo para que "pase".

## Ayuda

- Manual de Flex: https://westes.github.io/flex/manual/
- Condiciones de inicio: https://westes.github.io/flex/manual/Start-Conditions.html
- Probar expresiones regulares: https://regex101.com
- Cápsulas y Módulo 6 en Moodle.
