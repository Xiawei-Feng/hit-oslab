//who.c
#define __LIBRARY__
#include<errno.h>
#include<asm/segment.h>

#define MAX_LEN=23

char username[30];

int sys_iam(const char *name)
{
    int cnt=0,i=0;
    while(get_fs_byte(name+cnt)!='\0'&&cnt<30)
        ++cnt;
    if(cnt>MAX_LEN)
    {
        errno=EINVAL;
        return -1;
    }
    for(;i<=cnt;++i)
        username[i]=get_fs_byte(name+i);
    return cnt;
}

int sys_whoami(char *name,unsigned int size)
{
    int cnt=0,i=0;
    while(username[cnt]!='\0'&&cnt<30)
        ++cnt;
    if(cnt>size)
    {
        errno=EINVAL;
        return -1;
    }
    for(;i<=cnt;++i)
        put_fs_byte(username[i],(name+i));
    return cnt;
}