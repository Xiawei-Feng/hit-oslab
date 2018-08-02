//whoami.c
#define __LIBRARY__
#include <unistd.h>
#include <stdio.h>

_syscall2(int, whoami, char*, name, unsigned int, size)

int main(void)
{
    char str[30];  
    if(whoami(str, 24)<0) 
        return -1;

    printf("%s\n", str);
    return 0;
}