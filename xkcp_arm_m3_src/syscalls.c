#include <sys/stat.h>
#include <sys/types.h>
#include <errno.h>
#include <unistd.h>

static char *heap_end;

caddr_t _sbrk(int incr) {
    extern char _end; // defined by the linker
    char *prev_heap_end;

    if (heap_end == 0)
        heap_end = &_end;

    prev_heap_end = heap_end;
    heap_end += incr;
    return (caddr_t) prev_heap_end;
}

int _write(int file, char *ptr, int len) {
    (void)file;
    for (int i = 0; i < len; i++) {
        // Replace this with actual UART/ITM/semihosting logic if needed
        volatile char *uart = (char *)0x40011000; // example UART addr
        *uart = ptr[i];
    }
    return len;
}

int _read(int file, char *ptr, int len) {
    errno = ENOSYS;
    return -1;
}

int _close(int file) {
    errno = ENOSYS;
    return -1;
}

int _fstat(int file, struct stat *st) {
    st->st_mode = S_IFCHR;
    return 0;
}

int _isatty(int file) {
    return 1;
}

int _lseek(int file, int ptr, int dir) {
    return 0;
}

void _exit(int status) {
    while (1) { }
}

int _kill(int pid, int sig) {
    errno = EINVAL;
    return -1;
}

int _getpid(void) {
    return 1;
}