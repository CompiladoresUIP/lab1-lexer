#!/usr/bin/env python3
"""Muestra tu código fuente y, debajo de cada línea, los tokens que reconoció tu analizador.

Uso:  python3 tools/ver.py archivo.src build/lexer      (o:  make ver F=archivo.src)
"""
import re, subprocess, sys

TIPOS = "KEYWORD|IDENT|INT|FLOAT|STRING|CHAR|OP|PUNCT|HEXINT|BININT|ERROR"

def main():
    if len(sys.argv) != 3:
        print(__doc__); sys.exit(1)
    src, binary = sys.argv[1], sys.argv[2]
    texto = open(src, encoding="utf-8").read()
    salida = subprocess.run([binary], input=texto.encode(), capture_output=True, timeout=5).stdout.decode("utf-8", "replace")
    por_linea, sin_formato = {}, []
    patron = re.compile(r"(?<![0-9])(\d+) (%s)(?: ([^\n]*))?$" % TIPOS)
    for ln in salida.split("\n"):
        if not ln.strip():
            continue
        m = patron.search(ln)
        if m:
            por_linea.setdefault(int(m.group(1)), []).append((m.group(2), m.group(3) or ""))
            resto = ln[:m.start()]
            if resto.strip():
                sin_formato.append(resto)
        else:
            sin_formato.append(ln)
    total = sum(len(v) for v in por_linea.values())
    print("=" * 64)
    print(f" {src}")
    print("=" * 64)
    for n, linea in enumerate(texto.split("\n"), 1):
        if n == len(texto.split("\n")) and linea == "":
            break
        print(f"{n:>3} | {linea}")
        toks = por_linea.get(n, [])
        if toks:
            print("      -> " + "  ".join(f"{t}({l})" if l else t for t, l in toks))
    print("-" * 64)
    print(f" {total} tokens reconocidos")
    if sin_formato:
        print("\n Salida que NO tiene formato de token (texto que Flex copió tal cual):")
        for ln in sin_formato:
            print("   |" + ln)

if __name__ == "__main__":
    main()
