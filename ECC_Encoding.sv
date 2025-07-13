module ECC_Encoding #(parameter ADDR_WIDTH=32, DATA_WIDTH=32, MEM_WIDTH=38)(
  input [DATA_WIDTH -1:0] message_data,
  input [ADDR_WIDTH -1:0]address_in,
  input [MEM_WIDTH -1:0] douta,
  input e_clk,e_rst,
  input Main_mem_full,
  input [(DATA_WIDTH/8)-1:0] W_strobe,
  output reg EN_ready,
  output reg wea,ena,
  output reg [MEM_WIDTH -1:0] encodded_data,
  output reg [ADDR_WIDTH -1:0] address_out,
  output wire bvalid_in
  );
  
  reg P=0,P1=0,P2=0,P3=0,P4=0,P5=0,P6=0,P7=0;
  
  localparam idle=4'd0,Parity_bits_of_P1=4'd1,Parity_bits_of_P2=4'd2,Parity_bits_of_P3=4'd3,Parity_bits_of_P4=4'd4,Parity_bits_of_P5=4'd5,Parity_bits_of_P6=4'd6,Parity_bits_of_P7=4'd7,Data_encoding=4'd8,Finish=4'd9,including_parity_bits=4'd10,strobe_operation=4'd11;
  
  reg [3:0] n_state=idle;
  reg [7:0]P_reg_count=0,m_bit_count=0,t_m_b_count=1;
  reg start=0;
  reg [3:0] n=0,rotation_count=0;
  
  reg [18:0] P1_reg=0,P2_reg=0,P3_reg=0,P4_reg=0,P5_reg=0,P6_reg=0,P7_reg=0;
  reg [7:0] P_count=0,P1_count=0,P2_count=0,P3_count=0,P4_count=0,P5_count=0,P6_count=0,P7_count=0;
  
  reg [7:0] P_bit_cont=0,temp_bit_count=0,i;
  reg [37:0] temp_message_data;
  reg [31:0] Decoded_message_data;
  reg [7:0] bit_count;
  //////////////////////////////////////////////////////////////////////////////
  reg D_P07,D_P=0,D_P1=0,D_P2=0,D_P3=0,D_P4=0,D_P5=0,D_P6=0,D_P7=0,D_Pn=0;
  
  reg [6:0]D_index_of_error;
  
  localparam D_idle=4'd0,D_Parity_bits_of_P1=4'd1,D_Parity_bits_of_P2=4'd2,D_Parity_bits_of_P3=4'd3,D_Parity_bits_of_P4=4'd4,D_Parity_bits_of_P5=4'd5,D_Parity_bits_of_P6=4'd6,D_Parity_bits_of_P7=4'd7,D_Data_encoding=4'd8,D_Finish=4'd9,D_including_parity_bits=4'd10;
  
  reg [3:0] D_n_state=D_idle;
  reg [7:0]D_P_reg_count=0,D_m_bit_count=0,D_t_m_b_count=1;
  reg D_start=0;
  reg [3:0] D_n=0;
  
  reg [18:0] D_P1_reg=0,D_P2_reg=0,D_P3_reg=0,D_P4_reg=0,D_P5_reg=0,D_P6_reg=0,D_P7_reg=0;
  reg [7:0] D_P_count=0,D_P1_count=0,D_P2_count=0,D_P3_count=0,D_P4_count=0,D_P5_count=0,D_P6_count=0,D_P7_count=0;
  
  reg [7:0] D_P_bit_cont=0,D_temp_bit_count=0; 
  reg [DATA_WIDTH -1:0] D_temp_message_data,D_temp_message_data1;
  reg [7:0] D_bit_count;
  reg [6:0] D_P_reg,D_rotation_count=0;
  reg [MEM_WIDTH -1:0] D_temp_encodded_data;
  
  assign bvalid_in = (n_state == Finish)? 1 : 0;
  
  
  always@(message_data)
    begin
      if(message_data>0)
        start=1;
      else
        start=0;
    end
  
  always@(posedge e_clk)
    begin
      if(e_rst)
        begin
          case(n_state)
            idle:
              begin
                if(!Main_mem_full)
                  EN_ready=1;
                else
                  EN_ready=0;
                wea = 0;
                ena = 0;
                //encodded_data=0;
                temp_message_data=0;
                P1_reg=0;P2_reg=0;P3_reg=0;P4_reg=0;P5_reg=0;P6_reg=0;P7_reg=0;
                P1=0;P2=0;P3=0;P4=0;P5=0;P6=0;P=0;
                P_count=0;P1_count=0;P2_count=0;P3_count=0;P4_count=0;P5_count=0;P6_count=0;P7_count=0;
                P_bit_cont=0;temp_bit_count=0;
                rotation_count=0;
                if(start)
                  begin
                    EN_ready=0;
                    wea = 0;
                    ena = 1;
                    D_n_state=D_idle;
                    n_state=strobe_operation;
                  end
                else
                  n_state=idle;
              end
            strobe_operation:
              begin
                //D_n_state=D_idle;
                case(D_n_state)
                  D_idle:
                    begin
                      //o_WD_valid=0;
                      D_P_count=0;D_P1_count=0;D_P2_count=0;D_P3_count=0;D_P4_count=0;
                      D_P5_count=0;D_P6_count=0;D_P7_count=0;
                      D_P1_reg=0;D_P2_reg=0;D_P3_reg=0;D_P4_reg=0;D_P5_reg=0;D_P6_reg=0;
                      D_P7_reg=0;
                      D_P_reg =0;
                      D_P=0;D_P1=0;D_P2=0;D_P3=0;D_P4=0;D_P5=0;D_P6=0;D_P7=0;
                      D_temp_message_data=0;D_temp_message_data1=0;
                      //D_temp_encodded_data=0;
                      D_P_reg_count=0;
                      D_P_bit_cont=0;
                      wea = 0;
                      ena = 0;
                      if(rotation_count>2)
                        begin
                          if(douta>=0)
                            begin
                              D_temp_encodded_data=douta;
                              D_n_state = D_including_parity_bits;
                            end
                          else
                            begin
                              n_state=including_parity_bits;
                              D_n_state=D_idle;
                            end
                        end
                      else
                        begin
                          rotation_count=rotation_count+1;
                          D_n_state = D_idle;
                        end
                    end
                  D_including_parity_bits:
                    begin
                      D_n=0;
                      D_t_m_b_count=0;
