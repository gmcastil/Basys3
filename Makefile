CTAGS=ctags

CTAGS_FLAGS=
# Recursively generate tags and don't append to anything existing
CTAGS_FLAGS+=-R --append=no
# Set up languages and extensions
CTAGS_FLAGS+=--languages=SystemVerilog,VHDL,Verilog 
CTAGS_FLAGS+=--langmap=Verilog:.v.vh
CTAGS_FLAGS+=--langmap=SystemVerilog:.sv.svh
CTAGS_FLAGS+=--langmap=VHDL:.vhd.vhdl

# Directories to exclude when creating a tags file. This prevents creating tags
# that reference Xilinx IP or project files 
CTAGS_EXCLUDE_DIRS=proj vendor .git doc

# Now we add them 
CTAGS_FLAGS+=$(foreach dir,$(CTAGS_EXCLUDE_DIRS), --exclude=$(dir))

# Define the target for ctags
.PHONY: ctags
ctags:
	$(CTAGS) $(CTAGS_FLAGS) .

# Optional: Clean the tags file
.PHONY: clean
clean:
	rm -f tags

