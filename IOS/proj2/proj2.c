#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/shm.h>
#include <sys/sem.h>
#include <sys/wait.h>
#include <time.h>
#include <fcntl.h>
#include <string.h>

#define NUM_SEMAPHORES 6
#define MAX_CARS 10000
#define MAX_TRUCKS 10000
#define FERRY_CAP_MIN 3
#define FERRY_CAP_MAX 100

typedef struct
{
    int action_counter;
    int remaining_cars;
    int remaining_trucks;
    int ferry_capacity;
    int ferry_position;
    int ferry_loading;
    int cars_in_ferry;
    int trucks_in_ferry;
    int cars_waiting[2];
    int trucks_waiting[2];
    int cars_transported;
    int trucks_transported;
    int ta; // Added
    int tp; // Added
} SharedData;

// Semaphore indices
enum
{
    SEM_MUTEX,
    SEM_FERRY,
    SEM_CAR_QUEUE_0,
    SEM_CAR_QUEUE_1,
    SEM_TRUCK_QUEUE_0,
    SEM_TRUCK_QUEUE_1
};

void sem_wait(int semid, int sem_num)
{
    struct sembuf op = {sem_num, -1, 0};
    semop(semid, &op, 1);
}

void sem_signal(int semid, int sem_num)
{
    struct sembuf op = {sem_num, 1, 0};
    semop(semid, &op, 1);
}

void write_log(int action_num, const char *message)
{
    FILE *f = fopen("proj2.out", "a");
    if (f == NULL)
    {
        perror("fopen");
        exit(1);
    }
    fprintf(f, "%d: %s\n", action_num, message);
    fclose(f);
}

int get_next_action(SharedData *shared, int semid)
{
    sem_wait(semid, SEM_MUTEX);
    int action = ++shared->action_counter;
    sem_signal(semid, SEM_MUTEX);
    return action;
}

void ferry_process(SharedData *shared, int semid)
{
    int action = get_next_action(shared, semid);
    write_log(action, "P: started");

    int port = 0;
    while (1)
    {
        // Travel to port
        usleep(rand() % (shared->tp + 1));

        action = get_next_action(shared, semid);
        char msg[50];
        snprintf(msg, sizeof(msg), "P: arrived to %d", port);
        write_log(action, msg);

        // Unload vehicles
        sem_wait(semid, SEM_MUTEX);
        shared->ferry_loading = 1;
        shared->cars_in_ferry = 0;
        shared->trucks_in_ferry = 0;
        sem_signal(semid, SEM_MUTEX);

        // Load vehicles
        while (1)
        {
            sem_wait(semid, SEM_MUTEX);
            int truck_space = (shared->ferry_capacity - shared->cars_in_ferry) >= 3;
            int car_space = (shared->ferry_capacity - shared->cars_in_ferry) >= 1;

            if (truck_space && shared->trucks_waiting[port] > 0)
            {
                shared->trucks_waiting[port]--;
                shared->trucks_in_ferry++;
                shared->cars_in_ferry += 3;
                sem_signal(semid, port ? SEM_TRUCK_QUEUE_1 : SEM_TRUCK_QUEUE_0);
                sem_signal(semid, SEM_MUTEX);
            }
            else if (car_space && shared->cars_waiting[port] > 0)
            {
                shared->cars_waiting[port]--;
                shared->cars_in_ferry++;
                sem_signal(semid, port ? SEM_CAR_QUEUE_1 : SEM_CAR_QUEUE_0);
                sem_signal(semid, SEM_MUTEX);
            }
            else
            {
                sem_signal(semid, SEM_MUTEX);
                break;
            }
        }

        action = get_next_action(shared, semid);
        snprintf(msg, sizeof(msg), "P: leaving %d", port);
        write_log(action, msg);

        port = (port + 1) % 2;

        sem_wait(semid, SEM_MUTEX);
        int cars_left = shared->remaining_cars > 0;
        int trucks_left = shared->remaining_trucks > 0;
        int vehicles_ferry = (shared->cars_in_ferry > 0) || (shared->trucks_in_ferry > 0);
        sem_signal(semid, SEM_MUTEX);

        if (!vehicles_ferry && !cars_left && !trucks_left)
        {
            break;
        }
    }

    // Return to dock
    usleep(rand() % (shared->tp + 1));
    action = get_next_action(shared, semid);
    write_log(action, "P: finish");
    exit(0);
}

