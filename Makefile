.POSIX:
.SUFFIXES:

include config.mk

# flags for compiling
DWLCPPFLAGS = -I. -DWLR_USE_UNSTABLE -D_POSIX_C_SOURCE=200809L -DVERSION=\"$(_VERSION)\" $(XWAYLAND)
DWLDEVCFLAGS = -pedantic -Wall -Wextra -Wdeclaration-after-statement -Wno-unused-parameter -Wno-sign-compare -Wshadow -Wunused-macros\
	-Werror=strict-prototypes -Werror=implicit -Werror=return-type -Werror=incompatible-pointer-types -g

# CFLAGS / LDFLAGS
PKGS      = wlroots wayland-server xkbcommon libinput $(XLIBS) pixman-1 fcft
DWLCFLAGS = `$(PKG_CONFIG) --cflags $(PKGS)` $(DWLCPPFLAGS) $(DWLDEVCFLAGS) $(CFLAGS)
LDLIBS    = `$(PKG_CONFIG) --libs $(PKGS)` $(LIBS)

all: dwl
dwl: dwl.o util.o dwl-ipc-unstable-v2-protocol.o
	$(CC) dwl.o util.o dwl-ipc-unstable-v2-protocol.o $(LDLIBS) $(LDFLAGS) $(DWLCFLAGS) -o $@
dwl.o: dwl.c config.mk config.h client.h xdg-shell-protocol.h wlr-layer-shell-unstable-v1-protocol.h dwl-ipc-unstable-v2-protocol.o pointer-constraints-unstable-v1-protocol.h
util.o: util.c util.h
dwl-ipc-unstable-v2-protocol.o: dwl-ipc-unstable-v2-protocol.h

# wayland-scanner is a tool which generates C headers and rigging for Wayland
# protocols, which are specified in XML. wlroots requires you to rig these up
# to your build system yourself and provide them in the include path.
WAYLAND_SCANNER   = `$(PKG_CONFIG) --variable=wayland_scanner wayland-scanner`
WAYLAND_PROTOCOLS = `$(PKG_CONFIG) --variable=pkgdatadir wayland-protocols`

xdg-shell-protocol.h:
	$(WAYLAND_SCANNER) server-header \
		$(WAYLAND_PROTOCOLS)/stable/xdg-shell/xdg-shell.xml $@
pointer-constraints-unstable-v1-protocol.h:
	$(WAYLAND_SCANNER) server-header \
		$(WAYLAND_PROTOCOLS)/unstable/pointer-constraints/pointer-constraints-unstable-v1.xml $@
wlr-layer-shell-unstable-v1-protocol.h:
	$(WAYLAND_SCANNER) server-header \
		protocols/wlr-layer-shell-unstable-v1.xml $@
dwl-ipc-unstable-v2-protocol.h:
	$(WAYLAND_SCANNER) server-header \
		protocols/dwl-ipc-unstable-v2.xml $@
dwl-ipc-unstable-v2-protocol.c:
	$(WAYLAND_SCANNER) private-code \
		protocols/dwl-ipc-unstable-v2.xml $@

config.h:
	cp config.def.h $@
clean:
	rm -f dwl *.o *-protocol.h

dist: clean
	mkdir -p dwl-$(_VERSION)
	cp -R LICENSE* Makefile README.md client.h config.def.h\
		config.mk protocols dwl.1 dwl.c util.c util.h dwl-clipboard-watcher\
		dwl-$(_VERSION)
	tar -caf dwl-$(_VERSION).tar.gz dwl-$(_VERSION)
	rm -rf dwl-$(_VERSION)

install: dwl
	mkdir -p $(DESTDIR)$(PREFIX)/bin
	cp -f dwl $(DESTDIR)$(PREFIX)/bin
	chmod 755 $(DESTDIR)$(PREFIX)/bin/dwl
	cp -f dwl-clipboard-watcher $(DESTDIR)$(PREFIX)/bin/dwl-clipboard-watcher
	chmod 755 $(DESTDIR)$(PREFIX)/bin/dwl-clipboard-watcher
	mkdir -p $(DESTDIR)$(MANDIR)/man1
	cp -f dwl.1 $(DESTDIR)$(MANDIR)/man1
	chmod 644 $(DESTDIR)$(MANDIR)/man1/dwl.1
uninstall:
	rm -f $(DESTDIR)$(PREFIX)/bin/dwl $(DESTDIR)$(MANDIR)/man1/dwl.1 $(DESTDIR)$(PREFIX)/bin/dwl-clipboard-watcher

.SUFFIXES: .c .o
.c.o:
	$(CC) $(CPPFLAGS) $(DWLCFLAGS) -c $<
