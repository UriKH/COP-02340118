test.exe: students_code.o test1.o _aux.o
	gcc -g students_code.o test1.o _aux.o -o test.exe

students_code.o: students_code.S
	gcc -c students_code.S -o students_code.o

test1.o: test1.c
	gcc -c test1.c -o test1.o

clean:
	rm test1.o students_code.o

generate:
	gcc -g generate_tests.c -o generate_tests.exe