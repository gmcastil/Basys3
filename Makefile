CTAGS		= ctags

CTAGS_FLAGS	=
# Recursively generate tags and don't append to anything existing
CTAGS_FLAGS	+= -R --append=no

# Set up languages and extensions
CTAGS_FLAGS	+= --languages=SystemVerilog,VHDL,Verilog 
CTAGS_FLAGS	+= --langmap=Verilog:.v.vh
CTAGS_FLAGS	+= --langmap=SystemVerilog:.sv.svh
CTAGS_FLAGS	+= --langmap=VHDL:.vhd.vhdl

# Directories to exclude when creating a tags file. This prevents creating tags
# that reference Xilinx IP or project files 
CTAGS_EXCLUDE_DIRS =
CTAGS_EXCLUDE_DIRS += proj vendor .git doc
CTAGS_EXCLUDE_DIRS += src/baseline/ip

CTAGS_FLAGS	+= $(foreach dir,$(CTAGS_EXCLUDE_DIRS), --exclude=$(dir))

.PHONY: ctags
ctags:
	$(CTAGS) $(CTAGS_FLAGS) .

.PHONY: clean
clean:
	rm -f tags

