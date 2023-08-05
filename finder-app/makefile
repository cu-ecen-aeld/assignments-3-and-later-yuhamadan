
CROSS_COMPILE ?= -1

default: writer.c

ifeq ($(CROSS_COMPILE), aarch64-none-linux-gnu-)
	aarch64-none-linux-gnu-gcc -o writer writer.c -I.
else
	gcc -o writer writer.c -I.
endif

clean:
	rm -f ./writer ./*.o