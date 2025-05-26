#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

typedef struct
{
    int value;
    process_queue *queue;
} Semaphore;

void lock(Semaphore *sem)
{
    sem->value--;
    if (sem->value < 0)
    {
        // Add the current process to the queue
        // and block it
        remove(readyQueue, currentProcess);
        append(s->queue, currentProcess);
    }
}

void unlock(Semaphore *sem)
{
    // Implementation of unlock function
    sem->value++;
    if (sem->value <= 0)
    {
        // Remove a process from the queue
        // and wake it up
        int P = get(sem->queue);
        append(readyQueue, P);
    }
}