//                       if(douta>=0)
//                         D_temp_encodded_data=douta;
//                       else
//                         n_state=including_parity_bits;
                      D_temp_encodded_data=douta;
                      for(D_m_bit_count=0; D_m_bit_count<39 ;D_m_bit_count=D_m_bit_count+1)
                        begin
                          if(D_m_bit_count+1==(2**D_n))
                            begin
                              D_P_reg[D_n]=D_temp_encodded_data[D_m_bit_count];
                              D_n=D_n+1;
                            end
                          else
                            begin
                              D_temp_message_data[D_t_m_b_count]= D_temp_encodded_data[D_m_bit_count];
                              D_t_m_b_count=D_t_m_b_count+1;
                            end
                        end
                      //$display("%h",temp_message_data);
                      D_n_state=D_Parity_bits_of_P1;
                    end
                  D_Parity_bits_of_P1:
                    begin
                      D_P_count=0;D_P1_count=0;D_P2_count=0;D_P3_count=0;D_P4_count=0;
                      D_P5_count=0;D_P6_count=0;D_P7_count=0;
                      D_P1_reg=0;D_P2_reg=0;D_P3_reg=0;D_P4_reg=0;D_P5_reg=0;D_P6_reg=0;
                      D_P7_reg=0;
                      D_P=0;D_P1=0;D_P2=0;D_P3=0;D_P4=0;D_P5=0;D_P6=0;D_P7=0;
                      D_P_reg_count=0;
                      D_P_bit_cont=0;
                      for(D_P_bit_cont=0; D_P_bit_cont<38; D_P_bit_cont=D_P_bit_cont+0)
                        begin
                          if(D_P_bit_cont==0)
                            begin
                              D_P1_reg[D_P_reg_count]=D_temp_encodded_data[D_P_bit_cont];
                              D_P_reg_count=D_P_reg_count+1;
                              D_P_bit_cont=D_P_bit_cont+2;
                            end
                          else
                            begin
                              D_P1_reg[D_P_reg_count]=D_temp_encodded_data[D_P_bit_cont];
                              D_P_reg_count=D_P_reg_count+1;
                              D_P_bit_cont=D_P_bit_cont+2;
                            end
                        end
                      D_n_state=D_Parity_bits_of_P2;
                    end
                  D_Parity_bits_of_P2:
                    begin
                      D_P_bit_cont=1;
                      D_P_reg_count=0;
                      for(D_P_bit_cont=1; D_P_bit_cont<38; D_P_bit_cont=D_P_bit_cont+0)
                        begin
                          if(D_P_bit_cont==1 || D_P_bit_cont==2)
                            begin
                              D_P2_reg[D_P_reg_count]=D_temp_encodded_data[D_P_bit_cont];
                              //$display("%d-%d=%h",P_bit_cont,P_reg_count,P2_reg[P_reg_count]);
                              D_P_reg_count=D_P_reg_count+1;
                              D_P_bit_cont=D_P_bit_cont+1;
                            end
                          else
                            begin
                              if(D_P_bit_cont==3)
                                begin
                                  D_P_bit_cont=D_P_bit_cont-1;
                                  D_P_reg_count=D_P_reg_count-1;
                                end
                              if(D_P_bit_cont<36)
                                begin
                                  D_P_reg_count=D_P_reg_count+1;
                                  D_P_bit_cont=D_P_bit_cont+3;
                                  D_P2_reg[D_P_reg_count]=D_temp_encodded_data[D_P_bit_cont];
                                  //$display("%d-%d=%h",P_bit_cont,P_reg_count,P2_reg[P_reg_count]);
                                end
                              if(D_P_bit_cont<37)
                                begin
                                  D_P_bit_cont=D_P_bit_cont+1;
                                  D_P_reg_count=D_P_reg_count+1;
                                  D_P2_reg[D_P_reg_count]=D_temp_encodded_data[D_P_bit_cont];
                                  //$display("%d-%d=%h",P_bit_cont,P_reg_count,P2_reg[P_reg_count]);
                                end
                              else
                                D_P_bit_cont=39;
                            end
                        end
                      D_n_state=D_Parity_bits_of_P3;
                    end
                  D_Parity_bits_of_P3:
                    begin
                      D_temp_bit_count=7;
                      D_P_bit_cont=3;
                      D_P_reg_count=0;
                      for(D_P_bit_cont=3; D_P_bit_cont<38; D_P_bit_cont=D_P_bit_cont+4)
                        begin
                          for(D_P_bit_cont=D_temp_bit_count-4; D_P_bit_cont<D_temp_bit_count; 
                                      D_P_bit_cont=D_P_bit_cont+1)
                            begin
                              if(D_P_bit_cont<38)
                                begin
                                  D_P3_reg[D_P_reg_count]=D_temp_encodded_data[D_P_bit_cont];
                                  D_P_reg_count=D_P_reg_count+1;
                                end
                            end
                          D_temp_bit_count=D_temp_bit_count+8;
                        end
                      D_n_state=D_Parity_bits_of_P4;
                    end
                  D_Parity_bits_of_P4:
                    begin
                      D_temp_bit_count=15;
                      D_P_bit_cont=7;
                      D_P_reg_count=0;
                      for(D_P_bit_cont=7; D_P_bit_cont<38; D_P_bit_cont=D_P_bit_cont+8)
                        begin
                          for(D_P_bit_cont=D_temp_bit_count-8; D_P_bit_cont<D_temp_bit_count; 
                                      D_P_bit_cont=D_P_bit_cont+1)
                            begin
                              if(D_P_bit_cont<38)
                                begin
                                  D_P4_reg[D_P_reg_count]=D_temp_encodded_data[D_P_bit_cont];
                                  D_P_reg_count=D_P_reg_count+1;
                                end
                            end
                          D_temp_bit_count=D_temp_bit_count+16;
                        end
                      D_n_state=D_Parity_bits_of_P5;
                    end
                  D_Parity_bits_of_P5:
                    begin
                      D_temp_bit_count=31;
                      D_P_bit_cont=15;
                      D_P_reg_count=0;
                      for(D_P_bit_cont=15; D_P_bit_cont<38; D_P_bit_cont=D_P_bit_cont+16)
                        begin
                          for(D_P_bit_cont=D_temp_bit_count-16; D_P_bit_cont<D_temp_bit_count; 
                                      D_P_bit_cont=D_P_bit_cont+1)
                            begin
                              if(D_P_bit_cont<38)
                                begin
                                  D_P5_reg[D_P_reg_count]=D_temp_encodded_data[D_P_bit_cont];
                                  D_P_reg_count=D_P_reg_count+1;
                                end
                            end
                          D_temp_bit_count=D_temp_bit_count+32;
                        end
                      D_n_state=D_Parity_bits_of_P6;
                    end
                  D_Parity_bits_of_P6:
                    begin
                      D_P_bit_cont=31;
                      D_P_reg_count=0;
                      for(D_P_bit_cont=31; D_P_bit_cont<38; D_P_bit_cont=D_P_bit_cont+1)
                        begin
                          D_P6_reg[D_P_reg_count]=D_temp_encodded_data[D_P_bit_cont];
                          D_P_reg_count=D_P_reg_count+1;
                        end
                      D_n_state=D_Finish;
                    end
                  D_Finish:
                    begin
                      for(D_bit_count=0; D_bit_count<19; D_bit_count=D_bit_count+1)
                        begin
                          D_P1=D_P1^D_P1_reg[D_bit_count];
                          D_P2=D_P2^D_P2_reg[D_bit_count];
                          D_P3=D_P3^D_P3_reg[D_bit_count];
                          D_P4=D_P4^D_P4_reg[D_bit_count];
                          D_P5=D_P5^D_P5_reg[D_bit_count];
                          D_P6=D_P6^D_P6_reg[D_bit_count];
                          D_P07=D_P7;
                        end
                      for(D_bit_count=0; D_bit_count<38; D_bit_count=D_bit_count+1)
                        begin
                          D_P=D_P^D_temp_encodded_data[D_bit_count];
                        end
                      if({D_P1,D_P2,D_P3,D_P4,D_P5,D_P6}==0)
                        begin
                          //o_WD_valid=1;
                          D_temp_message_data1=D_temp_message_data;////sample data///////
