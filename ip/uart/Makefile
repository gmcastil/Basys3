RTL_DIR 	= ./rtl
VHDL_FILES 	= $(wildcard $(RTL_DIR)/*.vhd)
BUILD_DIR 	= build

GHDL 		= ghdl
CTAGS 		= ctags

.PHONY: lint
lint:
	$(GHDL) -s --std=08 $(VHDL_FILES)

.PHONY: analyze
analyze: $(BUILD_DIR)
	$(GHDL) -a --std=08 $(VHDL_FILES)

.PHONY: tags
tags:
	$(CTAGS) -o ctags.rtl -R ./rtl

.PHONY: clean
clean:
	rm -rf $(BUILD_DIR)/*.o
	rm -rf $(BUILD_DIR)/*.cf
	mkdir -pv $(BUILD_DIR)
	rm -f ctags.rtl

