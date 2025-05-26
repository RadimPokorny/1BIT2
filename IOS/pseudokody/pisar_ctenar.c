#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

typedef struct
{
    int val;
} Semaphore;

int readcount;

Semaphore wrt, mutex;

void ctenar(Semaphore *sem)
{
    lock(mutex);
    if (readcount == 0)
        lock(wrt);
    unlock(mutex);
    readcount++;
    // Činnost //
    lock(mutex);
    readcount--;
    if (readcount == 0)
        unlock(wrt);
    unlock(mutex);
}

void pisar(Semaphore *sem)
{
    lock(wrt);
    // Činnost //
    unlock(wrt);
}

void initAll()
{
    readcount = 0;
    init(mutex, 1);
    init(wrt, 1);
}