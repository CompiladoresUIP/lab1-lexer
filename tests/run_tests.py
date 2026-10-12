#!/usr/bin/env python3
"""Corredor de pruebas del Laboratorio 1 (analizador léxico MiniC).

Uso:  python3 tests/run_tests.py --binary build/lexer --cases tests/cases [--variant A] [--only a03]
Cada caso es un par NOMBRE.src / NOMBRE.out. Prefijos:
  aNN_*    Parte A (checkpoint)      -> 15 puntos en total
  bNN_*    Parte B (entrega final)   -> 25 puntos en total
  v_X_*    Variante X (solo si tu VARIANT es X) -> 10 puntos en total
Los casos del instructor usan el prefijo h (ha01_, hb01_, hv_X_) y se califican igual.
"""
import argparse, glob, os, re, subprocess, sys

POINTS = {"a": 15, "b": 25, "v": 10}
NAMES = {"a": "Parte A (checkpoint)", "b": "Parte B (final)", "v": "Variante"}

def parse(name):
    m = re.match(r"^h?([abv])(?:_([A-D])_)?", name)
    return (m.group(1), m.group(2)) if m else (None, None)

def norm(s):
    return "\n".join(line.rstrip() for line in s.replace("\r\n", "\n").strip("\n").split("\n")).strip()

def run_suite(binary, case_dirs, variant=None, only=None):
    results = []
    for d in case_dirs:
        for src in sorted(glob.glob(os.path.join(d, "*.src"))):
            name = os.path.basename(src)[:-4]
            grp, var = parse(name)
            if grp is None or (only and only not in name):
                continue
            if grp == "v" and var != variant:
                continue
            exp_path = src[:-4] + ".out"
            expected = open(exp_path, encoding="utf-8").read()
            try:
                p = subprocess.run([binary], stdin=open(src, "rb"), capture_output=True, timeout=5)
                got = p.stdout.decode("utf-8", "replace")
                err = "" if p.returncode == 0 else f"(el programa terminó con código {p.returncode})"
            except subprocess.TimeoutExpired:
                got, err = "", "(tiempo excedido: ¿ciclo infinito?)"
            ok = norm(got) == norm(expected) and not err
            results.append({"name": name, "group": grp, "ok": ok, "got": got, "expected": expected, "err": err})
    return results

def score(results):
    per, total = {}, 0.0
    for g in "abv":
        rs = [r for r in results if r["group"] == g]
        if rs:
            per[g] = (sum(r["ok"] for r in rs), len(rs))
            total += POINTS[g] * per[g][0] / per[g][1]
    return per, total

def first_diff(got, expected, limit=4):
    g, e = norm(got).split("\n"), norm(expected).split("\n")
    out = []
    for i in range(max(len(g), len(e))):
        a = g[i] if i < len(g) else "<fin de salida>"
        b = e[i] if i < len(e) else "<fin esperado>"
        if a != b:
            out.append(f"    línea {i+1}: obtuviste  [{a}]\n             esperado   [{b}]")
            if len(out) >= limit:
                break
    return "\n".join(out)

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--binary", default="build/lexer")
    ap.add_argument("--cases", nargs="+", default=["tests/cases"])
    ap.add_argument("--variant", default=None)
    ap.add_argument("--only", default=None)
    a = ap.parse_args()
    variant = a.variant
    if variant is None and os.path.exists("VARIANT"):
        variant = open("VARIANT").read().strip().upper()[:1] or None
    results = run_suite(a.binary, a.cases, variant, a.only)
    print(f"Variante: {variant or '(sin definir: edita el archivo VARIANT)'}\n")
    for r in results:
        print(("  PASS  " if r["ok"] else "  FAIL  ") + r["name"])
        if not r["ok"]:
            print(r["err"] or first_diff(r["got"], r["expected"]))
    per, total = score(results)
    print()
    lines = []
    for g in "abv":
        if g in per:
            lines.append(f"{NAMES[g]}: {per[g][0]}/{per[g][1]} casos")
    print("\n".join(lines))
    print(f"\nPuntaje automático (casos visibles): {total:.1f} / {sum(POINTS.values())}")
    summ = os.environ.get("GITHUB_STEP_SUMMARY")
    if summ:
        with open(summ, "a", encoding="utf-8") as f:
            f.write("## Resultado de las pruebas\n\n| Caso | Resultado |\n|---|---|\n")
            for r in results:
                f.write(f"| `{r['name']}` | {'✅' if r['ok'] else '❌'} |\n")
            f.write("\n" + "  \n".join(lines) + f"\n\n**Puntaje automático (visibles): {total:.1f} / {sum(POINTS.values())}**\n")
    sys.exit(0 if all(r["ok"] for r in results) else 1)

if __name__ == "__main__":
    main()
