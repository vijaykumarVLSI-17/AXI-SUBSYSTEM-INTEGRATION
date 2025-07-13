`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.06.2025 17:16:29
// Design Name: 
// Module Name: BRAM_Memory
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

module DUAL_PORT_BRAM #(parameter ADDR_WIDTH=32, DATA_WIDTH=32, MEM_WIDTH=38, MEM_DEPTH=200)(
  input M_rst,
  input m_clka,m_clkb,
  input ena,enb,
  input wea,web,
  input WA_valid,
  input [ADDR_WIDTH -1:0] addra,addrb,
  input [MEM_WIDTH -1:0] dina,dinb,
  output reg [MEM_WIDTH -1:0] douta,doutb);
  
  
  reg [MEM_WIDTH -1:0] BRAM [MEM_DEPTH -1:0];
  
  localparam idle_a=2'd0,Write_a=2'd1,Read_a=2'd2;
  localparam idle_b=2'd0,Write_b=2'd1,Read_b=2'd2;
  
  reg [1:0] State_a=idle_a, State_b=idle_b;
  
  always@(posedge m_clka)
    begin
      if(!M_rst)
        begin
          douta <= 0;
          State_a <= idle_a;
        end
      else
        begin
          case(State_a)
            idle_a:
              begin
                if(ena)
                  begin
                    if(wea && ena)
                      State_a <= Write_a;
                    else if(!wea && ena)
                      State_a <= Read_a;
                    else
                      State_a <= idle_a;
                  end
                else
                  State_a <= idle_a;
              end
            Write_a:
              begin
                BRAM[addra] <= dina;
                State_a <= idle_a;
              end
            Read_a:
              begin
                douta <= BRAM[addra];
                State_a <= idle_a;
              end
          endcase
        end
    end
  
  always@(posedge m_clkb)
    begin
      if(!M_rst)
        begin
          doutb <= 0;
          State_b <= idle_b;
        end
      else
        begin
          case(State_b)
            idle_b:
              begin
                if(enb)
                  begin
                    if(web && enb)
                      State_b <= Write_b;
                    else if(!web && enb)
                      State_b <= Read_b;
                    else
                      State_b <= idle_b;
                  end
                else
                  State_b <= idle_b;
              end
            Write_b:
              begin
                BRAM[addrb] <= dinb;
                State_b <= idle_b;
              end
            Read_b:
              begin
                doutb <= BRAM[addrb];
                State_b <= idle_b;
              end
          endcase
        end
    end
endmodule
