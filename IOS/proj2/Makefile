# IOS 2. Project - Semaphores
# Author: Radim Pokorny (xpokorr00)
# Date: 2025-03-05

CC = gcc
CFLAGS = -std=gnu99 -Wall -Wextra -Werror -pedantic
TARGET = proj2
SOURCES = proj2.c
OBJS = $(SOURCES:.c=.o)

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) -o $@ $^

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(OBJS) $(TARGET) proj2.out

pack:
	zip proj2.zip proj2.c Makefile

.PHONY: all clean pack