.PHONY: all clean list force site

# Parallel OpenSCAD processes. Defaults to one per CPU; heavy models
# (the Boston lid) can exhaust RAM that way, so use e.g. `make JOBS=2`.
JOBS ?=
JOBS_FLAG = $(if $(JOBS),-j $(JOBS))

all:
	python3 tools/build.py $(JOBS_FLAG)

force:
	python3 tools/build.py --force $(JOBS_FLAG)

list:
	python3 tools/build.py --list

site: all
	python3 tools/site.py

clean:
	rm -rf build site
	find previews -name '*.png' -delete 2>/dev/null || true
