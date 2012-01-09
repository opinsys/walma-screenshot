prefix ?= /usr

all:

install:
	mkdir -p $(DESTDIR)$(prefix)/lib/ruby/1.8/
	cp -r walma-screenshot/ $(DESTDIR)$(prefix)/lib/ruby/1.8/
	cp -vr share/ $(DESTDIR)$(prefix)/
	mkdir -p $(DESTDIR)$(prefix)/bin
	install -o root -g root -m 755 walma-screenshot.rb \
		$(DESTDIR)$(prefix)/bin/walma-screenshot

clean:
