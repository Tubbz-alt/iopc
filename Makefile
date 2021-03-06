ifeq (${IOPBINDIR},)
IOPBINDIR = ${HOME}/bin/IOP
endif

.PHONY: all c clean install

all: c


c:
	$(MAKE) -C src

install: c
	$(MAKE) IOPBINDIR=${IOPBINDIR} -C src install

#a temporary target just for internal SRI use
internal: c
	$(MAKE) IOPBINDIR=${IOPBINDIR} -C src internal


clean:
	$(MAKE) -C src clean
	rm -rf build


package:
ifeq ($(IOP_VERSION_NO),)
	$(error IOP_VERSION_NO is undefined, hint: ls -la lib)
endif
	$(MAKE) -C src install IOPBINDIR="${PWD}/IOP-v$(IOP_VERSION_NO)"
	zip -r IOP-v$(IOP_VERSION_NO) IOP-v$(IOP_VERSION_NO)
