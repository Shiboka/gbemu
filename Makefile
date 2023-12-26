CC=nim

all: src/main.nim
	mkdir -p bin
	$(CC) c -o:bin/gbemu $<

clean:
	rm bin/gbemu*