void truck_process(int id, SharedData *shared, int semid)
{
    int action = get_next_action(shared, semid);
    char msg[50];
    snprintf(msg, sizeof(msg), "N %d: started", id);
    write_log(action, msg);

    int port = rand() % 2;
    usleep(rand() % (shared->ta + 1));

    action = get_next_action(shared, semid);
    snprintf(msg, sizeof(msg), "N %d: arrived to %d", id, port);
    write_log(action, msg);

    sem_wait(semid, SEM_MUTEX);
    shared->trucks_waiting[port]++;
    sem_signal(semid, port ? SEM_TRUCK_QUEUE_1 : SEM_TRUCK_QUEUE_0);
    sem_signal(semid, SEM_MUTEX);

    sem_wait(semid, port ? SEM_TRUCK_QUEUE_1 : SEM_TRUCK_QUEUE_0);

    action = get_next_action(shared, semid);
    snprintf(msg, sizeof(msg), "N %d: boarding", id);
    write_log(action, msg);

    sem_wait(semid, SEM_FERRY);

    int new_port = (port + 1) % 2;
    action = get_next_action(shared, semid);
    snprintf(msg, sizeof(msg), "N %d: leaving in %d", id, new_port);
    write_log(action, msg);

    sem_wait(semid, SEM_MUTEX);
    shared->trucks_transported++;
    shared->remaining_trucks--;
    sem_signal(semid, SEM_MUTEX);

    exit(0);
}

void car_process(int id, SharedData *shared, int semid)
{
    int action = get_next_action(shared, semid);
    char msg[50];
    snprintf(msg, sizeof(msg), "O %d: started", id);
    write_log(action, msg);

    int port = rand() % 2;
    usleep(rand() % (shared->ta + 1));

    action = get_next_action(shared, semid);
    snprintf(msg, sizeof(msg), "O %d: arrived to %d", id, port);
    write_log(action, msg);

    sem_wait(semid, SEM_MUTEX);
    shared->cars_waiting[port]++;
    sem_signal(semid, port ? SEM_CAR_QUEUE_1 : SEM_CAR_QUEUE_0);
    sem_signal(semid, SEM_MUTEX);

    sem_wait(semid, port ? SEM_CAR_QUEUE_1 : SEM_CAR_QUEUE_0);

    action = get_next_action(shared, semid);
    snprintf(msg, sizeof(msg), "O %d: boarding", id);
    write_log(action, msg);

    sem_wait(semid, SEM_FERRY);

    int new_port = (port + 1) % 2;
    action = get_next_action(shared, semid);
    snprintf(msg, sizeof(msg), "O %d: leaving in %d", id, new_port);
    write_log(action, msg);

    sem_wait(semid, SEM_MUTEX);
    shared->cars_transported++;
    shared->remaining_cars--;
    sem_signal(semid, SEM_MUTEX);

    exit(0);
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

    // Initialize random number generator
    srand(time(NULL));

    // Create output file
    FILE *f = fopen("proj2.out", "w");
    if (f == NULL)
    {
        perror("fopen");
        return 1;
    }
    fclose(f);

    // Create shared memory
    int shmid = shmget(IPC_PRIVATE, sizeof(SharedData), IPC_CREAT | 0666);
    if (shmid == -1)
    {
        perror("shmget");
        return 1;
    }

    SharedData *shared = (SharedData *)shmat(shmid, NULL, 0);
    if (shared == (void *)-1)
    {
        perror("shmat");
        return 1;
    }

    // Initialize shared data
    memset(shared, 0, sizeof(SharedData));
    shared->action_counter = 0;
    shared->remaining_cars = O;
    shared->remaining_trucks = N;
    shared->ferry_capacity = K;
    shared->ferry_position = 0;
    shared->ferry_loading = 0;
    shared->ta = TA;
    shared->tp = TP;

    // Create semaphores
    int semid = semget(IPC_PRIVATE, NUM_SEMAPHORES, IPC_CREAT | 0666);
    if (semid == -1)
    {
        perror("semget");
        return 1;
    }

    // Initialize semaphores
    union semun
    {
        int val;
        struct semid_ds *buf;
        unsigned short *array;
    } arg;

    arg.val = 1;
    if (semctl(semid, SEM_MUTEX, SETVAL, arg) == -1)
    {
        perror("semctl");
        return 1;
    }

    arg.val = 0;
    for (int i = 1; i < NUM_SEMAPHORES; i++)
    {
        if (semctl(semid, i, SETVAL, arg) == -1)
        {
            perror("semctl");
            return 1;
        }
    }

    // Create ferry process
    pid_t ferry_pid = fork();
    if (ferry_pid == 0)
    {
        ferry_process(shared, semid);
    }
    else if (ferry_pid < 0)
    {
        perror("fork");
        return 1;
    }

    // Create truck processes
    for (int i = 1; i <= N; i++)
    {
        pid_t pid = fork();
        if (pid == 0)
        {
            truck_process(i, shared, semid);
        }
        else if (pid < 0)
        {
            perror("fork");
            return 1;
        }
    }

    // Create car processes
    for (int i = 1; i <= O; i++)
    {
        pid_t pid = fork();
        if (pid == 0)
        {
            car_process(i, shared, semid);
        }
        else if (pid < 0)
        {
            perror("fork");
            return 1;
        }
    }

    // Wait for all children
    while (wait(NULL) > 0)
        ;

    // Cleanup
    shmdt(shared);
    shmctl(shmid, IPC_RMID, NULL);
    semctl(semid, 0, IPC_RMID, 0);

    return 0;
}