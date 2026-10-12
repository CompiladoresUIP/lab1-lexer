# Laboratorio 1 — Analizador léxico de MiniC con Flex

**Compiladores (707-00088) · Universidad Interamericana de Panamá**
Duración: 2 semanas (semanas 6 y 7) · Equipos de 2 o 3 estudiantes · Peso: ver "Calificación"

## 1. Objetivo

Construir, con **Flex**, el analizador léxico de un lenguaje pequeño llamado **MiniC**, aplicando lo visto en el curso: expresiones regulares, coincidencia más larga (*maximal munch*), palabras reservadas frente a identificadores, comentarios anidados con condiciones de inicio y manejo de errores léxicos. Este analizador será la primera pieza del compilador de tu proyecto final.

## 2. Cómo empezar (10 minutos)

Sigue `docs/GUIA_ESTUDIANTE.md`: crear tu repositorio desde esta plantilla, abrir Codespaces, y correr `make test`. No necesitas instalar nada en tu computadora.

## 3. El lenguaje MiniC

Tu programa lee código MiniC por la entrada estándar y escribe **un token por línea**:

```
<línea> <TIPO> <lexema>
```

| Tipo | Qué reconoce | Ejemplos |
|---|---|---|
| `KEYWORD` | `if else while for return int float char void break continue` | `while` |
| `IDENT` | letra o `_`, seguida de letras, dígitos o `_` | `x1`, `_tmp`, `iffy` |
| `INT` | uno o más dígitos | `42` |
| `FLOAT` | `dígitos . dígitos [exp]` o `dígitos exp`, con `exp = (e\|E)[+\|-]dígitos+` | `3.14`, `1e5`, `6.02e23` |
| `STRING` | texto entre comillas dobles, con escapes `\x`; el lexema **incluye** las comillas | `"hola\n"` |
| `CHAR` | un carácter (o escape) entre comillas simples | `'a'`, `'\n'` |
| `OP` | `++ -- += -= *= /= == != <= >= && \|\|` y `+ - * / % = < > !` | `<=` |
| `PUNCT` | `( ) { } [ ] ; , .` | `;` |

Se descartan: espacios, tabuladores, saltos de línea, comentarios `// ...` hasta fin de línea y comentarios `/* ... */` (que en la Parte B pueden **anidarse**).

### Errores léxicos (el analizador nunca se detiene)

| Situación | Salida |
|---|---|
| Carácter que no pertenece al lenguaje | `<línea> ERROR INVALID_CHAR <carácter>` |
| Cadena que llega a fin de línea sin cerrar | `<línea> ERROR UNTERMINATED_STRING` |
| Comentario que llega a fin de archivo sin cerrar | `<línea donde empezó> ERROR UNTERMINATED_COMMENT` |

Después de un error, el análisis continúa con lo que sigue.

### Reglas que debes respetar

- **Coincidencia más larga:** `x+++y` se lee como `x`, `++`, `+`, `y`.
- **Palabras reservadas:** `iffy` es un `IDENT`, `if` es un `KEYWORD`.
- **Números:** `12abc` son dos tokens (`INT 12` e `IDENT abc`); `7.` son `INT 7` y `PUNCT .`.
- **Números de línea:** empiezan en 1 y cuentan también las líneas dentro de los comentarios.

## 4. Variantes por equipo

Cada equipo recibe una **letra** del instructor. Escríbela en el archivo `VARIANT` (una sola letra). Además de lo anterior, tu analizador debe cumplir:

| Variante | Requisito adicional |
|---|---|
| **A** | Enteros hexadecimales `0x1F` / `0X1f` (al menos un dígito hex) → tipo `HEXINT` |
| **B** | Comentarios de línea estilo shell: `# ...` hasta fin de línea (se descartan) |
| **C** | Operadores `**` y `->` (tipo `OP`), respetando la coincidencia más larga |
| **D** | Enteros binarios `0b101` / `0B11` → tipo `BININT`, y el símbolo `$` permitido en identificadores (también al inicio) |

## 5. Entregas

| Cuándo | Qué | Qué cubre |
|---|---|---|
| **Fin de la semana 6** (checkpoint) | Enlace de tu repositorio en Moodle | Parte A: casos `a01`–`a07` |
| **Fin de la semana 7** | Enlace del repositorio + `NOTAS.md` completado | Parte B, variante y todo lo anterior |
| **Semana 7 o 8** | Defensa oral de 5 minutos (por video llamada) | Preguntas sobre tu propio código |

Fechas exactas: las indica el instructor en Moodle.

## 6. Cómo probar

```bash
make test              # compila y corre todos los casos visibles
make test-one T=a03    # solo los casos cuyo nombre contiene a03
make run F=prueba.src  # corre tu analizador sobre un archivo tuyo
```

Al subir tus cambios (`git push`), GitHub corre las mismas pruebas automáticamente: ve a la pestaña **Actions** de tu repositorio. Un ✅ verde significa que pasaron **todos los casos visibles**; la calificación final también usa **casos ocultos**, así que no te limites a hacer pasar los visibles: prueba tus propios archivos con casos raros.

## 7. Calificación (100 puntos)

| Componente | Puntos |
|---|---|
| Pruebas automáticas — Parte A (15) + Parte B (25) + variante (10) | 50 |
| Defensa oral individual | 30 |
| Calidad del código, comentarios en el `.l`, `NOTAS.md` y uso del repositorio (commits de todos los integrantes) | 20 |

## 8. Integridad académica

El código debe ser del equipo. En la defensa oral deberás explicar cualquier línea de tu analizador y modificarlo en vivo. Si usas ayudas externas (documentación, foros, asistentes de IA), indícalo en `NOTAS.md` y asegúrate de entender cada línea que entregas.

## 9. Estructura del repositorio

```
src/lexer.l          <- aquí trabajas
tests/cases/         <- casos visibles (.src entrada, .out salida esperada)
tests/run_tests.py   <- corredor de pruebas (no lo modifiques)
VARIANT              <- tu letra
NOTAS.md             <- preguntas de reflexión y declaración de ayudas
Makefile
```

## 10. Ayuda

- Manual de Flex: https://westes.github.io/flex/manual/
- Condiciones de inicio: https://westes.github.io/flex/manual/Start-Conditions.html
- Probar patrones: https://regex101.com
- Cápsulas y módulo 6 en Moodle (comentarios anidados, maximal munch, errores léxicos).
