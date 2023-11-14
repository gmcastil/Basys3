`define   GND   1'b0
`define   VCC   1'b1

`timescale 1ps / 1ps

module user_core //#(
//)
(
  input   wire          clk_ext,
  input   wire          rst_ext,
  inout   wire  [7:0]   pmod_ja
);

  reg   [1:0]           pmod_ja_r;

  // Something here about why there isn't a BUFG in the feedback loop
  wire    clk_fb;

//----------------------------------------------------------------------------
// User entered comments
//----------------------------------------------------------------------------
// None
//
//----------------------------------------------------------------------------
//  Output     Output      Phase    Duty Cycle   Pk-to-Pk     Phase
//   Clock     Freq (MHz)  (degrees)    (%)     Jitter (ps)  Error (ps)
//----------------------------------------------------------------------------
// clk_out1__236.25000______0.000______50.0______226.601____300.388
// clk_out2__21.47727______0.000______50.0______336.805____300.388
//
//----------------------------------------------------------------------------
// Input Clock   Freq (MHz)    Input Jitter (UI)
//----------------------------------------------------------------------------
// __primary_________100.000____________0.010
//

  wire    clk_236m25;
  wire    clk_21m48;
  wire    mmcm_locked;
  
  assign pmod_ja[0]   = pmod_ja_r[0];
  assign pmod_ja[1]   = pmod_ja_r[1];
  assign pmod_ja[2]   = mmcm_locked;
  assign pmod_ja[7:3] = 5'b0;

  always @(posedge clk_236m25) begin
    pmod_ja_r[0]  <= ~pmod_ja_r[0];
  end

  always @(posedge clk_21m48) begin
    pmod_ja_r[1]  <= ~pmod_ja_r[1];
  end

  MMCME2_ADV #(
    .BANDWIDTH            ("OPTIMIZED"),
    .CLKOUT4_CASCADE      ("FALSE"),
    .COMPENSATION         ("ZHOLD"),
    .STARTUP_WAIT         ("FALSE"),
    .DIVCLK_DIVIDE        (5),
    .CLKFBOUT_MULT_F      (47.250),
    .CLKFBOUT_PHASE       (0.000),
    .CLKFBOUT_USE_FINE_PS ("FALSE"),
    .CLKOUT0_DIVIDE_F     (4.000),
    .CLKOUT0_PHASE        (0.000),
    .CLKOUT0_DUTY_CYCLE   (0.500),
    .CLKOUT0_USE_FINE_PS  ("FALSE"),
    .CLKOUT1_DIVIDE       (44),
    .CLKOUT1_PHASE        (0.000),
    .CLKOUT1_DUTY_CYCLE   (0.500),
    .CLKOUT1_USE_FINE_PS  ("FALSE"),
    .CLKIN1_PERIOD        (10.000)
  )
  MMCME2_ADV_i0 (
    // Input clocks and clock select
    .CLKFBIN             (clk_fb),
    .CLKIN1              (clk_ext),
    .CLKIN2              (1'b0),
    .CLKINSEL            (1'b1),
    // Feedback and output clocks
    .CLKFBOUT            (clk_fb),
    .CLKFBOUTB           (),
    .CLKOUT0             (clk_236m25),
    .CLKOUT0B            (),
    .CLKOUT1             (clk_21m48),
    .CLKOUT1B            (),
    .CLKOUT2             (),
    .CLKOUT2B            (),
    .CLKOUT3             (),
    .CLKOUT3B            (),
    .CLKOUT4             (),
    .CLKOUT5             (),
    .CLKOUT6             (),
    // Dynamic reconfiguration port (DRP) is unused in this design
    .DADDR               (7'h0),
    .DCLK                (`GND),
    .DEN                 (`GND),
    .DI                  (16'h0),
    .DO                  (),
    .DRDY                (),
    .DWE                 (`GND),
    // Dynamic phase shift is unused in this design
    .PSCLK               (`GND),
    .PSEN                (`GND),
    .PSINCDEC            (`GND),
    .PSDONE              (),
    // Clock and reset status
    .LOCKED              (mmcm_locked),
    .CLKINSTOPPED        (),
    .CLKFBSTOPPED        (),
    .PWRDWN              (`GND),
    .RST                 (rst_ext)
  );

endmodule