//                           $display("--------there is no error occured in message--------");
//                           $display("-------------------%h-----------------",message_data);
                        end
                      else
                        begin
                          $display("---------error occured in message--------");
                        end
                      for (i = 0; i < (4); i++) 
                        begin
                          if (W_strobe[i])
                            Decoded_message_data[i*8 +: 8] = message_data[i*8 +: 8];
                          else
                            Decoded_message_data[i*8 +: 8] = D_temp_message_data1[i*8 +: 8];
                        end
                      $display("message data = %h",message_data);
                      $display("old data = %h",D_temp_message_data1);
                      $display("Strobe = %b",W_strobe);
                      $display("new message data = %h",Decoded_message_data);
                      $display("-----------------------------------");
                      n_state=including_parity_bits;
                    end
                endcase
                //n_state=including_parity_bits;
              end
            including_parity_bits:
              begin
                n=0;
//                 wea = 0;
//                 ena = 0;
                t_m_b_count=1;
                for(m_bit_count=0; m_bit_count<32 ;m_bit_count=m_bit_count+1)
                  begin
                    if(t_m_b_count==(2**n))
                      begin
                        temp_message_data[t_m_b_count-1]=0;
                        m_bit_count=m_bit_count-1;
                        n=n+1;
                        t_m_b_count=t_m_b_count+1;
                      end
                    else
                      begin
                        temp_message_data[t_m_b_count-1]=message_data[m_bit_count];
                        t_m_b_count=t_m_b_count+1;
                      end
                  end
                n_state=Parity_bits_of_P1;
              end
            Parity_bits_of_P1:
              begin
                P1_reg=0;P2_reg=0;P3_reg=0;P4_reg=0;P5_reg=0;P6_reg=0;P7_reg=0;
                P_count=0;P1_count=0;P2_count=0;P3_count=0;P4_count=0;P5_count=0;P6_count=0;P7_count=0;
                P_reg_count=0;
                P_bit_cont=0;
                for(P_bit_cont=0; P_bit_cont<38; P_bit_cont=P_bit_cont+0)
                  begin
                    if(P_bit_cont==0)
                      begin
                        P1_reg[P_reg_count]=temp_message_data[P_bit_cont];
                        P_reg_count=P_reg_count+1;
                        P_bit_cont=P_bit_cont+2;
                      end
                    else if(P_bit_cont<38)
                      begin
                        P1_reg[P_reg_count]=temp_message_data[P_bit_cont];
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
                        P2_reg[P_reg_count]=temp_message_data[P_bit_cont];
                        //$display("%d-%d=%h",P_bit_cont,P_reg_count,P2_reg[P_reg_count]);
                        P_bit_cont=P_bit_cont+1;
                        P_reg_count=P_reg_count+1;
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
                            P2_reg[P_reg_count]=temp_message_data[P_bit_cont];
                            //$display("%d-%d=%h",P_bit_cont,P_reg_count,P2_reg[P_reg_count]);
                          end
                        if(P_bit_cont<37)
                          begin
                            P_bit_cont=P_bit_cont+1;
                            P_reg_count=P_reg_count+1;
                            P2_reg[P_reg_count]=temp_message_data[P_bit_cont];
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
                            P3_reg[P_reg_count]=temp_message_data[P_bit_cont];
                            //$display("%d-%d=%h",P_bit_cont,P_reg_count,P3_reg[P_reg_count]);
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
                            P4_reg[P_reg_count]=temp_message_data[P_bit_cont];
                            //$display("%d-%d=%h",P_bit_cont,P_reg_count,P4_reg[P_reg_count]);
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
                            P5_reg[P_reg_count]=temp_message_data[P_bit_cont];
                            //$display("%d-%d=%h",P_bit_cont,P_reg_count,P5_reg[P_reg_count]);
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
                    P6_reg[P_reg_count]=temp_message_data[P_bit_cont];
                    //$display("%d-%d=%h",P_bit_cont,P_reg_count,P6_reg[P_reg_count]);
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
                    P7=P7^P7_reg[bit_count];
                  end
                temp_message_data[2**0-1]=P1;
                temp_message_data[2**1-1]=P2;
                temp_message_data[2**2-1]=P3;
                temp_message_data[2**3-1]=P4;
                temp_message_data[2**4-1]=P5;
                temp_message_data[2**5-1]=P6;
                for(bit_count=0; bit_count<38; bit_count=bit_count+1)
                  begin
                    P=P^temp_message_data[bit_count];
                  end
                encodded_data=temp_message_data;
                address_out=address_in;
                wea = 1;
                ena = 1;
                address_out=address_in;
                //$display("---------%h---------",encodded_data);
                start=0;
                n_state=idle;
              end
          endcase
        end
      else
        begin
          encodded_data=0;
          temp_message_data=0;
          P1=0;P2=0;P3=0;P4=0;P5=0;P6=0;
          P1_reg=0;P2_reg=0;P3_reg=0;P4_reg=0;P5_reg=0;P6_reg=0;P7_reg=0;
          P_count=0;P1_count=0;P2_count=0;P3_count=0;P4_count=0;P5_count=0;P6_count=0;P7_count=0;
          P_bit_cont=0;temp_bit_count=0;
        end
    end
endmodule