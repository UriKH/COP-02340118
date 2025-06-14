test.exe: students_code.o new_test.o _aux.o
	gcc -g students_code.o new_test.o _aux.o -o test.exe

students_code.o: students_code.S
	gcc -c students_code.S -o students_code.o

new_test.o: new_test.c
	gcc -c new_test.c -o new_test.o

clean:
	rm new_test.o students_code.o

generate:
	gcc -g generate_tests.c -o generate_tests.exe