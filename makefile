ifeq (${IOPBINDIR},)
IOPBINDIR = /usr/local/iop
endif

.PHONY: all c java doc clean install

all: java c

c:
	cd src; make

java:
	ant

javaclean:
	ant clean

src-zip:
	ant zip

doc: 
	ant api-g2d

clean: javaclean
	cd src; make clean

install:
	ant install

install-PLA:
	ant install-PLA

run-PLA:
	ant run-PLA

dist: all
	ant distributable

webdoc:
	ant api-g2d
	cp -r /home/iop/IOP/doc/api-g2d/*  ~iop/public_html/GraphicsActor2D/doc/

