prefix ?= /usr

all: man

install:
	mkdir -p $(DESTDIR)$(prefix)/lib/ruby/1.8/
	cp -r walma-screenshot/ $(DESTDIR)$(prefix)/lib/ruby/1.8/
	cp -r share/ $(DESTDIR)$(prefix)/
	mkdir -p $(DESTDIR)$(prefix)/bin
	install -o root -g root -m 755 walma-screenshot.rb \
		$(DESTDIR)$(prefix)/bin/walma-screenshot


man: WALMA-SCREENSHOT
	mkdir -p share/man/man1/
	rd2 -rrd/rd2man-lib.rb WALMA-SCREENSHOT | gzip -cf > share/man/man1/walma-screenshot.1.gz

clean:
	rm share/man/man1/walma-screenshot.1.gz
