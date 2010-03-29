VERSION=$(shell grep -i '^version' plugins/CKEditor/config.yaml | sed 's/.*: *//')
NAME=$(shell basename `pwd`)
BASENAME=$(shell basename `pwd`)-${VERSION}

all: build

build:
	make -C mt-static/plugins/CKEditor build

unpack:
	make -C mt-static/plugins/CKEditor unpack

clean:
	make -C mt-static/plugins/CKEditor clean

distclean:
	make -C mt-static/plugins/CKEditor distclean
	rm -fr CKEditor-*
	rm -fr ckeditor-for-mt

dist:
	rm -fr /tmp/${BASENAME}*
	mkdir -p /tmp/${BASENAME}/plugins /tmp/${BASENAME}/mt-static/plugins
	cp -pbR plugins/${NAME} /tmp/${BASENAME}/plugins/${NAME}
	rm -fr /tmp/${BASENAME}/plugins/${NAME}/t
	cp INSTALL* AUTHOR* /tmp/${BASENAME}/
	make DESTDIR=/tmp/${BASENAME}/mt-static/plugins/${NAME} -C mt-static/plugins/CKEditor install
	tar zcf ${BASENAME}.tgz -C /tmp ${BASENAME}
	(cd /tmp; zip -qr ${BASENAME}.zip ${BASENAME})
	mv /tmp/${BASENAME}.zip .

release:
	for f in CKEditor-*.tgz; do \
		tar zxf $$f || exit; \
		git clone git@github.com:usualoma/ckeditor-for-mt.git; \
		rm -fr ckeditor-for-mt/*; \
		mv `echo $$f | sed 's/\.tgz//'`/* ckeditor-for-mt/; \
		cd ckeditor-for-mt/; \
		git checkout -b commit_download origin/download; \
		git add .; \
		git commit -m "Release `echo $$f | sed 's/.*-//;s/\.tgz//'`."; \
	done
