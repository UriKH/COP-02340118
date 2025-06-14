#include <stdio.h>
#include <stdlib.h>

int main(int argc, char* argv[]){
    if (argc > 1){
        FILE* fd = fopen(argv[1], "w");
        if (fd == NULL){
            printf("could not open %s\n", argv[1]);
            exit(1);
        }
        // const char* msg = "aAaaAAaAaAaAa\nAAaAAAAAAAAAA\nAAAAAAAAAAAAA\nAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAaAAAAAAAAAAAAAAAAAAAA\nAaAaAAaaaaaa";
        const char* msg = "I love ATAM\n.";
        fputs(msg, fd);
        fclose(fd);
    }
    else{
        printf("not enough arguments\n");
    }
    return 0;
}