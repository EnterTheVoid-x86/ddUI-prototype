# ddUI - dynamic window manager
# See LICENSE file for copyright and license details.

include config.mk

SRC = drw.c ddUI.c util.c
OBJ = ${SRC:.c=.o}

# FreeBSD users, prefix all ifdef, else and endif statements with a . for this to work (e.g. .ifdef)

ifdef YAJLLIBS
all: options ddUI ddUI-msg
else
all: options ddUI
endif

options:
	@echo ddUI build options:
	@echo "CFLAGS   = ${CFLAGS}"
	@echo "LDFLAGS  = ${LDFLAGS}"
	@echo "CC       = ${CC}"

.c.o:
	${CC} -c ${CFLAGS} $<

${OBJ}: config.h config.mk patches.h

config.h:
	cp config.def.h $@

patches.h:
	cp patches.def.h $@

ddUI: ${OBJ}
	${CC} -o $@ ${OBJ} ${LDFLAGS}

ifdef YAJLLIBS
ddUI-msg:
	${CC} -o $@ patch/ipc/ddUI-msg.c ${LDFLAGS}
endif

clean:
	rm -f ddUI ${OBJ} ddUI-${VERSION}.tar.gz
	rm -f ddUI-msg

dist: clean
	mkdir -p ddUI-${VERSION}
	cp -R LICENSE Makefile README config.def.h config.mk\
		ddUI.1 drw.h util.h ${SRC} ddUI.png transient.c ddUI-${VERSION}
	tar -cf ddUI-${VERSION}.tar ddUI-${VERSION}
	gzip ddUI-${VERSION}.tar
	rm -rf ddUI-${VERSION}

install: all
	mkdir -p ${DESTDIR}${PREFIX}/bin
	cp -f ddUI ${DESTDIR}${PREFIX}/bin
ifdef YAJLLIBS
	cp -f ddUI-msg ${DESTDIR}${PREFIX}/bin
endif
	#cp -f patch/ddUIc ${DESTDIR}${PREFIX}/bin
	chmod 755 ${DESTDIR}${PREFIX}/bin/ddUI
ifdef YAJLLIBS
	chmod 755 ${DESTDIR}${PREFIX}/bin/ddUI-msg
endif
	mkdir -p ${DESTDIR}${MANPREFIX}/man1
	sed "s/VERSION/${VERSION}/g" < ddUI.1 > ${DESTDIR}${MANPREFIX}/man1/ddUI.1
	chmod 644 ${DESTDIR}${MANPREFIX}/man1/ddUI.1
	mkdir -p ${DESTDIR}${PREFIX}/share/xsessions
	test -f ${DESTDIR}${PREFIX}/share/xsessions/ddUI.desktop || cp -n ddUI.desktop ${DESTDIR}${PREFIX}/share/xsessions
	chmod 644 ${DESTDIR}${PREFIX}/share/xsessions/ddUI.desktop

uninstall:
	rm -f ${DESTDIR}${PREFIX}/bin/ddUI\
		${DESTDIR}${MANPREFIX}/man1/ddUI.1\
		${DESTDIR}${PREFIX}/share/xsessions/ddUI.desktop

.PHONY: all options clean dist install uninstall
