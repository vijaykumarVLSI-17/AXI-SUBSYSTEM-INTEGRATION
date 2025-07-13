`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: NANOCHIP SOLUTIONS
// Engineer: VIJAY KUMAR AYINALA
//           [SoC/ASIC Design & Verification Engineer] 
// Create Date: 17.06.2025 17:21:37
// Design Name: AXI_top_Interconnect_to_Buffer_Controller
// Module Name: AR_Buffer_design
// Project Name: AXI-Compatible Memory Controller with 
//                  Integration of AXI-Lite Multi slave Interface Controller
// Target Devices: EMBEDDED SYSTEMS 
// Tool Versions: Vivado 2019.2
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module AXI_top_design #(
                         parameter DATA_WIDTH=32,
                         parameter STRB_WIDTH=(DATA_WIDTH/8), 
                         parameter ADDR_WIDTH=32, 
                         parameter BURST_TYPE=2, 
                         parameter BURST_LEN=8, 
                         parameter BEAT_SIZE=3, 
                         parameter RESP_WIDTH=2, 
                         parameter ID=5, 
                         parameter WLAST_WIDTH=1,
                         parameter AW_FIFO_DEPTH=16,
                         parameter AW_FIFO_WIDTH=ADDR_WIDTH + BURST_TYPE + BURST_LEN + BEAT_SIZE + ID,
                         parameter W_FIFO_DEPTH=32,
                         parameter W_FIFO_WIDTH=DATA_WIDTH + STRB_WIDTH + WLAST_WIDTH,
                         parameter AR_FIFO_DEPTH=16,
                         parameter AR_FIFO_WIDTH=ADDR_WIDTH + BURST_TYPE + BURST_LEN + BEAT_SIZE + ID,
                         parameter AW_PTR_WIDTH=$clog2(AW_FIFO_DEPTH),
                         parameter W_PTR_WIDTH=$clog2(W_FIFO_DEPTH),
                         parameter AR_PTR_WIDTH=$clog2(AR_FIFO_DEPTH),
                         parameter ECC_WIDTH=38,
                         parameter ECC_DEPTH=128,
                         parameter MEM_DEPTH=50,
                         parameter MEM_WIDTH=38,
                         
                         // Main AXI Slaves (Top-Level)
                         parameter BRAM_BASE_ADDR            = 32'h0000_0000,
                         parameter BRAM_ADDR_SIZE            = 32'h0001_0000, // 64 KB
                         parameter BRAM_END_ADDR = BRAM_BASE_ADDR + BRAM_ADDR_SIZE - 1,
                         
                         parameter SLAVE_CONTLR_BASE_ADDR = 32'h4000_0000,
                         parameter SLAVE_CONTLR_ADDR_SIZE = 32'h0001_0000, // 64 KB for all AXI-Lite peripherals
                         parameter SLAVE_CONTLR_END_ADDR = SLAVE_CONTLR_BASE_ADDR + SLAVE_CONTLR_ADDR_SIZE - 1,
                         
                        // AXI-Lite Peripherals (Inside AXI_SLAVE_CONTLR)
                         parameter SPI_BASE_ADDR              = 32'h4000_1000,
                         parameter SPI_ADDR_SIZE              = 32'h0000_1000, // 4 KB
                         parameter SPI_END_ADDR = SPI_BASE_ADDR + SPI_ADDR_SIZE - 1,
                         
                         parameter GPIO_BASE_ADDR             = 32'h4000_2000,
                         parameter GPIO_ADDR_SIZE             = 32'h0000_1000, // 4 KB
                         parameter GPIO_END_ADDR = GPIO_BASE_ADDR + GPIO_ADDR_SIZE - 1,
                            
                         parameter USB_BASE_ADDR              = 32'h4000_3000,
                         parameter USB_ADDR_SIZE              = 32'h0000_1000, // 4 KB
                         parameter USB_END_ADDR = USB_BASE_ADDR + USB_ADDR_SIZE - 1,
                         
                         parameter I2C_BASE_ADDR              = 32'h4000_4000,
                         parameter I2C_ADDR_SIZE              = 32'h0000_1000, // 4 KB
                         parameter I2C_END_ADDR = I2C_BASE_ADDR + I2C_ADDR_SIZE - 1,
    
                         parameter UART_BASE_ADDR             = 32'h4000_5000,
                         parameter UART_ADDR_SIZE             = 32'h0000_1000, // 4 KB
                         parameter UART_END_ADDR = UART_BASE_ADDR + UART_ADDR_SIZE - 1, 
                         
                        // Optional External Memory
                         parameter EXTERNAL_MEM_BASE_ADDR     = 32'hA000_0000,
                         parameter EXTERNAL_MEM_ADDR_SIZE     = 32'h0100_0000, // 16 MB
                         parameter EXTERNAL_MEM_END_ADDR = EXTERNAL_MEM_BASE_ADDR + EXTERNAL_MEM_ADDR_SIZE

                        )
    (
      input clk,
      input controller_clk,
      input rst,
      input controller_rst,
      
      input wire[ADDR_WIDTH -1:0]i_awaddr,
      input wire[BURST_TYPE -1:0]i_awburst,
      input wire[BURST_LEN  -1:0]i_awlen,
      input wire[BEAT_SIZE  -1:0]i_awsize,
      input wire[ID         -1:0]i_awid,
      input wire i_awvalid,
      input wire i_awready,
      input wire controller_awready,
      
      output reg [ADDR_WIDTH -1:0]o_awaddr,
      output reg [BURST_TYPE -1:0]o_awburst,
      output reg [BURST_LEN  -1:0]o_awlen,
      output reg [BEAT_SIZE  -1:0]o_awsize,
      output reg [ID         -1:0]o_awid,
      output reg o_awvalid,
      output reg o_awready,
      
      input wire[DATA_WIDTH -1:0]i_wdata,
      input wire[STRB_WIDTH -1:0]i_wstrb,
      input wire i_wlast,
      input wire i_wvalid,
      input wire i_wready,
      input wire controller_wready,
      
      output reg[DATA_WIDTH -1:0]o_wdata,
      output reg[STRB_WIDTH -1:0]o_wstrb,
      output reg o_wlast,
      output reg o_wvalid,
      output reg o_wready,
      
      
      input wire[RESP_WIDTH -1:0]i_bresp,
      input wire[ID         -1:0]i_bid,
      input wire i_bvalid,
      input wire i_bready,
      
      output reg[RESP_WIDTH -1:0]o_bresp,
      output reg[ID         -1:0]o_bid,
      output reg o_bvalid,
      output reg o_bready,
      
      input wire[ADDR_WIDTH -1:0]i_araddr,
      input wire[BURST_TYPE -1:0]i_arburst,
      input wire[BURST_LEN  -1:0]i_arlen,
      input wire[BEAT_SIZE  -1:0]i_arsize,
      input wire[ID         -1:0]i_arid,
      input wire i_arvalid,
      input wire i_arready,
      
      output reg [ADDR_WIDTH -1:0]o_araddr,
      output reg [BURST_TYPE -1:0]o_arburst,
      output reg [BURST_LEN  -1:0]o_arlen,
      output reg [BEAT_SIZE  -1:0]o_arsize,
      output reg [ID         -1:0]o_arid,
      output reg o_arvalid,
      output reg o_arready,
      input wire controller_arready,
      
      input wire[DATA_WIDTH -1:0]i_rdata,
      input wire[ID         -1:0]i_rid,
      input wire                 i_rlast,
      input wire i_rvalid,
      input wire i_rready,
      
      output reg[DATA_WIDTH -1:0]o_rdata,
      output reg[ID         -1:0]o_rid,
      output reg                 o_rlast,
      output reg o_rvalid,
      output reg o_rready

    );
    
    //AXI_INTERCONNECT SIGNAL PORTS 
    logic ACLK;
    logic ARESETn;
    
    // AXI MASTER to AXI INTERCONNECT i/p and o/p pins
    logic [ADDR_WIDTH-1:0] I_in_AWADDR;
    logic [BURST_TYPE -1:0]I_in_AWBURST;
    logic [BURST_LEN-1:0]  I_in_AWLEN;
    logic [BEAT_SIZE-1:0]  I_in_AWSIZE;
    logic [ID -1:0]        I_in_AWID;
    
    logic                  I_in_AWVALID;
    logic                  AXI4_in_AWREADY;
    logic                  AXI4_out_AWVALID;
    logic                  I_out_AWREADY;      //Interconnect o/p port AWREADY to Master
    
    // AXI Interconnect i/p & o/p pins to AXI4 INTERFACE 
    logic [ADDR_WIDTH-1:0] AXI4_out_AWADDR;  
    logic [BURST_TYPE -1:0]AXI4_out_AWBURST;
    logic [BURST_LEN-1:0]  AXI4_out_AWLEN;
    logic [BEAT_SIZE-1:0]  AXI4_out_AWSIZE;
    logic [ID -1:0]        AXI4_out_AWID;
    
    // AXI MASTER to AXI INTERCONNECT i/p pins
    logic [DATA_WIDTH-1:0]      I_in_WDATA;
    logic [(DATA_WIDTH/8) -1:0] I_in_WSTRB;
    logic                       I_in_WLAST;
    logic I_in_WVALID;
    logic I_out_WREADY;
    
    logic AXI4_in_WREADY;
    
    logic AXI4_out_WVALID;
    
    //AXI INTERCONNECT to AXI4 Interface signals
    logic[DATA_WIDTH-1:0]     AXI4_out_WDATA;
    logic[(DATA_WIDTH/8) -1:0]AXI4_out_WSTRB;
    logic                     AXI4_out_WLAST;
              
    
    logic [RESP_WIDTH -1:0] I_out_BRESP;
    logic [ID -1:0] I_out_BID;
    logic I_in_BREADY;
    logic I_out_BVALID;
    
    logic [RESP_WIDTH -1:0]AXI4_in_BRESP;
    logic [ID -1:0]  AXI4_in_BID;
    logic            AXI4_in_BVALID;
    logic AXI4_out_BREADY;
        
    logic [ADDR_WIDTH-1:0] I_in_ARADDR;
    logic [BURST_TYPE -1:0]I_in_ARBURST;
    logic [BURST_LEN-1:0]  I_in_ARLEN;
    logic [BEAT_SIZE-1:0]  I_in_ARSIZE;
    logic [ID -1:0]        I_in_ARID;
    
    logic                  I_in_ARVALID;
    logic                  AXI4_in_ARREADY;
    logic                  AXI4_out_ARVALID;
    logic                  I_out_ARREADY;      //Interconnect o/p port AWREADY to Master
    
    // AXI Interconnect i/p & o/p pins to AXI4 INTERFACE 
    logic [ADDR_WIDTH-1:0] AXI4_out_ARADDR;  
    logic [BURST_TYPE -1:0]AXI4_out_ARBURST;
    logic [BURST_LEN-1:0]  AXI4_out_ARLEN;
    logic [BEAT_SIZE-1:0]  AXI4_out_ARSIZE;
    logic [ID -1:0]        AXI4_out_ARID;
 
    logic [DATA_WIDTH-1:0] I_out_RDATA;
    logic [ID -1:0]I_out_RID;
    logic I_out_RLAST;
    logic I_in_RREADY;
    logic I_out_RVALID;
    
    logic [DATA_WIDTH -1:0]AXI4_in_RDATA;
    logic [ID -1:0]AXI4_in_RID;
    logic AXI4_in_RLAST;
    logic AXI4_out_RREADY;
    logic AXI4_in_RVALID;
    
    //AXI_AW_BUFFER signal ports
    logic AW_fifo_write_clk;
    logic AW_fifo_read_clk;
    logic AW_fifo_rst;
    logic AW_fifo_w_en;
    logic AW_fifo_r_en;
    logic  AW_fifo_full;
    logic  AW_fifo_empty;
  
    logic [ADDR_WIDTH -1:0]in_fifo_AWADDR;
    logic [BURST_TYPE -1:0]in_fifo_AWBURST;
    logic [BURST_LEN -1:0]in_fifo_AWLEN;
    logic [BEAT_SIZE -1:0]in_fifo_AWSIZE;
    logic [ID -1:0]in_fifo_AWID;
    logic in_fifo_AWVALID;
    logic in_fifo_AWREADY;
  
    logic [ADDR_WIDTH -1:0]out_fifo_AWADDR;
    logic [BURST_TYPE -1:0]out_fifo_AWBURST;
    logic [BURST_LEN -1:0]out_fifo_AWLEN;
    logic [BEAT_SIZE -1:0]out_fifo_AWSIZE;
    logic [ID -1:0]out_fifo_AWID;
    logic out_fifo_AWVALID;
    logic out_fifo_AWREADY;
    
    //AXI_W_BUFFER signal ports
    logic W_fifo_write_clk;
    logic W_fifo_read_clk;
    logic W_fifo_rst;
    logic W_fifo_w_en;
    logic W_fifo_r_en;
    logic  W_fifo_full;
    logic  W_fifo_empty;
  
    logic [DATA_WIDTH -1:0]in_fifo_WDATA;
    logic [STRB_WIDTH -1:0]in_fifo_WSTRB;
    logic in_fifo_WLAST;
    logic in_fifo_WVALID;
    logic in_fifo_WREADY;
  
    logic [DATA_WIDTH -1:0]out_fifo_WDATA;
    logic [STRB_WIDTH -1:0]out_fifo_WSTRB;
    logic out_fifo_WLAST;
    logic out_fifo_WVALID;
    logic out_fifo_WREADY;
    logic [BURST_LEN -1:0] W_fifo_occupancy;
    
    //AXI_AR_BUFFER signal ports
    logic AR_fifo_write_clk;
    logic AR_fifo_read_clk;
    logic AR_fifo_rst;
    logic AR_fifo_w_en;
    logic AR_fifo_r_en;
    logic  AR_fifo_full;
    logic  AR_fifo_empty;
  
    logic [ADDR_WIDTH -1:0]in_fifo_ARADDR;
    logic [BURST_TYPE -1:0]in_fifo_ARBURST;
    logic [BURST_LEN -1:0]in_fifo_ARLEN;
    logic [BEAT_SIZE -1:0]in_fifo_ARSIZE;
    logic [ID -1:0]in_fifo_ARID;
    logic in_fifo_ARVALID;
    logic in_fifo_ARREADY;
  
    logic [ADDR_WIDTH -1:0]out_fifo_ARADDR;
    logic [BURST_TYPE -1:0]out_fifo_ARBURST;
    logic [BURST_LEN -1:0]out_fifo_ARLEN;
    logic [BEAT_SIZE -1:0]out_fifo_ARSIZE;
    logic [ID -1:0]out_fifo_ARID;
    logic out_fifo_ARVALID;
    logic out_fifo_ARREADY;
    
    //AXI_BUFFER_CONTROLLER signal ports
    logic mem_contlr_CLK;
    logic mem_contlr_RST;
  
    logic AW_r_en;
    logic W_r_en;
    logic AR_r_en;
  
    logic[ADDR_WIDTH -1:0]AWADDR_mem_contlr_in;
    logic[BURST_TYPE -1:0]AWBURST_mem_contlr_in;
    logic[BURST_LEN -1:0]AWLEN_mem_contlr_in;
    logic[BEAT_SIZE -1:0]AWSIZE_mem_contlr_in;
    logic[ID -1:0]AWID_mem_contlr_in;
    logic AWVALID_mem_contlr_in;
    logic AWREADY_mem_contlr_in;
  
    logic AW_fifo_empty_in;
  
    logic[ADDR_WIDTH -1:0]AWADDR_mem_contlr_out;
    logic[BURST_TYPE -1:0]AWBURST_mem_contlr_out;
    logic[BURST_LEN -1:0]AWLEN_mem_contlr_out;
    logic[BEAT_SIZE -1:0]AWSIZE_mem_contlr_out;
    logic[ID -1:0]AWID_mem_contlr_out;
    logic AWVALID_mem_contlr_out;
    logic AWREADY_mem_contlr_out;
  
    logic[DATA_WIDTH -1:0]WDATA_mem_contlr_in;
    logic[STRB_WIDTH -1:0]WSTRB_mem_contlr_in;
    logic WLAST_mem_contlr_in;
    logic WVALID_mem_contlr_in;
    logic WREADY_mem_contlr_in;
  
    logic W_fifo_empty_in;
    logic [BURST_LEN -1:0]fifo_occupancy;
    
    logic[DATA_WIDTH -1:0]WDATA_mem_contlr_out;
    logic[STRB_WIDTH -1:0]WSTRB_mem_contlr_out;
    logic WLAST_mem_contlr_out;
    logic WVALID_mem_contlr_out;
    logic WREADY_mem_contlr_out;
    
    logic[RESP_WIDTH -1:0]BRESP_mem_contlr_out;
    logic[ID -1:0]BID_mem_contlr_out;
    logic BVALID_mem_contlr_out;
    logic BREADY_mem_contlr_in;
    
    logic[RESP_WIDTH -1:0]BRESP_mem_contlr_in;
    logic[ID -1:0]BID_mem_contlr_in;
    logic BVALID_mem_contlr_in;
    logic BREADY_mem_contlr_out;
    
    logic[ADDR_WIDTH -1:0]ARADDR_mem_contlr_in;
    logic[BURST_TYPE -1:0]ARBURST_mem_contlr_in;
    logic[BURST_LEN -1:0]ARLEN_mem_contlr_in;
    logic[BEAT_SIZE -1:0]ARSIZE_mem_contlr_in;
    logic[ID -1:0]ARID_mem_contlr_in;
    logic ARVALID_mem_contlr_in;
    logic ARREADY_mem_contlr_in;
    
    logic AR_fifo_empty_in;
    
    logic[ADDR_WIDTH -1:0]ARADDR_mem_contlr_out;
    logic[BURST_TYPE -1:0]ARBURST_mem_contlr_out;
    logic[BURST_LEN -1:0]ARLEN_mem_contlr_out;
    logic[BEAT_SIZE -1:0]ARSIZE_mem_contlr_out;
    logic[ID -1:0]ARID_mem_contlr_out;
    logic ARVALID_mem_contlr_out;
    logic ARREADY_mem_contlr_out;
    
    logic[DATA_WIDTH -1:0]RDATA_mem_contlr_in;
    logic[ID -1:0]RID_mem_contlr_in;
    logic RLAST_mem_contlr_in;
    logic RVALID_mem_contlr_in;
    logic RREADY_mem_contlr_in;
    
    logic[DATA_WIDTH -1:0]RDATA_mem_contlr_out;
    logic[ID -1:0]RID_mem_contlr_out;
    logic RLAST_mem_contlr_out;
    logic RVALID_mem_contlr_out;
    logic RREADY_mem_contlr_out;
    
    logic m_clk;
    logic m_rst;
    logic clka,clkb;
    logic enb,web;
    logic WA_valid;
    logic S_ready;
    logic bvalid_in;
    logic mem_full;
    logic o_WD_valid;
    logic t_ready;
    logic [DATA_WIDTH -1:0] data_in;
    logic [ADDR_WIDTH -1:0]addra,addrb;
    logic [(DATA_WIDTH/8)-1:0] W_strobe;
    logic [MEM_WIDTH -1:0] dinb;
    logic [DATA_WIDTH -1:0] data_out;
    logic DE_finish;
    
    wire [ADDR_WIDTH -1:0]addr;
    wire [BURST_TYPE -1:0]burst;
    wire [BURST_LEN -1:0]awlen;
    wire [BEAT_SIZE -1:0]awsize;
    wire [ID -1:0]awid;
    
    wire [ADDR_WIDTH -1:0]b_addr;
    wire [BURST_TYPE -1:0]b_burst;
    wire [BURST_LEN -1:0]b_awlen;
    wire [BEAT_SIZE -1:0]b_awsize;
    wire [ID -1:0]b_awid;
    wire b_aw_r_en;
    wire b_empty;
    wire contlr_awready;
    wire b_awvalid;
    wire b_wready;
    wire [DATA_WIDTH -1:0]data;
    wire [STRB_WIDTH -1:0]strobe;
    wire last;
    wire w_valid;
    wire [DATA_WIDTH -1:0]b_data;
    wire [STRB_WIDTH -1:0]b_strobe;
    wire b_last;
    wire b_wvalid;
    wire wready;
    wire w_empty;
    wire [BURST_LEN -1:0]occupancy;
    wire wread;
    wire bready;
    wire bvalid;
    wire [RESP_WIDTH -1:0]bresp;
    wire [ID -1:0]bid;
    wire [ADDR_WIDTH -1:0]r_addr;
    wire [BURST_TYPE -1:0]r_burst;
    wire [BURST_LEN -1:0]r_arlen;
    wire [BEAT_SIZE -1:0]r_arsize;
    wire [ID -1:0]r_arid;
    wire b_rready;
    wire rvalid;
    wire ar_empty;
    wire ar_en;
    wire ar_ready;
    wire [ADDR_WIDTH -1:0]ar_addr;
    wire [BURST_TYPE -1:0]ar_burst;
    wire [BURST_LEN -1:0]ar_arlen;
    wire [BEAT_SIZE -1:0]ar_arsize;
    wire [ID -1:0]ar_arid;
    wire arvalid;
    wire ready;
    wire valid;
    wire [DATA_WIDTH -1:0]re_data;
    wire [ID -1:0]rid;
    wire rlast;
    wire [DATA_WIDTH -1:0]o_data;
    wire [ID -1:0]o_id;
    wire o_last;
    wire ARVALID_out;
    wire WVALID_out;
    wire ECC_ready;
    wire ECC_r_ready;
    wire ECC_read_ready;
    wire [DATA_WIDTH -1:0]input_rdata;
    wire [DATA_WIDTH -1:0]ECC_data;
    wire [ADDR_WIDTH -1:0]AWADDR_out;
    wire [ADDR_WIDTH -1:0]ARADDR_out;
    wire [STRB_WIDTH -1:0]WSTRB_out;
    wire [MEM_WIDTH -1:0]wiire;
    wire decode;
    wire valid_decode;
    wire bvalid_;
    
    Interconnect_test_dsgn #(
                          .DATA_WIDTH(DATA_WIDTH),
                          .STRB_WIDTH(STRB_WIDTH),
                          .ADDR_WIDTH(ADDR_WIDTH), 
                          .BURST_TYPE(BURST_TYPE), 
                          .BURST_LEN(BURST_LEN), 
                          .BEAT_SIZE(BEAT_SIZE), 
                          .RESP_WIDTH(RESP_WIDTH), 
                          .ID(ID), 
                        
                          .BRAM_BASE_ADDR(BRAM_BASE_ADDR),          
                          .BRAM_ADDR_SIZE(BRAM_ADDR_SIZE),           
                          .BRAM_END_ADDR(BRAM_END_ADDR), 
                        
                          .SLAVE_CONTLR_BASE_ADDR(SLAVE_CONTLR_BASE_ADDR), 
                          .SLAVE_CONTLR_ADDR_SIZE(SLAVE_CONTLR_ADDR_SIZE), 
                          .SLAVE_CONTLR_END_ADDR(SLAVE_CONTLR_END_ADDR)
    )axi_interconnect(
     .ACLK(clk),
     .ARESETn(rst),
     
     .I_in_AWADDR(i_awaddr),
     .I_in_AWBURST(i_awburst),
     .I_in_AWLEN(i_awlen),
     .I_in_AWSIZE(i_awsize),
     .I_in_AWID(i_awid),
     .I_in_AWVALID(i_awvalid),
     .AXI4_in_AWREADY(out_fifo_AWREADY),
     .AXI4_out_AWVALID(in_fifo_AWVALID),
    
     .I_out_AWREADY(),    
    
     .AXI4_out_AWADDR(addr),  
     .AXI4_out_AWBURST(burst),
     .AXI4_out_AWLEN(awlen),
     .AXI4_out_AWSIZE(awsize),
     .AXI4_out_AWID(awid),

     .I_in_WDATA(i_wdata),
     .I_in_WSTRB(i_wstrb),
     .I_in_WLAST(i_wlast),
     .I_in_WVALID(i_wvalid),
     .I_out_WREADY(),
    
     .AXI4_in_WREADY(b_wready),
    
     .AXI4_out_WVALID(wvalid),
    
     .AXI4_out_WDATA(data),
     .AXI4_out_WSTRB(strobe),
     .AXI4_out_WLAST(last),

     .I_out_BRESP(),
     .I_out_BID(),
     .I_in_BREADY(i_bready),
     .I_out_BVALID(),
    
     .AXI4_in_BRESP(bresp),
     .AXI4_in_BID(bid),
     .AXI4_in_BVALID(bvalid),
     .AXI4_out_BREADY(bready),
 
     .I_in_ARADDR(i_araddr),
     .I_in_ARBURST(i_arburst),
     .I_in_ARLEN(i_arlen),
     .I_in_ARSIZE(i_arsize),
     .I_in_ARID(i_arid),
     .I_in_ARVALID(i_arvalid),
     .AXI4_in_ARREADY(b_rready),
     .AXI4_out_ARVALID(rvalid),
     .I_out_ARREADY(),     
    
     .AXI4_out_ARADDR(r_addr),  
     .AXI4_out_ARBURST(r_burst),
     .AXI4_out_ARLEN(r_arlen),
     .AXI4_out_ARSIZE(r_arsize),
     .AXI4_out_ARID(r_arid),

     .I_out_RDATA(),
     .I_out_RID(),
     .I_out_RLAST(),
     .I_in_RREADY(i_rready),
     .I_out_RVALID(),
    
     .AXI4_in_RDATA(re_data),
     .AXI4_in_RID(rid),
     .AXI4_in_RLAST(rlast),
     .AXI4_out_RREADY(ready),
     .AXI4_in_RVALID(valid)
     
 );
 
  
 AW_FIFO_design #(
                 .FIFO_DEPTH(AW_FIFO_DEPTH),  
                 .ADDR_WIDTH(ADDR_WIDTH),
                 .BURST_TYPE(BURST_TYPE),
                 .BURST_LEN(BURST_LEN), 
                 .BEAT_SIZE(BEAT_SIZE),  
                 .ID(ID),
                 .FIFO_WIDTH (AW_FIFO_WIDTH)
 )aw_buffer(
  
   .AW_fifo_write_clk(ACLK),
   .AW_fifo_read_clk(controller_clk),
   .AW_fifo_rst(ARESETn),
   .AW_fifo_w_en(AXI4_out_AWVALID),
   .AW_fifo_r_en(b_aw_r_en),
//   .AW_fifo_full(),
   .AW_fifo_empty(b_empty),
  
   .in_fifo_AWADDR(addr),
   .in_fifo_AWBURST(burst),
   .in_fifo_AWLEN(awlen),
   .in_fifo_AWSIZE(awsize),
   .in_fifo_AWID(awid),
   .in_fifo_AWVALID(AXI4_out_AWVALID),
   .in_fifo_AWREADY(contlr_awready),
  
   .out_fifo_AWADDR(b_addr),
   .out_fifo_AWBURST(b_burst),
   .out_fifo_AWLEN(b_awlen),
   .out_fifo_AWSIZE(b_awsize),
   .out_fifo_AWID(b_awid),
   .out_fifo_AWVALID(b_awvalid),
   .out_fifo_AWREADY(AXI4_in_AWREADY)
   
 );
 
 W_FIFO_design #(
                   .FIFO_DEPTH(W_FIFO_DEPTH) , 
                   .DATA_WIDTH(DATA_WIDTH),
                   .STRB_WIDTH(STRB_WIDTH),
                   .PTR_WIDTH(W_PTR_WIDTH),
                   .FIFO_WIDTH(W_FIFO_WIDTH) 
 )w_buffer(
  
   .W_fifo_write_clk(ACLK),
   .W_fifo_read_clk(controller_clk),
   .W_fifo_rst(ARESETn),
   .W_fifo_w_en(wvalid),
   .W_fifo_r_en(wread),
//   .W_fifo_full(),
   .W_fifo_empty(w_empty),
  
   .in_fifo_WDATA(data),
   .in_fifo_WSTRB(strobe),
   .in_fifo_WLAST(last),
   .in_fifo_WVALID(wvalid),
   .in_fifo_WREADY(wready),
  
   .out_fifo_WDATA(b_data),
   .out_fifo_WSTRB(b_strobe),
   .out_fifo_WLAST(b_last),
   .out_fifo_WVALID(w_valid),
   .out_fifo_WREADY(b_wready),
   .W_fifo_occupancy(occupancy)
);     

AR_Buffer_design #(
                 .AR_FIFO_DEPTH(AR_FIFO_DEPTH) , 
                 .ADDR_WIDTH(ADDR_WIDTH), 
                 .BURST_TYPE(BURST_TYPE), 
                 .BURST_LEN(BURST_LEN), 
                 .BEAT_SIZE(BEAT_SIZE), 
                 .ID(ID),
                 .FIFO_WIDTH(AR_FIFO_WIDTH)
)ar_buffer(
  
   .AR_fifo_write_clk(ACLK),
   .AR_fifo_read_clk(controller_clk),
   .AR_fifo_rst(ARESETn),
   .AR_fifo_w_en(rvalid),
   .AR_fifo_r_en(ar_en),
//   .AR_fifo_full(),
   .AR_fifo_empty(ar_empty),
  
   .in_fifo_ARADDR(r_addr),
   .in_fifo_ARBURST(r_burst),
   .in_fifo_ARLEN(r_arlen),
   .in_fifo_ARSIZE(r_arsize),
   .in_fifo_ARID(r_arid),
   .in_fifo_ARVALID(rvalid),
   .in_fifo_ARREADY(ar_ready),
  
   .out_fifo_ARADDR(ar_addr),
   .out_fifo_ARBURST(ar_burst),
   .out_fifo_ARLEN(ar_arlen),
   .out_fifo_ARSIZE(ar_arsize),
   .out_fifo_ARID(ar_arid),
   .out_fifo_ARVALID(arvalid),
   .out_fifo_ARREADY(b_rready)
);    
wire temp;
AXI_Memory_Controller #(
                             .ADDR_WIDTH(ADDR_WIDTH),
                             .DATA_WIDTH(DATA_WIDTH),
                             .STRB_WIDTH(STRB_WIDTH),
                             .BURST_TYPE(BURST_TYPE),
                             .BURST_LEN(BURST_LEN),
                             .BEAT_SIZE(BEAT_SIZE),
                             .ID(ID),
                             .RESP_WIDTH(RESP_WIDTH)
)buffer_controller(
  
    .mem_contlr_CLK(controller_clk),
    .mem_contlr_RST(controller_rst),
  
    .AW_r_en(b_aw_r_en),
    .W_r_en(wread),
    .AR_r_en(ar_en),
  
   .AWADDR_mem_contlr_in(b_addr),
   .AWBURST_mem_contlr_in(b_burst),
   .AWLEN_mem_contlr_in(b_awlen),
   .AWSIZE_mem_contlr_in(b_awsize),
   .AWID_mem_contlr_in(b_awid),
   .AWVALID_mem_contlr_in(b_awvalid),
   .AWREADY_mem_contlr_in(WVALID_out),
  
   .AW_fifo_empty_in(b_empty),
  
   .AWADDR_mem_contlr_out(AWADDR_out),
   .AWBURST_mem_contlr_out(o_awburst),
   .AWLEN_mem_contlr_out(o_awlen),
   .AWSIZE_mem_contlr_out(o_awsize),
   .AWID_mem_contlr_out(o_awid),
   .AWVALID_mem_contlr_out(temp),
   .AWREADY_mem_contlr_out(contlr_awready),
  
   .WDATA_mem_contlr_in(b_data),
   .WSTRB_mem_contlr_in(b_strobe),
   .WLAST_mem_contlr_in(b_last),
   .WVALID_mem_contlr_in(w_valid),
   .WREADY_mem_contlr_in(temp),
  
   .W_fifo_empty_in(w_empty),
   .fifo_occupancy(occupancy),
  
   .WDATA_mem_contlr_out(ECC_data),
   .WSTRB_mem_contlr_out(WSTRB_out),
   .WLAST_mem_contlr_out(o_wlast),
   .WVALID_mem_contlr_out(WVALID_out),
   .WREADY_mem_contlr_out(wready),
  
   .BRESP_mem_contlr_out(bresp),
   .BID_mem_contlr_out(bid),
   .BVALID_mem_contlr_out(bvalid),
   .BREADY_mem_contlr_in(bready),
  
   .BRESP_mem_contlr_in(i_bresp),
   .BID_mem_contlr_in(i_bid),
   .BVALID_mem_contlr_in(bvalid_),
   .BREADY_mem_contlr_out(),
  
   .ARADDR_mem_contlr_in(ar_addr),
   .ARBURST_mem_contlr_in(ar_burst),
   .ARLEN_mem_contlr_in(ar_arlen),
   .ARSIZE_mem_contlr_in(ar_arsize),
   .ARID_mem_contlr_in(ar_arid),
   .ARVALID_mem_contlr_in(arvalid),
   .ARREADY_mem_contlr_in(ECC_r_ready),
  
   .AR_fifo_empty_in(ar_empty),
   .ECC_DE_complete(decode),
   
   .ARADDR_mem_contlr_out(ARADDR_out),
   .ARBURST_mem_contlr_out(o_arburst),
   .ARLEN_mem_contlr_out(o_arlen),
   .ARSIZE_mem_contlr_out(o_arsize),
   .ARID_mem_contlr_out(o_arid),
   .ARVALID_mem_contlr_out(ARVALID_out),
   .ARREADY_mem_contlr_out(ar_ready),
  
   .RDATA_mem_contlr_in(input_rdata),
   .RID_mem_contlr_in(i_rid),
   .RLAST_mem_contlr_in(i_rlast),
   .RVALID_mem_contlr_in(valid_decode),
   .RREADY_mem_contlr_in(ready),
  
   .RDATA_mem_contlr_out(re_data),
   .RID_mem_contlr_out(rid),
   .RLAST_mem_contlr_out(rlast),
   .RVALID_mem_contlr_out(valid),
   .RREADY_mem_contlr_out(ECC_read_ready)
  
);   

wire w_WA_VALID;
assign w_WA_VALID = (WVALID_out && temp);
TOP_ECC_BRAM #(
               .ADDR_WIDTH(ADDR_WIDTH),
               .DATA_WIDTH(DATA_WIDTH),
               .MEM_WIDTH(MEM_WIDTH),
               .MEM_DEPTH(MEM_DEPTH)
)top_ecc_bram(
    .m_clk(controller_clk),
    .m_rst(controller_rst),
    .clka(controller_clk),
    .clkb(controller_clk),
    .enb(ARVALID_out),
    .web(!ARVALID_out),
    .WA_valid(w_WA_VALID),
    .S_ready(ECC_read_ready),
    .bvalid_in(bvalid_),
    .mem_full(ECC_ready),
    .o_WD_valid(valid_decode),
    .DE_finish(decode),
    .t_ready(ECC_r_ready),
    .data_in(ECC_data),
    .addra(AWADDR_out),
    .addrb(ARADDR_out),
    .W_strobe(WSTRB_out),
    .dinb(wiire),
    .data_out(input_rdata)
);

      
assign ACLK    = clk;
assign ARESETn = rst;
assign AXI4_out_AWVALID = in_fifo_AWVALID;
assign out_fifo_AWREADY = AXI4_in_AWREADY;
assign in_fifo_AWREADY = AXI4_out_AWADDR;
endmodule
