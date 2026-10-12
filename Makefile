FLEX ?= flex
CC   ?= gcc
CFLAGS ?= -Wall -O1
BUILD = build

all: $(BUILD)/lexer

$(BUILD)/lexer: src/lexer.l
	mkdir -p $(BUILD)
	$(FLEX) -o $(BUILD)/lex.yy.c src/lexer.l
	$(CC) $(CFLAGS) -o $@ $(BUILD)/lex.yy.c

# make test              -> compila y corre todos los casos visibles (te dice cuántos pasan)
test: all
	python3 tests/run_tests.py --binary $(BUILD)/lexer --cases tests/cases

# make test-one T=a03    -> solo los casos cuyo nombre contiene T
test-one: all
	python3 tests/run_tests.py --binary $(BUILD)/lexer --cases tests/cases --only $(T)

# make ver F=ejemplos/ej01_hola.src   -> tu código fuente con sus tokens debajo de cada línea
ver: all
	python3 tools/ver.py $(F) $(BUILD)/lexer

# make run F=archivo.src -> la salida cruda del analizador
run: all
	./$(BUILD)/lexer < $(F)

clean:
	rm -rf $(BUILD)

.PHONY: all test test-one ver run clean
