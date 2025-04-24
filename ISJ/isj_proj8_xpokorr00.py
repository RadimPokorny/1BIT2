#!/usr/bin/env python3
import time
import asyncio
from time import sleep
from threading import Thread
from multiprocessing import Process

def work_i():
    lst = [i * i for i in range(1000000)]

def work_sleep():
    for _ in range(10000): sleep(0)

async def async_work_sleep():
    for _ in range(10000): await asyncio.sleep(0)

async def async_work_i_square():
    lst = [i * i for i in range(1000000)]

def use_multiprocessing():
    processes = []
    begin = time.perf_counter()
    for _ in range(100):
        p = Process(target=work_sleep)
        p.start()
        processes.append(p)
    for p in processes:
        p.join()
    spent = time.perf_counter() - begin

def use_threading():
    threads = []
    begin = time.perf_counter()
    for _ in range(100):
        t = Thread(target=work_sleep)
        t.start()
        threads.append(t)
    for t in threads:
        t.join()
    spent = time.perf_counter() - begin

async def use_asyncio():
    begin = time.perf_counter()
    tasks = [asyncio.create_task(async_work_sleep()) for _ in range(100)]
    await asyncio.gather(*tasks)
    spent = time.perf_counter() - begin

# Test
if __name__ == "__main__":
    use_multiprocessing()
    use_threading()
    asyncio.run(use_asyncio())