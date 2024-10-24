
CTAGS=ctags

CTAGS_FLAGS=
# Recursively generate tags
CTAGS_FLAGS+=-R
#
CTAGS_FLAGS+=--languages=SystemVerilog,VHDL,Verilog 
CTAGS_FLAGS+=--langmap=Verilog:.v.vh
CTAGS_FLAGS+=--langmap=SystemVerilog:.sv.svh
CTAGS_FLAGS+=--langmap=VHDL:.vhd.vhdl

# Define the target for ctags
ctags:
	$(CTAGS) $(CTAGS_FLAGS) .

# Optional: Clean the tags file
clean:
	rm -f tags

.PHONY: ctags clean
