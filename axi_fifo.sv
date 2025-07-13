`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: NANOCHIP SOLUTIONS
// Engineer: VIJAY KUMAR AYINALA (SoC/ASIC Design & Verification)
// 
// Create Date: 24.04.2025 12:21:08
// Design Name: FIFO Buffer design test    
// Module Name: AW_FIFO_design
// Project Name: AXI Compatible Memory Controller
// Target Devices: Embedded Systems
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


module AW_FIFO_design #(
  parameter FIFO_DEPTH = 16, 
  parameter ADDR_WIDTH = 32, 
  parameter BURST_TYPE = 2, 
  parameter BURST_LEN = 8, 
  parameter BEAT_SIZE = 3, 
  parameter ID = 5,
  parameter FIFO_WIDTH = ADDR_WIDTH + BURST_TYPE + BURST_LEN + BEAT_SIZE + ID )(
  
  input AW_fifo_write_clk,
  input AW_fifo_read_clk,
  input AW_fifo_rst,
  input AW_fifo_w_en,
  input AW_fifo_r_en,
  output logic AW_fifo_full,
  output logic AW_fifo_empty,
  
  input [ADDR_WIDTH -1:0]in_fifo_AWADDR,
  input [BURST_TYPE -1:0]in_fifo_AWBURST,
  input [BURST_LEN -1:0]in_fifo_AWLEN,
  input [BEAT_SIZE -1:0]in_fifo_AWSIZE,
  input [ID -1:0]in_fifo_AWID,
  input in_fifo_AWVALID,
  input in_fifo_AWREADY,
  
  output reg [ADDR_WIDTH -1:0]out_fifo_AWADDR,
  output reg [BURST_TYPE -1:0]out_fifo_AWBURST,
  output reg [BURST_LEN -1:0]out_fifo_AWLEN,
  output reg [BEAT_SIZE -1:0]out_fifo_AWSIZE,
  output reg [ID -1:0]out_fifo_AWID,
  output reg out_fifo_AWVALID,
  output reg out_fifo_AWREADY
);

  localparam AWID_WIDTH = ID;
  localparam AWADDR_WIDTH = ADDR_WIDTH;
  localparam AWBURST_WIDTH = BURST_TYPE;
  localparam AWLEN_WIDTH = BURST_LEN;
  localparam AWSIZE_WIDTH = BEAT_SIZE;
  
  localparam ID_LSB        = 0;
  localparam ID_MSB        = ID_LSB + ID - 1;

  localparam AWSIZE_LSB    = ID_MSB + 1;
  localparam AWSIZE_MSB    = AWSIZE_LSB + AWSIZE_WIDTH - 1;
    
  localparam AWLEN_LSB     = AWSIZE_MSB + 1;
  localparam AWLEN_MSB     = AWLEN_LSB + AWLEN_WIDTH - 1;
    
  localparam AWBURST_LSB   = AWLEN_MSB + 1;
  localparam AWBURST_MSB   = AWBURST_LSB + AWBURST_WIDTH - 1;
    
  localparam AWADDR_LSB    = AWBURST_MSB + 1;
  localparam AWADDR_MSB    = AWADDR_LSB + AWADDR_WIDTH - 1;
    
  localparam TOTAL_WIDTH   = AWADDR_MSB + 1;
  
  localparam PTR_WIDTH = $clog2(FIFO_DEPTH);
  
  
  //Internal Registers in AW_FIFO_BUFFER
  reg [FIFO_WIDTH -1:0]FIFO_MEMORY[FIFO_DEPTH -1:0];
  reg [PTR_WIDTH -1:0]FIFO_w_ptr = 0;
  reg [PTR_WIDTH -1:0]FIFO_r_ptr = 0;
  reg FIFO_is_almost_full;
  reg FIFO_is_almost_empty;
  reg state;
  localparam IDLE = 0;
  localparam DATA = 1;
  
  assign out_fifo_AWREADY = ~ FIFO_is_almost_full;
  
  always@(posedge AW_fifo_write_clk)begin
    if(!AW_fifo_rst)begin
      FIFO_w_ptr <= 0;
    end
    else if(AW_fifo_w_en && !AW_fifo_full && in_fifo_AWVALID && out_fifo_AWREADY)begin
      FIFO_MEMORY[FIFO_w_ptr] <= {in_fifo_AWADDR, in_fifo_AWBURST, in_fifo_AWLEN, in_fifo_AWSIZE, in_fifo_AWID};
      FIFO_w_ptr <= (FIFO_w_ptr + 1) % FIFO_DEPTH;
    end
  end

  always@(posedge AW_fifo_read_clk)begin
    if(!AW_fifo_rst)begin
      FIFO_r_ptr <= 0;
      state <=0;
    end
    else begin
      case(state)
        IDLE:begin
          if(AW_fifo_r_en)begin
            state <= DATA;
          end
          else begin
            state <= IDLE;
          end
        end
        
        DATA:begin
            out_fifo_AWADDR <= FIFO_MEMORY[FIFO_r_ptr][AWADDR_MSB : AWADDR_LSB];
            out_fifo_AWBURST <= FIFO_MEMORY[FIFO_r_ptr][AWBURST_MSB : AWBURST_LSB];
            out_fifo_AWLEN <= FIFO_MEMORY[FIFO_r_ptr][AWLEN_MSB : AWLEN_LSB];
            out_fifo_AWSIZE <= FIFO_MEMORY[FIFO_r_ptr][AWSIZE_MSB : AWSIZE_LSB];
            out_fifo_AWID <= FIFO_MEMORY[FIFO_r_ptr][ID_MSB : ID_LSB];
            FIFO_r_ptr <= (FIFO_r_ptr + 1) % FIFO_DEPTH;
          if(!AW_fifo_empty && in_fifo_AWREADY)begin
            
            state <= IDLE;
          end
          else begin
            state <= DATA;
          end
        end
      endcase
    end
//    else if(AW_fifo_r_en && !AW_fifo_empty && in_fifo_AWREADY)begin
//      out_fifo_AWADDR <= FIFO_MEMORY[FIFO_r_ptr][AWADDR_MSB : AWADDR_LSB];
//      out_fifo_AWBURST <= FIFO_MEMORY[FIFO_r_ptr][AWBURST_MSB : AWBURST_LSB];
//      out_fifo_AWLEN <= FIFO_MEMORY[FIFO_r_ptr][AWLEN_MSB : AWLEN_LSB];
//      out_fifo_AWSIZE <= FIFO_MEMORY[FIFO_r_ptr][AWSIZE_MSB : AWSIZE_LSB];
//      out_fifo_AWID <= FIFO_MEMORY[FIFO_r_ptr][ID_MSB : ID_LSB];
//      FIFO_r_ptr <= (FIFO_r_ptr + 1) % FIFO_DEPTH;
//      $display("read transaction test -%h",out_fifo_AWADDR);
//    end   
  end  
  
  always@(posedge AW_fifo_read_clk)begin
    if(!AW_fifo_rst)begin
      out_fifo_AWVALID <= 0;
    end
    else if (state == DATA)begin
      out_fifo_AWVALID <= 1;
    end
    else begin
      out_fifo_AWVALID <= 0;
    end
  end  
  
  assign AW_fifo_full = (FIFO_w_ptr + 1 == FIFO_r_ptr);
  assign AW_fifo_empty = (FIFO_w_ptr == FIFO_r_ptr);
//  assign out_fifo_AWVALID = (state == DATA);
  assign FIFO_is_almost_full = ((FIFO_w_ptr + 2) % FIFO_DEPTH == FIFO_r_ptr);
  assign FIFO_is_almost_empty = ((FIFO_w_ptr - FIFO_r_ptr) <= 1);
  
endmodule