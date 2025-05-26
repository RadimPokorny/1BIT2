#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <pthread.h>
#include <semaphore.h>
#include <unistd.h>

struct inv_tab_item
{
    page pg;
    process_id pid;
    next_item *next;
}

page2frame(inv_tab_item *table, page pg, process_id pid)
{
    int fr = hash(pg, pid);
    while (pg != table[fr].pg || pid != table[fr].pid)
    {
        fr = table[fr].next;
        if (table[fr].next == -1)
        {
            return -1; // Not found
        }
    }
}