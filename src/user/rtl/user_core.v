`define GND             1'b0
`define VCC             1'b1

`define ILA_NES_CLKS    1

`timescale 1ps / 1ps

module user_core //#(
//)
(
  input   wire          clk_ext,
  input   wire          rst_ext,
  inout   wire  [7:0]   pmod_ja,

  output  wire          clk_mst,
  output  wire          clk_en_ppu,
  output  wire          clk_en_cpu,

  output  wire          rst_mst,
  output  wire          rst_en_ppu,
  output  wire          rst_en_cpu
);

  localparam  CPU_CLK_DIV     = 12;
  localparam  PPU_CLK_DIV     = 5;

  // We desire to create a CPU and PPU clock that are each derived from the
  // master clock, itself defined as the 236.25MHz principal input clock divided
  // down by 11, or approximately 21.47727MHz.
  //
  // The CPU and PPU clocks are defined as that master clock divided by 12 and 4,
  // respectively (we constrain our discussion here to NTSC only - PAL had
  // different clock frequencies and relationships).  Further, as both the
  // CPU and PPU clocks are derived from the master clock, they require a fixed
  // relationship to each other that needs to be maintained. An additional
  // clock is also required in order to allow the SBC side of the dual-port BRAM
  // to be operated faster than, but also synchronous to, the CPU clock. This is
  // required since the CPU operates as if the RAM and ROM were asynchronous
  // devices and memory contents will be available by the next rising edge of the
  // CPU clock (i.e., writes from the CPU domain will be performed faster by the
  // RAM or ROM emulator). The natural candidate to perform this task is the
  // master clock
  //
  // Creating the CPU and PPU clocks can be a bit challenging for a couple of
  // reasons. Our desire 

  // To synthesize the clock enable signal for the CPU clock domain we divide
  // the master clock by 12. More accurately, we generate a single clock pulse in 
  // the master clock domain every 12 clocks. 

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
  wire    mmcm_locked;

  assign clk_en_cpu   = clk_en_cpu_q;
  assign clk_en_ppu   = clk_en_ppu_q;
  assign rst_en_cpu   = 1'b0;
  assign rst_en_ppu   = 1'b0;

  /* Debugging signals */
  assign pmod_ja[0]   = clk_en_cpu_q;
  assign pmod_ja[1]   = clk_en_ppu_q;
  assign pmod_ja[2]   = mmcm_locked;
  assign pmod_ja[7:3] = 5'b0;

  // Will add a (TYPE) flip flop stage after the shift register instance to ease
  // timing efforts
  reg             clk_en_cpu_q;
  reg             clk_en_ppu_q;

  // Signals for hooking up the two shift registers to the output clock from the
  // MMCM
  wire            srl_ppu_feedback;
  wire            srl_cpu_feedback;
  wire  [4:0]     srl_ppu_depth;
  wire  [4:0]     srl_cpu_depth;

  // nasty do not do this
  assign rst_mst = mmcm_locked;

  MMCME2_ADV #(
    .BANDWIDTH              ("OPTIMIZED"),
    .CLKOUT4_CASCADE        ("FALSE"),
    .COMPENSATION           ("ZHOLD"),
    .STARTUP_WAIT           ("FALSE"),
    .DIVCLK_DIVIDE          (5),
    .CLKFBOUT_MULT_F        (47.250),
    .CLKFBOUT_PHASE         (0.000),
    .CLKFBOUT_USE_FINE_PS   ("FALSE"),
    .CLKOUT0_DIVIDE_F       (4.000),
    .CLKOUT0_PHASE          (0.000),
    .CLKOUT0_DUTY_CYCLE     (0.500),
    .CLKOUT0_USE_FINE_PS    ("FALSE"),
    .CLKOUT1_DIVIDE         (44),
    .CLKOUT1_PHASE          (0.000),
    .CLKOUT1_DUTY_CYCLE     (0.500),
    .CLKOUT1_USE_FINE_PS    ("FALSE"),
    .CLKIN1_PERIOD          (10.000)
  )
  MMCME2_ADV_i0 (
    // Input clocks and clock select
    .CLKFBIN                (clk_fb),
    .CLKIN1                 (clk_ext),
    .CLKIN2                 (1'b0),
    .CLKINSEL               (1'b1),
    // Feedback and output clocks
    .CLKFBOUT               (clk_fb),
    .CLKFBOUTB              (),
    .CLKOUT0                (clk_236m25),
    .CLKOUT0B               (),
    .CLKOUT1                (clk_mst),
    .CLKOUT1B               (),
    .CLKOUT2                (),
    .CLKOUT2B               (),
    .CLKOUT3                (),
    .CLKOUT3B               (),
    .CLKOUT4                (),
    .CLKOUT5                (),
    .CLKOUT6                (),
    // Dynamic reconfiguration port (DRP) is unused in this design
    .DADDR                  (7'h0),
    .DCLK                   (`GND),
    .DEN                    (`GND),
    .DI                     (16'h0),
    .DO                     (),
    .DRDY                   (),
    .DWE                    (`GND),
    // Dynamic phase shift is unused in this design
    .PSCLK                  (`GND),
    .PSEN                   (`GND),
    .PSINCDEC               (`GND),
    .PSDONE                 (),
    // Clock and reset status
    .LOCKED                 (mmcm_locked),
    .CLKINSTOPPED           (),
    .CLKFBSTOPPED           (),
    .PWRDWN                 (`GND),
    .RST                    (rst_ext)
  );

  assign srl_cpu_depth = CPU_CLK_DIV - 1;
  assign srl_ppu_depth = PPU_CLK_DIV - 1;

  SRLC32E #(
    .IS_CLK_INVERTED    (0),
    .INIT               (32'h0000_0001)  
  ) 
  SRLC32E_cpu_clk (
    .Q                  (srl_cpu_feedback),
    .Q31                (),
    .A                  (srl_cpu_depth),
    .CE                 (rst_mst),
    .CLK                (clk_mst),
    .D                  (srl_cpu_feedback)
  );

  SRLC32E #(
    .IS_CLK_INVERTED    (0),
    .INIT               (32'h0000_0001)  
  ) 
  SRLC32E_ppu_clk (
    .Q                  (srl_ppu_feedback),
    .Q31                (),
    .A                  (srl_ppu_depth),
    .CE                 (rst_mst),
    .CLK                (clk_mst),
    .D                  (srl_ppu_feedback)
  );
  
  // Adding an extra registration stage to the output is done to improve
  // clock-to-out timing.
  always @(posedge clk_mst) begin
    clk_en_cpu_q      <= srl_cpu_feedback;
    clk_en_ppu_q      <= srl_ppu_feedback;
  end

  generate
    if (`ILA_NES_CLKS == 1) begin
      ila_nes_clks //#(
      //)
      ila_nes_clks_i0 (
        // The master clock should be running
        .clk          (clk_mst),
        // MMCM should lock very quickly
        .probe0       (mmcm_locked),
        .probe1       (1'b0),
        // PPU clock is a divide by 5
        .probe2       (clk_en_ppu),
        // CPU clock is a divide by 12
        .probe3       (clk_en_cpu),
        // Master reset derived from the MMCM locked
        .probe4       (rst_mst),
        // Reset synchronous to the PPU enable signal
        .probe5       (rst_en_ppu),
        // Reset synchronous to the CPU enable signal
        .probe6       (rst_en_cpu),
        // Output of SRL for the PPU and CPU enable signal generations
        .probe7       (srl_ppu_feedback),
        .probe8       (srl_cpu_feedback)
      );
    end
  endgenerate /* synthesis syn_keep=1 syn_preserve=1 syn_noprune=1 */;

endmodule
