`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.06.2025 16:31:01
// Design Name: 
// Module Name: TOP_ECC_BRAM
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

module TOP_ECC_BRAM #(parameter ADDR_WIDTH=32, DATA_WIDTH=32, MEM_DEPTH=128, MEM_WIDTH=38)( 
  input m_clk,
  input m_rst,
  input clka,clkb,
  input enb,web,
  input WA_valid,
  input S_ready,
  input bvalid_in,
  output reg mem_full,
  output reg o_WD_valid,
  output reg t_ready,
  input [DATA_WIDTH -1:0] data_in,
  input [ADDR_WIDTH -1:0]addra,addrb,
  input [(DATA_WIDTH/8)-1:0] W_strobe,
  input [MEM_WIDTH -1:0] dinb,
  output wire DE_finish,
//  output wire bvalid_o,
  
  output reg [DATA_WIDTH -1:0] data_out);

  wire E_ready_HE,MM_ena_HE;
  wire HE_WA_valid_MM;
  wire HE_mem_full_MM=0;
  wire [(DATA_WIDTH/8)-1:0] EC_W_strobe_HE;
  wire [MEM_WIDTH -1:0] HE_data_MM, MM_data_HD,douta;
  wire [DATA_WIDTH -1:0] E_data_HE;
  wire [ADDR_WIDTH -1:0]E_address_HE,HE_address_MM;
  
  ECC_MEM_CONTROLLER ECC_memory (.data_in(data_in),.address_in(addra),.c_clk(m_clk),.c_rst(m_rst),.S_ready(E_ready_HE),.WA_valid(WA_valid),.mem_full(mem_full),.data_out(E_data_HE),.address_out(E_address_HE),.W_strobe(W_strobe),.o_W_strobe(EC_W_strobe_HE));
  
  ECC_Encoding Hamming_EC (.message_data(E_data_HE),.address_in(E_address_HE),.douta(douta),.bvalid_in(bvalid_in),.e_clk(m_clk),.e_rst(m_rst),.Main_mem_full(HE_mem_full_MM),.EN_ready(E_ready_HE),.wea(HE_WA_valid_MM),.ena(MM_ena_HE),.encodded_data(HE_data_MM),.address_out(HE_address_MM),.W_strobe(EC_W_strobe_HE));
  
  DUAL_PORT_BRAM main_Memory1 (.M_rst(m_rst),.m_clka(clka),.m_clkb(clkb),.ena(MM_ena_HE),.enb(enb),.wea(HE_WA_valid_MM),.web(web),.WA_valid(HE_WA_valid_MM),.addra(HE_address_MM),.addrb(addrb),.dina(HE_data_MM),.dinb(dinb),.douta(douta),.doutb(MM_data_HD));
  
  ECC_Decoding Hamming_DC (.encodded_data(MM_data_HD),.d_clk(m_clk),.d_rst(m_rst),.DE_complete(DE_finish),.DE_ready(t_ready),.S_ready(S_ready),.o_WD_valid(o_WD_valid),.message_data(data_out));

endmodule

