.PHONY: all clean list force site

all:
	python3 tools/build.py

force:
	python3 tools/build.py --force

list:
	python3 tools/build.py --list

site: all
	python3 tools/site.py

clean:
	rm -rf build site
	find previews -name '*.png' -delete 2>/dev/null || true
