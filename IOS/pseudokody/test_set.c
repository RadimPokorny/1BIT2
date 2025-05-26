#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <pthread.h>
#include <semaphore.h>

struct sSemaphore
{
    int value;
    queue *q;
    bool locked;
};

void init(struct sSemaphore *sem, int value)
{
    sem->value = value;
    sem->locked = false;
}

void lock(struct sSemaphore *sem)
{
    while (TestAndSet(&sem->locked))
    {
        sem->value--;
        if (sem->value < 0)
        {
            process_t *C = get(ready_q);
            append(sem->q, C);
            s->locked = false;
            switch ()
                ;
        }
        else
        {
            sem->locked = false;
        }
    }
}