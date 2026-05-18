.PHONY: all clean list force

all:
	python3 tools/build.py

force:
	python3 tools/build.py --force

list:
	python3 tools/build.py --list

clean:
	rm -rf build
	find previews -name '*.png' -delete 2>/dev/null || true
