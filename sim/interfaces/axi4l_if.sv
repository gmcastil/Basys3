
interface axi4l_if #(
    parameter int   ADDR_WIDTH = 32,
    parameter int   DATA_WIDTH = 32
) (
    input   logic   axi4l_aclk,
    input   logic   axi4l_arstn
);

    // Write Address Channel
    logic [ADDR_WIDTH-1:0]      awaddr;
    logic                       awvalid;
    logic                       awready;

    // Write Data Channel
    logic [DATA_WIDTH-1:0]      wdata;
    logic [(DATA_WIDTH/8)-1:0]  wstrb;
    logic                       wvalid;
    logic                       wready;

    // Write Response Channel
    logic [1:0]                 bresp;
    logic                       bvalid;
    logic                       bready;

    // Read Address Channel
    logic [ADDR_WIDTH-1:0]      araddr;
    logic                       arvalid;
    logic                       arready;

    // Read Data Channel
    logic [DATA_WIDTH-1:0]      rdata;
    logic [1:0]                 rresp;
    logic                       rvalid;
    logic                       rready;

    // AXI4-Lite read and write response types
    typedef enum logic [1:0] {
        RESP_OKAY       = 2'b00,    // Transaction completed successfully
        RESP_EXOKAY     = 2'b01,    // Exclusvie access successful
        RESP_SLVERR     = 2'b10,    // Slave error
        RESP_DECERR     = 2'b11     // Decode error
    } axi4l_resp_t;

    // AXI4-Lite read and write transactions (use widths derived from the interface)
    typedef struct {
        logic [ADDR_WIDTH-1:0] waddr;
        logic [DATA_WIDTH-1:0] wdata;
        logic [(DATA_WIDTH/8)-1:0] wstrb;
        axi4l_resp_t bresp;
    } axi4l_write_t;
    
    typedef struct {
        logic [ADDR_WIDTH-1:0] raddr;
        logic [DATA_WIDTH-1:0] rdata;
        axi4l_resp_t rresp;
    } axi4l_read_t;

    clocking cb @(posedge axi4l_aclk);
        input   awready, wready, bvalid, arready, rvalid, rdata, bresp, rresp;
        output  awaddr, awvalid, wdata, wstrb, wvalid, bready, araddr, arvalid, rready;
    endclocking

    modport master (
        input   axi4l_aclk,
        input   axi4l_arstn,
        output  awaddr, awvalid, wdata, wstrb, wvalid, bready, araddr, arvalid, rready,
        input   awready, wready, bvalid, arready, rvalid, rdata, bresp, rresp
    );

    modport slave (
        input   axi4l_aclk,
        input   axi4l_arstn,
        input   awaddr, awvalid, wdata, wstrb, wvalid, bready, araddr, arvalid, rready,
        output  awready, wready, bvalid, arready, rvalid, rdata, bresp, rresp
    );

endinterface

