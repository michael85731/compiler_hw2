rm -r parser.tab.c parser.tab.h output.exe lex.yy.c
flex -l scanner.l
bison -vd parser.y
gcc -o output.exe lex.yy.c parser.tab.c -lm -lfl
./output.exe < test.rust