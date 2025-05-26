#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <pthread.h>
#include <semaphore.h>

typedef struct
{
    int wait;
    Sem mutex;
    Sem condition;
} Monitor;

void initMonitor(Monitor *m)
{
    m->wait = 0;
    m->condition = sem_init(0);
    m->mutex = sem_init(1);
}

void enter(Monitor *m)
{
    lock(&m->mutex);
}

void leave(Monitor *m)
{
    unlock(&m->mutex);
}

void wait(Monitor *m)
{
    m->wait++;
    unlock(&m->mutex);

    lock(&m->condition);

    lock(&m->mutex);
}

void notify(Monitor *m)
{
    if (m->wait > 0)
    {
        m->wait--;
        unlock(&m->condition);
    }
}