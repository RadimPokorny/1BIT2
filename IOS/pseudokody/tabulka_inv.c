#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <pthread.h>
#include <semaphore.h>
#include <unistd.h>

struct table
{
    int page;
    int pid;
};

table inv_table[n];

int page_frame(int page, int pid)
{
    for (int i = 0; i < n; ++i)
    {
        if (inv_table[i].page == page && inv_table[i].pid == pid)
        {
            return i;
        }
    }

    return -1;
}