`include "baseline/include/constants.vh"
`include "baseline/include/debug.vh"

module basys3_io //#(
//)
(
  output  wire          clk_ext,
  input   wire          clk_ext_pad
);


  // Per UG471, IBUF and IBUFG primitives are the same.  Here we instantiate the
  // IBUF and the BUFG explicitly to make sure that the external clock is
  // clearly placed on the global clock network.  If we instantiate an IBUFG,
  // the synthesis tool will place an IBUF instead, throw up a warning, and in
  // the schematic, we will see an IBUF with a misleading name of IBUFG_clk_ext
  // or something of the sort.
  IBUF //#(
  //)
  IBUF_clk_ext (
    .I        (clk_ext_pad),
    .O        (clk_ext_bufg)
  );
  BUFG //#(
  //)
  BUFG_clk_ext (
    .I        (clk_ext_bufg),
    .O        (clk_ext)
  );

/*
  // Onboard VGA interface signals
  genvar i;
  generate
    for (i = 0; i < 4; i = i + 1) begin
      OBUF //#(
      //)
      OBUF_vga_red (
        .I        (vga_red[i]),
        .O        (vga_red_pad[i])
      );
  
      OBUF //#(
      //)
      OBUF_vga_green (
        .I        (vga_green[i]),
        .O        (vga_green_pad[i])
      );
  
      OBUF //#(
      //)
      OBUF_vga_blue (
        .I        (vga_blue[i]),
        .O        (vga_blue_pad[i])
      );
    end
  endgenerate

  OBUF //#(
  //)
  OBUF_hsync (
    .I          (vga_hsync),
    .O          (vga_hsync_pad)
  );

  OBUF //#(
  //)
  OBUF_vsync (
    .I          (vga_vsync),
    .O          (vga_vsync_pad)
  );

  // Onboard user LED signals
  generate
    for (i = 0; i < 16; i = i + 1) begin
      OBUF //#(
      //)
      (
        .I      (user_led[i]),
        .O      (user_led_pad[i])
      );
    end
  endgenerate
*/
endmodule

