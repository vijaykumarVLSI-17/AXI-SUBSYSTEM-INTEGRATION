`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.06.2025 17:13:30
// Design Name: 
// Module Name: ECC_Decoding
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

module ECC_Decoding #(parameter ADDR_WIDTH=32, DATA_WIDTH=32, MEM_WIDTH=38)(
  input [MEM_WIDTH -1:0] encodded_data,
  input d_clk,d_rst,
  input S_ready,
  output reg DE_ready,
  output wire DE_complete,
  output reg o_WD_valid,
  output reg [DATA_WIDTH -1:0] message_data);
  
  
  reg P07,P=0,P1=0,P2=0,P3=0,P4=0,P5=0,P6=0,P7=0,Pn=0;
  
  reg [6:0]index_of_error;
  
  localparam idle=4'd0,Parity_bits_of_P1=4'd1,Parity_bits_of_P2=4'd2,Parity_bits_of_P3=4'd3,Parity_bits_of_P4=4'd4,Parity_bits_of_P5=4'd5,Parity_bits_of_P6=4'd6,Parity_bits_of_P7=4'd7,Data_encoding=4'd8,Finish=4'd9,including_parity_bits=4'd10;
  
  reg [3:0] n_state=idle;
  reg [7:0]P_reg_count=0,m_bit_count=0,t_m_b_count=1;
  reg start=0;
  reg [3:0] n=0;
  
  reg [18:0] P1_reg=0,P2_reg=0,P3_reg=0,P4_reg=0,P5_reg=0,P6_reg=0,P7_reg=0;
  reg [7:0] P_count=0,P1_count=0,P2_count=0,P3_count=0,P4_count=0,P5_count=0,P6_count=0,P7_count=0;
  
  reg [7:0] P_bit_cont=0,temp_bit_count=0; 
  reg [DATA_WIDTH -1:0] temp_message_data,temp_message_data1;
  reg [7:0] bit_count;
  reg [6:0] P_reg,rotation_count=0;
  reg [MEM_WIDTH -1:0] temp_encodded_data;
  
  assign DE_complete = ((n_state == idle) && !start);
  
  always@(encodded_data)
    begin
      if(encodded_data>0)
        start=1;
      else
        start=0;
    end
  
  always@(posedge d_clk)
    begin
      if(d_rst)
        begin
          case(n_state)
            idle:
              begin
                if(S_ready)
                  DE_ready=1;
                else
                  DE_ready=0;
                o_WD_valid=0;
                P_count=0;P1_count=0;P2_count=0;P3_count=0;P4_count=0;
                P5_count=0;P6_count=0;P7_count=0;
                P1_reg=0;P2_reg=0;P3_reg=0;P4_reg=0;P5_reg=0;P6_reg=0;P7_reg=0;
                P=0;P1=0;P2=0;P3=0;P4=0;P5=0;P6=0;P7=0;
                temp_message_data=0;temp_message_data1=0;
                temp_encodded_data=0;
                P_reg_count=0;
                P_bit_cont=0;
                if(start)
                  begin
                    DE_ready=0;
                    n_state=including_parity_bits;
                    start = 0;
                  end
                else
                  n_state=idle;
              end
            including_parity_bits:
              begin
                n=0;
                t_m_b_count=0;
                temp_encodded_data=encodded_data;
                for(m_bit_count=0; m_bit_count<39 ;m_bit_count=m_bit_count+1)
                  begin
                    if(m_bit_count+1==(2**n))
                      begin
                        P_reg[n]=temp_encodded_data[m_bit_count];
                        n=n+1;
                      end
                    else
                      begin
                        temp_message_data[t_m_b_count]=temp_encodded_data[m_bit_count];
                        t_m_b_count=t_m_b_count+1;
                      end
                  end
                //$display("%h",temp_message_data);
                n_state=Parity_bits_of_P1;
              end
            Parity_bits_of_P1:
              begin
                P_count=0;P1_count=0;P2_count=0;P3_count=0;P4_count=0;P5_count=0;P6_count=0;P7_count=0;
                P1_reg=0;P2_reg=0;P3_reg=0;P4_reg=0;P5_reg=0;P6_reg=0;P7_reg=0;
                P=0;P1=0;P2=0;P3=0;P4=0;P5=0;P6=0;P7=0;
                P_reg_count=0;
                P_bit_cont=0;
                for(P_bit_cont=0; P_bit_cont<38; P_bit_cont=P_bit_cont+0)
                  begin
                    if(P_bit_cont==0)
                      begin
                        P1_reg[P_reg_count]=temp_encodded_data[P_bit_cont];
                        P_reg_count=P_reg_count+1;
                        P_bit_cont=P_bit_cont+2;
                      end
                    else
                      begin
                        P1_reg[P_reg_count]=temp_encodded_data[P_bit_cont];
                        P_reg_count=P_reg_count+1;
                        P_bit_cont=P_bit_cont+2;
                      end
                  end
                n_state=Parity_bits_of_P2;
              end
            Parity_bits_of_P2:
              begin
                P_bit_cont=1;
                P_reg_count=0;
                for(P_bit_cont=1; P_bit_cont<38; P_bit_cont=P_bit_cont+0)
                  begin
                    if(P_bit_cont==1 || P_bit_cont==2)
                      begin
                        P2_reg[P_reg_count]=temp_encodded_data[P_bit_cont];
                        //$display("%d-%d=%h",P_bit_cont,P_reg_count,P2_reg[P_reg_count]);
                        P_reg_count=P_reg_count+1;
                        P_bit_cont=P_bit_cont+1;
                      end
                    else
                      begin
                        if(P_bit_cont==3)
                          begin
                            P_bit_cont=P_bit_cont-1;
                            P_reg_count=P_reg_count-1;
                          end
                        if(P_bit_cont<36)
                          begin
                            P_reg_count=P_reg_count+1;
                            P_bit_cont=P_bit_cont+3;
                            P2_reg[P_reg_count]=temp_encodded_data[P_bit_cont];
                            //$display("%d-%d=%h",P_bit_cont,P_reg_count,P2_reg[P_reg_count]);
                          end
                        if(P_bit_cont<37)
                          begin
                            P_bit_cont=P_bit_cont+1;
                            P_reg_count=P_reg_count+1;
                            P2_reg[P_reg_count]=temp_encodded_data[P_bit_cont];
                            //$display("%d-%d=%h",P_bit_cont,P_reg_count,P2_reg[P_reg_count]);
                          end
                        else
                          P_bit_cont=39;
                      end
                  end
                n_state=Parity_bits_of_P3;
              end
            Parity_bits_of_P3:
              begin
                temp_bit_count=7;
                P_bit_cont=3;
                P_reg_count=0;
                for(P_bit_cont=3; P_bit_cont<38; P_bit_cont=P_bit_cont+4)
                  begin
                    for(P_bit_cont=temp_bit_count-4; P_bit_cont<temp_bit_count; P_bit_cont=P_bit_cont+1)
                      begin
                        if(P_bit_cont<38)
                          begin
                            P3_reg[P_reg_count]=temp_encodded_data[P_bit_cont];
                            P_reg_count=P_reg_count+1;
                          end
                      end
                    temp_bit_count=temp_bit_count+8;
                  end
                n_state=Parity_bits_of_P4;
              end
            Parity_bits_of_P4:
              begin
                temp_bit_count=15;
                P_bit_cont=7;
                P_reg_count=0;
                for(P_bit_cont=7; P_bit_cont<38; P_bit_cont=P_bit_cont+8)
                  begin
                    for(P_bit_cont=temp_bit_count-8; P_bit_cont<temp_bit_count; P_bit_cont=P_bit_cont+1)
                      begin
                        if(P_bit_cont<38)
                          begin
                            P4_reg[P_reg_count]=temp_encodded_data[P_bit_cont];
                            P_reg_count=P_reg_count+1;
                          end
                      end
                    temp_bit_count=temp_bit_count+16;
                  end
                n_state=Parity_bits_of_P5;
              end
            Parity_bits_of_P5:
              begin
                temp_bit_count=31;
                P_bit_cont=15;
                P_reg_count=0;
                for(P_bit_cont=15; P_bit_cont<38; P_bit_cont=P_bit_cont+16)
                  begin
                    for(P_bit_cont=temp_bit_count-16; P_bit_cont<temp_bit_count; P_bit_cont=P_bit_cont+1)
                      begin
                        if(P_bit_cont<38)
                          begin
                            P5_reg[P_reg_count]=temp_encodded_data[P_bit_cont];
                            P_reg_count=P_reg_count+1;
                          end
                      end
                    temp_bit_count=temp_bit_count+32;
                  end
                n_state=Parity_bits_of_P6;
              end
            Parity_bits_of_P6:
              begin
                P_bit_cont=31;
                P_reg_count=0;
                for(P_bit_cont=31; P_bit_cont<38; P_bit_cont=P_bit_cont+1)
                  begin
                    P6_reg[P_reg_count]=temp_encodded_data[P_bit_cont];
                    P_reg_count=P_reg_count+1;
                  end
                n_state=Finish;
              end
            Finish:
              begin
                for(bit_count=0; bit_count<19; bit_count=bit_count+1)
                  begin
                    P1=P1^P1_reg[bit_count];
                    P2=P2^P2_reg[bit_count];
                    P3=P3^P3_reg[bit_count];
                    P4=P4^P4_reg[bit_count];
                    P5=P5^P5_reg[bit_count];
                    P6=P6^P6_reg[bit_count];
                    P07=P7;
                  end
                for(bit_count=0; bit_count<38; bit_count=bit_count+1)
                  begin
                    P=P^temp_encodded_data[bit_count];
                  end
                if({P1,P2,P3,P4,P5,P6}==0)
                  begin
                    o_WD_valid=1;
                    message_data=temp_message_data;
//                     $display("--------there is no error occured in message--------");
//                     $display("-------------------%h-----------------",message_data);
                  end
                else
                  begin
                    //$display("---------error occured in message--------");
                  end
//                start=0;
                n_state=idle;
              end
          endcase
        end
      else
        begin
          P_count=0;P1_count=0;P2_count=0;P3_count=0;P4_count=0;P5_count=0;P6_count=0;P7_count=0;
          P1_reg=0;P2_reg=0;P3_reg=0;P4_reg=0;P5_reg=0;P6_reg=0;P7_reg=0;
          P=0;P1=0;P2=0;P3=0;P4=0;P5=0;P6=0;P7=0;
          temp_message_data=0;temp_message_data1=0;
          temp_encodded_data=0;
          P_reg_count=0;
          P_bit_cont=0;
        end
    end
endmodule

