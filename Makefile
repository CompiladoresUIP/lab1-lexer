FLEX ?= flex
CC   ?= gcc
CFLAGS ?= -Wall -O1
BUILD = build

all: $(BUILD)/lexer

$(BUILD)/lexer: src/lexer.l
	mkdir -p $(BUILD)
	$(FLEX) -o $(BUILD)/lex.yy.c src/lexer.l
	$(CC) $(CFLAGS) -o $@ $(BUILD)/lex.yy.c

test: all
	python3 tests/run_tests.py --binary $(BUILD)/lexer --cases tests/cases

# make test-one T=a03   -> corre solo los casos cuyo nombre contenga T
test-one: all
	python3 tests/run_tests.py --binary $(BUILD)/lexer --cases tests/cases --only $(T)

# make run F=mi_archivo.src
run: all
	./$(BUILD)/lexer < $(F)

clean:
	rm -rf $(BUILD)

.PHONY: all test test-one run clean
