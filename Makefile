prefix ?= /usr

all:

install:
	mkdir -p $(DESTDIR)$(prefix)/bin
	install -o root -g root -m 755 main.rb \
		$(DESTDIR)$(prefix)/bin/puavo-whiteboard-screenshot

clean:
