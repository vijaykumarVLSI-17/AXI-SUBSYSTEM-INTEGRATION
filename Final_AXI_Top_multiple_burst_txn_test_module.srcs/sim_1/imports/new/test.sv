`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.06.2025 15:21:30
// Design Name: 
// Module Name: test
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_AXI_top_design;

  // Parameters
  localparam DATA_WIDTH      = 32;
  localparam STRB_WIDTH      = DATA_WIDTH / 8;
  localparam ADDR_WIDTH      = 32;
  localparam BURST_TYPE      = 2;
  localparam BURST_LEN       = 8;
  localparam BEAT_SIZE       = 3;
  localparam RESP_WIDTH      = 2;
  localparam ID_WIDTH        = 5;
  localparam WLAST_WIDTH     = 1;

  // Clock and reset
  reg clk, controller_clk;
  reg rst, controller_rst;

  // AXI master stimulus signals
  reg [ADDR_WIDTH-1:0] i_awaddr;
  reg [BURST_TYPE-1:0] i_awburst;
  reg [BURST_LEN-1:0]  i_awlen;
  reg [BEAT_SIZE-1:0]  i_awsize;
  reg [ID_WIDTH-1:0]   i_awid;
  reg                  i_awvalid;
  wire                 i_awready;
  reg                  controller_awready;

  reg [DATA_WIDTH-1:0] i_wdata;
  reg [STRB_WIDTH-1:0] i_wstrb;
  reg                  i_wlast;
  reg                  i_wvalid;
  wire                 i_wready;
  reg                  controller_wready;

  reg [RESP_WIDTH-1:0] i_bresp;
  reg [ID_WIDTH-1:0]   i_bid;
  reg                  i_bvalid;
  reg                  i_bready;

  reg [ADDR_WIDTH-1:0] i_araddr;
  reg [BURST_TYPE-1:0] i_arburst;
  reg [BURST_LEN-1:0]  i_arlen;
  reg [BEAT_SIZE-1:0]  i_arsize;
  reg [ID_WIDTH-1:0]   i_arid;
  reg                  i_arvalid;
  wire                 i_arready;
  reg                  controller_arready;

  reg [DATA_WIDTH-1:0] i_rdata;
  reg [ID_WIDTH-1:0]   i_rid;
  reg                  i_rlast;
  reg                  i_rvalid;
  reg                  i_rready;

  // DUT outputs
  wire [ADDR_WIDTH-1:0] o_awaddr;
  wire [BURST_TYPE-1:0] o_awburst;
  wire [BURST_LEN-1:0]  o_awlen;
  wire [BEAT_SIZE-1:0]  o_awsize;
  wire [ID_WIDTH-1:0]   o_awid;
  wire                  o_awvalid;
  wire                  o_awready;

  wire [DATA_WIDTH-1:0] o_wdata;
  wire [STRB_WIDTH-1:0] o_wstrb;
  wire                  o_wlast;
  wire                  o_wvalid;
  wire                  o_wready;

  wire [RESP_WIDTH-1:0] o_bresp;
  wire [ID_WIDTH-1:0]   o_bid;
  wire                  o_bvalid;
  wire                  o_bready;

  wire [ADDR_WIDTH-1:0] o_araddr;
  wire [BURST_TYPE-1:0] o_arburst;
  wire [BURST_LEN-1:0]  o_arlen;
  wire [BEAT_SIZE-1:0]  o_arsize;
  wire [ID_WIDTH-1:0]   o_arid;
  wire                  o_arvalid;
  wire                  o_arready;

  wire [DATA_WIDTH-1:0] o_rdata;
  wire [ID_WIDTH-1:0]   o_rid;
  wire                  o_rlast;
  wire                  o_rvalid;
  wire                  o_rready;
  integer i = 0;
  integer j = 0;
  integer k = 0;
  // Instantiate the DUT
  AXI_top_design DUT (
    .clk(clk),
    .controller_clk(controller_clk),
    .rst(rst),
    .controller_rst(controller_rst),
    .i_awaddr(i_awaddr),
    .i_awburst(i_awburst),
    .i_awlen(i_awlen),
    .i_awsize(i_awsize),
    .i_awid(i_awid),
    .i_awvalid(i_awvalid),
    .i_awready(i_awready),
    .controller_awready(controller_awready),
    .o_awaddr(o_awaddr),
    .o_awburst(o_awburst),
    .o_awlen(o_awlen),
    .o_awsize(o_awsize),
    .o_awid(o_awid),
    .o_awvalid(o_awvalid),
    .o_awready(o_awready),
    .i_wdata(i_wdata),
    .i_wstrb(i_wstrb),
    .i_wlast(i_wlast),
    .i_wvalid(i_wvalid),
    .i_wready(i_wready),
    .controller_wready(controller_wready),
    .o_wdata(o_wdata),
    .o_wstrb(o_wstrb),
    .o_wlast(o_wlast),
    .o_wvalid(o_wvalid),
    .o_wready(o_wready),
    .i_bresp(i_bresp),
    .i_bid(i_bid),
    .i_bvalid(i_bvalid),
    .i_bready(i_bready),
    .o_bresp(o_bresp),
    .o_bid(o_bid),
    .o_bvalid(o_bvalid),
    .o_bready(o_bready),
    .i_araddr(i_araddr),
    .i_arburst(i_arburst),
    .i_arlen(i_arlen),
    .i_arsize(i_arsize),
    .i_arid(i_arid),
    .i_arvalid(i_arvalid),
    .i_arready(i_arready),
    .o_araddr(o_araddr),
    .o_arburst(o_arburst),
    .o_arlen(o_arlen),
    .o_arsize(o_arsize),
    .o_arid(o_arid),
    .o_arvalid(o_arvalid),
    .o_arready(o_arready),
    .controller_arready(controller_arready),
    .i_rdata(i_rdata),
    .i_rid(i_rid),
    .i_rlast(i_rlast),
    .i_rvalid(i_rvalid),
    .i_rready(i_rready),
    .o_rdata(o_rdata),
    .o_rid(o_rid),
    .o_rlast(o_rlast),
    .o_rvalid(o_rvalid),
    .o_rready(o_rready)
  );

  // Clock generation
  initial begin
    clk = 1;
    controller_clk = 1;
    forever #5 clk = ~clk;
  end

  always #10 controller_clk = ~controller_clk;

  // Reset logic and stimulus
  initial begin
    rst = 0;
    controller_rst = 0;
    #50;
    rst = 1;
    controller_rst = 1;
    
    
    // TODO: Write/Read burst transaction sequences
    // Set AW channel
    i_awaddr  = 32'h0000_0001;
    i_awburst = 2'b01;
    i_awlen   = 8'd3;
    i_awsize  = 3'd2;
    i_awid    = 5'd1;
    i_awvalid = 1;
    controller_awready = 1;
    
    
//  end
//  initial begin
//    
    
    controller_wready = 1;
    i_wvalid = 1;
    
    i_rready = 1;
    i_bready = 1;
    
    while ( i <= i_awlen) begin
      $display("i value %b -",i);
      i_wdata = 32'hA5A5A5A5 + i;
      i_wstrb = 4'b1111;
      i_wlast = (i == i_awlen);
      i = i + 1;
      #20;
      i_awvalid = 0;
      
    end
    i_wvalid = 0;
    i_wlast  = 0;
    
    #70;
    // Set AW channel
    i_awaddr  = 32'h0000_0002;
    i_awburst = 2'b01;
    i_awlen   = 8'd4;
    i_awsize  = 3'd3;
    i_awid    = 5'd2;
    i_awvalid = 1;
    #40;
    @(posedge clk);
        i_awvalid = 0;
    
    #0;
//    controller_wready = 1;
    i_wvalid = 1;

    while ( j <= i_awlen) begin
      $display("j value %b -",j);
      i_wdata = 32'hA2A2A2A2 + j;
      i_wstrb = 4'b1111;
      i_wlast = (j == i_awlen);
      j = j + 1;
      #20; 
    end
    i_wvalid = 0;
    i_wlast = 0;
    
    #100;
    // Set AW channel
    i_awaddr  = 32'h0000_0003;
    i_awburst = 2'b01;
    i_awlen   = 8'd2;
    i_awsize  = 3'd3;
    i_awid    = 5'd3;
    i_awvalid = 1;
    #40;
    @(posedge clk);
        i_awvalid = 0;
    
    #0;
//    controller_wready = 1;
    i_wvalid = 1;

    while ( k <= i_awlen) begin
      $display("k value %b -",k);
      i_wdata = 32'h12345678 + k;
      i_wstrb = 4'b1111;
      i_wlast = (k == i_awlen);
      k = k + 1;
      #20; 
    end
    i_wvalid = 0;
    i_wlast = 0;
    
    
    
    #1200;
    // Set AR channel
    i_araddr  = 32'h0000_0001;
    i_arburst = 2'b01;
    i_arlen   = 8'd3;
    i_arsize  = 3'd2;
    i_arid    = 5'd1;
    i_arvalid = 1;
    controller_arready = 1;
    #20;
    @(posedge clk);
    i_arvalid = 0;
    
    #1400;
    // Set AR channel
    i_araddr  = 32'h0000_0002;
    i_arburst = 2'b01;
    i_arlen   = 8'd4;
    i_arsize  = 3'd3;
    i_arid    = 5'd2;
    i_arvalid = 1;
    controller_arready = 1;
    #20;
    @(posedge clk);
    i_arvalid = 0;
    
    #1600;
    // Set AR channel
    i_araddr  = 32'h0000_0003;
    i_arburst = 2'b01;
    i_arlen   = 8'd2;
    i_arsize  = 3'd3;
    i_arid    = 5'd3;
    i_arvalid = 1;
    controller_arready = 1;
    #20;
    @(posedge clk);
    i_arvalid = 0;
    
     $finish;
  end
  
  initial begin
    $monitor("TB: time=%0t i_wdata=%h I_in_WDATA=%h", $time, i_wdata, DUT.i_wdata);
  end
  initial begin
    #1000;
    if (i_wdata == 0)
    $display("? ERROR: i_wdata is not driven!");
  end



endmodule
