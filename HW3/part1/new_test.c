#include <stdio.h>
#include <string.h>

int compute_char_repeats(char* buffer, int line_length, char special_char);
int parse_lines(char* path, int* line_max_len, int* line_max_repeat);

int main(int argc, char* argv[]){
    int line_max_len = 0;
    int line_max_repeat = 0;
    int lines = parse_lines("first_test", &line_max_len, &line_max_repeat);
    printf("There are %d lines. The longest line is of length %d and the most repeats of the special character in a single line is %d.\n", lines, line_max_len, line_max_repeat);
    return 0;
}