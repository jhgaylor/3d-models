OPENSCAD ?= $(shell command -v openscad 2>/dev/null || ls /Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD 2>/dev/null || echo openscad)
SRC_DIR  := src
BUILD    := build

SCAD_FILES := $(shell find $(SRC_DIR) -name '*.scad')
STL_FILES  := $(patsubst $(SRC_DIR)/%.scad,$(BUILD)/%.stl,$(SCAD_FILES))

.PHONY: all clean list
all: $(STL_FILES)

$(BUILD)/%.stl: $(SRC_DIR)/%.scad
	@mkdir -p $(dir $@)
	$(OPENSCAD) -o $@ $<

list:
	@echo "Source files:"
	@printf '  %s\n' $(SCAD_FILES)
	@echo "Outputs:"
	@printf '  %s\n' $(STL_FILES)

clean:
	rm -rf $(BUILD)
