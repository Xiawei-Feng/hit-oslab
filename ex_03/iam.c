//iam.c
#define __LIBRARY__
#include<unistd.h>

_syscall1(int, iam, const char*, name)

int main(int argc,char* argv[])
{
       if(argc>1 && iam(arg[1])>=0) return 0;

       return -1;
}