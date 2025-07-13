`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: NANOCHIP SOLUTIONS
// Engineer: VIJAY KUMAR AYINALA
//           [SoC/ASIC Design & Verification Engineer] 
// Create Date: 17.06.2025 17:21:37
// Design Name: AXI_AR_BUFFER 
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


module AR_Buffer_design #(
  parameter AR_FIFO_DEPTH = 16, 
  parameter ADDR_WIDTH = 32, 
  parameter BURST_TYPE = 2, 
  parameter BURST_LEN = 8, 
  parameter BEAT_SIZE = 3, 
  parameter ID = 5,
  parameter FIFO_WIDTH = ADDR_WIDTH + BURST_TYPE + BURST_LEN + BEAT_SIZE + ID )(
  
  input AR_fifo_write_clk,
  input AR_fifo_read_clk,
  input AR_fifo_rst,
  input AR_fifo_w_en,
  input AR_fifo_r_en,
  output logic AR_fifo_full,
  output logic AR_fifo_empty,
  
  input [ADDR_WIDTH -1:0]in_fifo_ARADDR,
  input [BURST_TYPE -1:0]in_fifo_ARBURST,
  input [BURST_LEN -1:0]in_fifo_ARLEN,
  input [BEAT_SIZE -1:0]in_fifo_ARSIZE,
  input [ID -1:0]in_fifo_ARID,
  input in_fifo_ARVALID,
  input in_fifo_ARREADY,
  
  output reg [ADDR_WIDTH -1:0]out_fifo_ARADDR,
  output reg [BURST_TYPE -1:0]out_fifo_ARBURST,
  output reg [BURST_LEN -1:0]out_fifo_ARLEN,
  output reg [BEAT_SIZE -1:0]out_fifo_ARSIZE,
  output reg [ID -1:0]out_fifo_ARID,
  output reg out_fifo_ARVALID,
  output reg out_fifo_ARREADY
);

  localparam ARID_WIDTH = ID;
  localparam ARADDR_WIDTH = ADDR_WIDTH;
  localparam ARBURST_WIDTH = BURST_TYPE;
  localparam ARLEN_WIDTH = BURST_LEN;
  localparam ARSIZE_WIDTH = BEAT_SIZE;
  
  localparam ID_LSB        = 0;
  localparam ID_MSB        = ID_LSB + ID - 1;

  localparam ARSIZE_LSB    = ID_MSB + 1;
  localparam ARSIZE_MSB    = ARSIZE_LSB + ARSIZE_WIDTH - 1;
    
  localparam ARLEN_LSB     = ARSIZE_MSB + 1;
  localparam ARLEN_MSB     = ARLEN_LSB + ARLEN_WIDTH - 1;
    
  localparam ARBURST_LSB   = ARLEN_MSB + 1;
  localparam ARBURST_MSB   = ARBURST_LSB + ARBURST_WIDTH - 1;
    
  localparam ARADDR_LSB    = ARBURST_MSB + 1;
  localparam ARADDR_MSB    = ARADDR_LSB + ARADDR_WIDTH - 1;
    
  localparam TOTAL_WIDTH   = ARADDR_MSB + 1;
  
  localparam PTR_WIDTH = $clog2(AR_FIFO_DEPTH);
  
  
  //Internal Registers in AR_FIFO_BUFFER
  reg [FIFO_WIDTH -1:0]FIFO_MEMORY[AR_FIFO_DEPTH -1:0];
  reg [PTR_WIDTH -1:0]FIFO_w_ptr = 0;
  reg [PTR_WIDTH -1:0]FIFO_r_ptr = 0;
  reg FIFO_is_almost_full;
  reg FIFO_is_almost_empty;
  
  assign out_fifo_ARREADY = ~ FIFO_is_almost_full;
  
  always@(posedge AR_fifo_write_clk)begin
    if(!AR_fifo_rst)begin
      FIFO_w_ptr <= 0;
    end
    else if(AR_fifo_w_en && !AR_fifo_full && in_fifo_ARVALID && out_fifo_ARREADY)begin
      FIFO_MEMORY[FIFO_w_ptr] <= {in_fifo_ARADDR, in_fifo_ARBURST, in_fifo_ARLEN, in_fifo_ARSIZE, in_fifo_ARID};
      FIFO_w_ptr <= (FIFO_w_ptr + 1) % AR_FIFO_DEPTH;
    end
  end

  always@(posedge AR_fifo_read_clk)begin
    if(!AR_fifo_rst)begin
      FIFO_r_ptr <= 0;
    end
    else if(AR_fifo_r_en && !AR_fifo_empty && in_fifo_ARREADY)begin
      out_fifo_ARADDR <= FIFO_MEMORY[FIFO_r_ptr][ARADDR_MSB : ARADDR_LSB];
      out_fifo_ARBURST <= FIFO_MEMORY[FIFO_r_ptr][ARBURST_MSB : ARBURST_LSB];
      out_fifo_ARLEN <= FIFO_MEMORY[FIFO_r_ptr][ARLEN_MSB : ARLEN_LSB];
      out_fifo_ARSIZE <= FIFO_MEMORY[FIFO_r_ptr][ARSIZE_MSB : ARSIZE_LSB];
      out_fifo_ARID <= FIFO_MEMORY[FIFO_r_ptr][ID_MSB : ID_LSB];
      FIFO_r_ptr <= (FIFO_r_ptr + 1) % AR_FIFO_DEPTH;
      $display("read transaction test -%h",out_fifo_ARADDR);
    end   
  end  
  
  always@(posedge AR_fifo_read_clk)begin
    if(!AR_fifo_rst)begin
      out_fifo_ARVALID <= 0;
    end
    else if (AR_fifo_r_en && !AR_fifo_empty && in_fifo_ARREADY)begin
      out_fifo_ARVALID <= 1;
    end
    else begin
      out_fifo_ARVALID <= 0;
    end
  end  
  
  assign AR_fifo_full = (FIFO_w_ptr + 1 == FIFO_r_ptr);
  assign AR_fifo_empty = (FIFO_w_ptr == FIFO_r_ptr);
  
  assign FIFO_is_almost_full = ((FIFO_w_ptr + 2) % AR_FIFO_DEPTH == FIFO_r_ptr);
  assign FIFO_is_almost_empty = ((FIFO_w_ptr - FIFO_r_ptr) <= 1);
  
endmodule
