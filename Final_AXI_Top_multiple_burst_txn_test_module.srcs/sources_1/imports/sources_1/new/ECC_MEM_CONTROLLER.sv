`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.06.2025 16:40:20
// Design Name: 
// Module Name: ECC_MEM_CONTROLLER
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

module ECC_MEM_CONTROLLER #(parameter ADDR_WIDTH=32, DATA_WIDTH=32, ECC_DEPTH=128, ECC_WIDTH =38)(
  
  input [DATA_WIDTH -1:0] data_in,
  input [ADDR_WIDTH -1:0]address_in,
  input [(DATA_WIDTH/8)-1:0] W_strobe,
  input c_clk,c_rst,
  input S_ready,WA_valid,
  output reg mem_full,
  output reg [(DATA_WIDTH/8)-1:0] o_W_strobe,
  output reg [DATA_WIDTH -1:0] data_out,
  output reg [ADDR_WIDTH -1:0] address_out
  );
  
  reg [((2*DATA_WIDTH)+(DATA_WIDTH/8))-1:0] mem [ECC_DEPTH -1:0];
  reg [(ECC_DEPTH/8) -1:0] i=0,j=0;
  reg data_shift=0,data_shift_completed=1,data_transfer=0;
  reg [(ECC_DEPTH/8)-1:0] index_count=0;
  
  always@(posedge c_clk)
    begin
      if(index_count < ECC_DEPTH)
        begin
          if(WA_valid && data_in>=0)
            begin
              mem[index_count]={W_strobe,data_in,address_in};
              //$display("%h - %h",mem[index_count],data_in);
              data_transfer = 1;
              index_count=index_count+1;
              mem_full=1;
            end
          else
           index_count=index_count+0; 
        end
      else
        begin
          mem_full=0;
        end
    end
  
  always@(negedge c_clk)
    begin
      if(c_rst)
        begin
          if(index_count < ECC_DEPTH)
            mem_full=1;
          if(S_ready)
            begin
              if(mem[0]>=0)
                begin
                  data_out=mem[0][63:32];
                  address_out=mem[0][31:0];
                  o_W_strobe=mem[0][67:64];
                end
              if(index_count>=0)
                data_shift=1;
              else
                data_shift=0;
              data_shift_completed=0;
              data_transfer=0;
            end
          else
            data_shift=0;
        end
      else
        begin
          index_count=0;i=0;j=0;
          mem_full=1;
        end
    end
  
  always@(data_shift)
    begin
      for(j=1;j<128;j=j+1)
        begin
          mem[j-1]=mem[j];
          //data_shift_completed=1;
        end
      data_shift_completed=1;
      //$display("%h",mem[0]);
      data_shift=0;
      if(index_count>0)
        begin
          index_count=index_count-1;
          //mem_full=0;
        end
      else
        index_count=index_count+0;
    end
endmodule


