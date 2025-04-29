#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <semaphore.h>
#include <sys/shm.h>
#include <sys/wait.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <time.h>
#include <fcntl.h>
#include <string.h>
#include <stdarg.h>

#define MAX_CARS 10000
#define MAX_TRUCKS 10000
#define FERRY_CAP_MIN 3
#define FERRY_CAP_MAX 100

typedef struct
{
    int action_counter;
    int cars_waiting[2];
    int trucks_waiting[2];
    int cars_on_ferry;
    int trucks_on_ferry;
    int ferry_capacity;
    int ferry_port;
    int cars_done;
    int trucks_done;
    int total_cars;
    int total_trucks;
    int cars_transported;
    int trucks_transported;
} SharedData;

sem_t *mutex;
sem_t *ferry_sem;
sem_t *loading_sem;
sem_t *unloading_sem;
sem_t *car_queue[2];
sem_t *truck_queue[2];

FILE *output_file;
SharedData *shared;

void random_delay(int max_microseconds)
{
    if (max_microseconds <= 0)
        return;
    usleep(rand() % (max_microseconds + 1));
}

void synchronized_print(const char *format, ...)
{
    sem_wait(mutex);

    va_list args;
    va_start(args, format);
    fprintf(output_file, "%d: ", shared->action_counter++);
    vfprintf(output_file, format, args);
    fflush(output_file);
    va_end(args);

    sem_post(mutex);
}

void initialize_resources()
{
    // Initialize shared memory
    shared = mmap(NULL, sizeof(SharedData), PROT_READ | PROT_WRITE,
                  MAP_SHARED | MAP_ANONYMOUS, -1, 0);
    memset(shared, 0, sizeof(SharedData));
    shared->action_counter = 1; // Start counting from 1

    // Initialize semaphores
    mutex = sem_open("/ferry_mutex", O_CREAT | O_EXCL, 0666, 1);
    ferry_sem = sem_open("/ferry_sem", O_CREAT | O_EXCL, 0666, 0);
    loading_sem = sem_open("/loading_sem", O_CREAT | O_EXCL, 0666, 0);
    unloading_sem = sem_open("/unloading_sem", O_CREAT | O_EXCL, 0666, 0);

    for (int i = 0; i < 2; i++)
    {
        char name[20];
        snprintf(name, sizeof(name), "/car_queue_%d", i);
        car_queue[i] = sem_open(name, O_CREAT | O_EXCL, 0666, 0);

        snprintf(name, sizeof(name), "/truck_queue_%d", i);
        truck_queue[i] = sem_open(name, O_CREAT | O_EXCL, 0666, 0);
    }
}

void cleanup()
{
    // Close and unlink semaphores
    sem_close(mutex);
    sem_unlink("/ferry_mutex");

    sem_close(ferry_sem);
    sem_unlink("/ferry_sem");

    sem_close(loading_sem);
    sem_unlink("/loading_sem");

    sem_close(unloading_sem);
    sem_unlink("/unloading_sem");

    for (int i = 0; i < 2; i++)
    {
        sem_close(car_queue[i]);
        sem_close(truck_queue[i]);

        char name[20];
        snprintf(name, sizeof(name), "/car_queue_%d", i);
        sem_unlink(name);

        snprintf(name, sizeof(name), "/truck_queue_%d", i);
        sem_unlink(name);
    }

    munmap(shared, sizeof(SharedData));
    fclose(output_file);
}

void ferry_process(int TP)
{
    synchronized_print("P: started\n");

    while (1)
    {
        // Travel to port
        srand(time(NULL) ^ getpid());
        random_delay(TP);
        synchronized_print("P: arrived to %d\n", shared->ferry_port);

        // Unload all vehicles
        while (shared->cars_on_ferry > 0 || shared->trucks_on_ferry > 0)
        {
            sem_post(unloading_sem);
            sem_wait(ferry_sem);
        }

        // Load vehicles
        int current_port = shared->ferry_port;
        int remaining_capacity = shared->ferry_capacity;
        int try_truck = 1; // Alternate between truck and car

        while (remaining_capacity > 0)
        {
            sem_wait(mutex);
            int trucks_available = shared->trucks_waiting[current_port] > 0;
            int cars_available = shared->cars_waiting[current_port] > 0;
            sem_post(mutex);

            if (try_truck && trucks_available && remaining_capacity >= 3)
            {
                sem_post(truck_queue[current_port]);
                sem_wait(loading_sem);
                remaining_capacity -= 3;
                try_truck = 0;
            }
            else if (cars_available && remaining_capacity >= 1)
            {
                sem_post(car_queue[current_port]);
                sem_wait(loading_sem);
                remaining_capacity -= 1;
                try_truck = 1;
            }
            else if (trucks_available && remaining_capacity >= 3)
            {
                sem_post(truck_queue[current_port]);
                sem_wait(loading_sem);
                remaining_capacity -= 3;
                try_truck = 0;
            }
            else
            {
                break;
            }
        }

        synchronized_print("P: leaving %d\n", current_port);

        // Switch port
        shared->ferry_port = (shared->ferry_port + 1) % 2;

        // Check termination condition
        sem_wait(mutex);
        int all_done = (shared->cars_transported == shared->total_cars) &&
                       (shared->trucks_transported == shared->total_trucks) &&
                       (shared->cars_on_ferry == 0) &&
                       (shared->trucks_on_ferry == 0);
        sem_post(mutex);

        if (all_done)
            break;
    }

    // Final trip to dock
    random_delay(TP);
    synchronized_print("P: finish\n");
}

