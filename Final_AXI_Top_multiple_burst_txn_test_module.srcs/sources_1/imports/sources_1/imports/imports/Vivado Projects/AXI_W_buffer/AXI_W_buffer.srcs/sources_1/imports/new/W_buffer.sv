`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: NANOCHIP SOLUTIONS
// Engineer: VIJAY KUMAR AYINALA
// 
// Create Date: 02.05.2025 10:26:25
// Design Name: Write Buffer
// Module Name: W_Buffer
// Project Name: AXI - Compatible Memory Controller
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


module W_FIFO_design #(
  parameter FIFO_DEPTH = 256, 
  parameter DATA_WIDTH = 32,
  parameter STRB_WIDTH = DATA_WIDTH/8,
  parameter WLAST_WIDTH = 1,
  parameter PTR_WIDTH = $clog2(FIFO_DEPTH),
  parameter FIFO_WIDTH = DATA_WIDTH + STRB_WIDTH + WLAST_WIDTH )(
  
  input W_fifo_write_clk,
  input W_fifo_read_clk,
  input W_fifo_rst,
  input W_fifo_w_en,
  input W_fifo_r_en,
  output logic W_fifo_full,
  output logic W_fifo_empty,
  
  input [DATA_WIDTH -1:0]in_fifo_WDATA,
  input [STRB_WIDTH -1:0]in_fifo_WSTRB,
  input in_fifo_WLAST,
  input in_fifo_WVALID,
  input in_fifo_WREADY,
  
  output reg [DATA_WIDTH -1:0]out_fifo_WDATA,
  output reg [STRB_WIDTH -1:0]out_fifo_WSTRB,
  output reg out_fifo_WLAST,
  output reg out_fifo_WVALID,
  output reg out_fifo_WREADY,
  output wire [PTR_WIDTH -1:0] W_fifo_occupancy
);

  localparam WDATA_WIDTH = DATA_WIDTH ;
  localparam WSTRB_WIDTH = STRB_WIDTH ;

  localparam DATA_LSB = 0;
  localparam DATA_MSB = DATA_LSB + DATA_WIDTH - 1;

  localparam STRB_LSB = DATA_MSB + 1;
  localparam STRB_MSB = STRB_LSB + STRB_WIDTH - 1;

  localparam TOTAL_WIDTH   = STRB_MSB + 1;
  
  
  //Internal Registers in AW_FIFO_BUFFER
  reg [FIFO_WIDTH -1:0]FIFO_MEMORY[FIFO_DEPTH -1:0];
  reg [PTR_WIDTH -1:0]FIFO_w_ptr = 0;
  reg [PTR_WIDTH -1:0]FIFO_r_ptr = 0;
  reg FIFO_is_almost_full;
  reg FIFO_is_almost_empty;
  
  always@(posedge W_fifo_write_clk)begin
    if(!W_fifo_rst)begin
      FIFO_w_ptr <= 0;
    end
    else if(W_fifo_w_en && !W_fifo_full && in_fifo_WVALID && out_fifo_WREADY)begin
      FIFO_MEMORY[FIFO_w_ptr] <= {in_fifo_WLAST, in_fifo_WSTRB, in_fifo_WDATA};
      $display("Stored memory DATA -%h",FIFO_MEMORY[FIFO_w_ptr - 1]);
      FIFO_w_ptr <= (FIFO_w_ptr == FIFO_DEPTH - 1)? 0: FIFO_w_ptr + 1;
    end
  end

  reg r_en_d;

    always @(posedge W_fifo_read_clk or negedge W_fifo_rst) begin
      if (!W_fifo_rst) begin
        r_en_d <= 0;
      end else begin
        r_en_d <= W_fifo_r_en && !W_fifo_empty && in_fifo_WREADY;
      end
    end
    
    wire read_pulse = (W_fifo_r_en && !W_fifo_empty && in_fifo_WREADY) && !r_en_d;

    always @(posedge W_fifo_read_clk or negedge W_fifo_rst) begin
      if (!W_fifo_rst) begin
        FIFO_r_ptr <= 0;
        out_fifo_WVALID <= 0;
      end else if (read_pulse) begin
        out_fifo_WDATA <= FIFO_MEMORY[FIFO_r_ptr][DATA_MSB : DATA_LSB];
        out_fifo_WSTRB <= FIFO_MEMORY[FIFO_r_ptr][STRB_MSB : STRB_LSB];
        out_fifo_WLAST <= FIFO_MEMORY[FIFO_r_ptr][STRB_MSB + 1];
        FIFO_r_ptr <= (FIFO_r_ptr == FIFO_DEPTH - 1) ? 0 : FIFO_r_ptr + 1;
        out_fifo_WVALID <= 1'b1; // assert VALID only for one cycle
      end else begin
        out_fifo_WVALID <= 1'b0;
      end
    end

    

  
  
//  assign out_fifo_WVALID = (in_fifo_WREADY && W_fifo_r_en && (FIFO_r_ptr!=0)) ;
  assign W_fifo_full = ((FIFO_w_ptr + 1) % FIFO_DEPTH == FIFO_r_ptr);
  assign W_fifo_empty = (FIFO_w_ptr == FIFO_r_ptr);
  assign out_fifo_WREADY = ~FIFO_is_almost_full;
  
  assign FIFO_is_almost_full = ((FIFO_w_ptr + 2) % FIFO_DEPTH == FIFO_r_ptr);
  assign FIFO_is_almost_empty = ((FIFO_w_ptr - FIFO_r_ptr) <= 1);
  
  assign W_fifo_occupancy = FIFO_w_ptr;
  
endmodule
