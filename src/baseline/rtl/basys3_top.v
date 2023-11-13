`include "baseline/include/constants.vh"
`include "baseline/include/debug.vh"

module basys3_top // #(
// )
(
  /* 100MHz external clock */
  input   wire            clk_ext_pad,

  /* Slider switches */
  // input   wire  [15:0]    slider_sw_pad,

  /* Pushbutton switches */
  // input   wire  [4:0]     pushb_sw_pad,

  /* PMOD interfaces */
  inout   wire  [7:0]     pmod_ja_pad
  // inout   wire  [7:0]     pmod_jb_pad,
  // inout   wire  [7:0]     pmod_jc_pad,
  // inout   wire  [7:0]     pmod_jxadc_pad,

  /* Flash SPI interface */
  // output  wire            flash_mosi,
  // input   wire            flash_miso,
  // output  wire            flash_csn,
  // output  wire            flash_wpn,
  // output  wire            flash_hldn,

  /* VGA interface */
  // output  wire  [3:0]     vga_red_pad,
  // output  wire  [3:0]     vga_green_pad,
  // output  wire  [3:0]     vga_blue_pad,
  // output  wire            vga_hsync_pad,
  // output  wire            vga_vsync_pad,

  /* User LED */
  // output  wire  [15:0]    user_led_pad

  /* Seven-segment (SSEG) display */
  // output  wire  [6:0]     sseg_digit_pad,
  // output  wire            sseg_dp_pad,
  // output  wire  [3:0]     sseg_selectn_pad,

  /* USB HID (PS/2) */
  // output  wire            host_ps2_clk_pad,
  // input   wire            host_ps2_data_pad,

  /* USB RS-232 interface */
  // output  wire            uart_txd_pad,
  // input   wire            uart_rxd_pad
);

  // IO ring to top level connections
  wire              clk_ext;
  wire    [7:0]     pmod_ja;

  basys3_io //#(
  //)
  basys3_io_i0 (
    .clk_ext          (clk_ext),        // output wire
    .clk_ext_pad      (clk_ext_pad)     // input  wire
  );

  user_io //#(
  //)
  user_io_i0 (
    .pmod_ja          (pmod_ja),
    .pmod_ja_pad      (pmod_ja_pad)
  );

  user_core //#(
  //)
  user_core_i0 (
    .clk_ext        (clk_ext),
    .pmod_ja        (pmod_ja)
  );

endmodule

