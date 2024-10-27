SRC_DIR = ./
VHDL_FILES = $(wildcard $(SRC_DIR)/*.vhd)
BUILD_DIR = build

GHDL = ghdl

.PHONY: lint
lint:
	$(GHDL) -s --std=08 $(VHDL_FILES)

.PHONY: analyze
analyze: $(BUILD_DIR)
	$(GHDL) -a --std=08 $(VHDL_FILES)


.PHONY: clean
clean:
	rm -rf $(BUILD_DIR)/*.o
	rm -rf $(BUILD_DIR)/*.cf
	mkdir -pv $(BUILD_DIR)

