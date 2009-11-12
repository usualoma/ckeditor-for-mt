DESTDIR = 
files = LICENSE.html ckeditor.js contents.css images lang plugins skins themes

all: build

install: build
	if test -z "${DESTDIR}"; then \
		echo "\$$DESTDIR must be specified."; \
		false; \
	fi
	mkdir -p ${DESTDIR}
	cp config.js ${DESTDIR}/config.js
	cp -R lib ${DESTDIR}/lib
	cp -R template ${DESTDIR}/template
	cp -R style ${DESTDIR}/style
	mkdir ${DESTDIR}/ckeditor
	for f in ${files}; do \
		cp -R ckeditor/$$f ${DESTDIR}/ckeditor/$$f; \
	done

build: unpack
	rm -fr  ckeditor_src/release
	java -jar ckreleaser.jar ckeditor_src/ckeditor.release ckeditor_src/ ckeditor_src/release 1 package
	ln -sf ckeditor_src/release/release ckeditor
	rm ckeditor/config.js
	ln -sf `pwd`/config.js ckeditor/config.js

unpack: ckeditor_src/_source/core/ckeditor.js

ckeditor_src/_source/core/ckeditor.js: 
	tar zxf ckeditor_3.*.tar.gz
	for f in *.tar.gz; do \
		tar zxf $$f; \
	done
	for f in *.patch.gz; do \
		zcat $$f | (cd ckeditor; patch -p1) \
	done
	mv ckeditor ckeditor_src

clean:
	rm -f ckeditor
	rm -fr ckeditor_src/release

distclean: clean
	rm -fr ckeditor_src
