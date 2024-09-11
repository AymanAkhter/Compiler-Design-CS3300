bison -d P1.y
flex P1.l
gcc P1.tab.c lex.yy.c -o out -lfl