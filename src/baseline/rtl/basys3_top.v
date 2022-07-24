module basys3_top #(
  // To disable instantiation of entire user core
  parameter integer       USER_CORE_ENABLE    = 0
)
(
  /* 100MHz external clock */
  input   wire            clk_ext,

  /* Slider switches */
  input   wire  [15:0]    slider_sw,

  /* Pushbutton switches */
  input   wire  [4:0]     pushb_sw,

  /* PMOD interfaces */
  inout   wire  [7:0]     pmod_ja,
  inout   wire  [7:0]     pmod_jb,
  inout   wire  [7:0]     pmod_jc,
  inout   wire  [7:0]     pmod_jxadc,

  /* Flash SPI interface */
  output  wire            flash_mosi,
  input   wire            flash_miso,
  output  wire            flash_csn,
  output  wire            flash_wpn,
  output  wire            flash_hldn,

  /* VGA interface */
  output  wire  [3:0]     vga_red,
  output  wire  [3:0]     vga_green,
  output  wire  [3:0]     vga_blue,
  output  wire            vga_hsync,
  output  wire            vga_vsync,

  /* User LED */
  output  wire  [15:0]    user_led,

  /* Seven-segment (SSEG) display */
  output  wire  [6:0]     sseg_digit,
  output  wire            sseg_dp,
  output  wire  [3:0]     sseg_selectn,

  /* USB HID (PS/2) */
  output  wire            host_ps2_clk,
  input   wire            host_ps2_data,

  /* USB RS-232 interface */
  output  wire            uart_txd,
  input   wire            uart_rxd
);

  generate
    if (USER_CORE_ENABLE == 1) begin
    end else begin
    end
  endgenerate

endmodule