void car_process(int id, int port, int TA)
{
    synchronized_print("O %d: started\n", id);

    // Travel to port
    srand(time(NULL) ^ getpid());
    random_delay(TA);
    synchronized_print("O %d: arrived to %d\n", id, port);

    sem_wait(mutex);
    shared->cars_waiting[port]++;
    sem_post(mutex);

    // Wait for ferry
    sem_wait(car_queue[port]);

    // Board ferry
    sem_wait(mutex);
    shared->cars_waiting[port]--;
    shared->cars_on_ferry++;
    sem_post(mutex);

    synchronized_print("O %d: boarding\n", id);
    sem_post(loading_sem);

    // Wait for arrival at destination
    sem_wait(unloading_sem);

    // Leave ferry
    sem_wait(mutex);
    shared->cars_on_ferry--;
    shared->cars_transported++;
    int dest_port = (port + 1) % 2;
    sem_post(mutex);

    synchronized_print("O %d: leaving in %d\n", id, dest_port);
    sem_post(ferry_sem);
}

void truck_process(int id, int port, int TA)
{
    synchronized_print("N %d: started\n", id);

    // Travel to port
    srand(time(NULL) ^ getpid());
    random_delay(TA);
    synchronized_print("N %d: arrived to %d\n", id, port);

    sem_wait(mutex);
    shared->trucks_waiting[port]++;
    sem_post(mutex);

    // Wait for ferry
    sem_wait(truck_queue[port]);

    // Board ferry
    sem_wait(mutex);
    shared->trucks_waiting[port]--;
    shared->trucks_on_ferry++;
    sem_post(mutex);

    synchronized_print("N %d: boarding\n", id);
    sem_post(loading_sem);

    // Wait for arrival at destination
    sem_wait(unloading_sem);

    // Leave ferry
    sem_wait(mutex);
    shared->trucks_on_ferry--;
    shared->trucks_transported++;
    int dest_port = (port + 1) % 2;
    sem_post(mutex);

    synchronized_print("N %d: leaving in %d\n", id, dest_port);
    sem_post(ferry_sem);
}

int main(int argc, char *argv[])
{
    if (argc != 6)
    {
        fprintf(stderr, "Usage: %s N O K TA TP\n", argv[0]);
        return 1;
    }

    int N = atoi(argv[1]);
    int O = atoi(argv[2]);
    int K = atoi(argv[3]);
    int TA = atoi(argv[4]);
    int TP = atoi(argv[5]);

    // Validate input
    if (N < 0 || N >= MAX_TRUCKS || O < 0 || O >= MAX_CARS ||
        K < FERRY_CAP_MIN || K > FERRY_CAP_MAX ||
        TA < 0 || TA > 10000 || TP < 0 || TP > 1000)
    {
        fprintf(stderr, "Invalid input parameters\n");
        return 1;
    }

    srand(time(NULL));
    output_file = fopen("proj2.out", "w");
    if (output_file == NULL)
    {
        perror("fopen");
        return 1;
    }

    initialize_resources();
    shared->ferry_capacity = K;
    shared->total_cars = O;
    shared->total_trucks = N;

    // Create ferry process
    pid_t ferry_pid = fork();
    if (ferry_pid == 0)
    {
        ferry_process(TP);
        exit(0);
    }
    else if (ferry_pid < 0)
    {
        perror("fork");
        cleanup();
        return 1;
    }

    // Create truck processes
    for (int i = 1; i <= N; i++)
    {
        pid_t pid = fork();
        if (pid == 0)
        {
            int port = rand() % 2;
            truck_process(i, port, TA);
            exit(0);
        }
        else if (pid < 0)
        {
            perror("fork");
            cleanup();
            return 1;
        }
    }

    // Create car processes
    for (int i = 1; i <= O; i++)
    {
        pid_t pid = fork();
        if (pid == 0)
        {
            int port = i % 2;
            car_process(i, port, TA);
            exit(0);
        }
        else if (pid < 0)
        {
            perror("fork");
            cleanup();
            return 1;
        }
    }

    // Wait for all children
    for (int i = 0; i < 1 + N + O; i++)
    {
        wait(NULL);
    }

    cleanup();
    return 0;
}