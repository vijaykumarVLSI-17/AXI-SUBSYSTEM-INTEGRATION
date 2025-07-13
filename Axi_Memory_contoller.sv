 `timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: NANOCHIP SOLUTIONS
// Engineer: VIJAY KUMAR AYINALA (SoC DESIGN & VERIFICATION ENGINEER)
//
// Create Date: 12.05.2025 10:18:47
// Design Name: AXI MEMORY CONTROLLER
// Module Name: AXI_Memory_Controller
// Project Name: AXI - COMPATIBLE MEMORY CONTROLLER
// Target Devices: LOW - POWER EMBEDDED SYSTEMS 
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


module AXI_Memory_Controller #(
  parameter ADDR_WIDTH = 32,
  parameter DATA_WIDTH = 32,
  parameter STRB_WIDTH = (DATA_WIDTH/8),
  parameter BURST_TYPE = 2,
  parameter BURST_LEN = 8,
  parameter BEAT_SIZE = 3,
  parameter ID = 5,
  parameter RESP_WIDTH = 2
)(
  
  input wire mem_contlr_CLK,
  input wire mem_contlr_RST,
  
  output reg AW_r_en,
  output reg W_r_en,
  output reg AR_r_en,
  input wire[ADDR_WIDTH -1:0]AWADDR_mem_contlr_in,
  input wire[BURST_TYPE -1:0]AWBURST_mem_contlr_in,
  input wire[BURST_LEN -1:0]AWLEN_mem_contlr_in,
  input wire[BEAT_SIZE -1:0]AWSIZE_mem_contlr_in,
  input wire[ID -1:0]AWID_mem_contlr_in,
  input wire AWVALID_mem_contlr_in,
  input wire AWREADY_mem_contlr_in,
  
  input wire AW_fifo_empty_in,
  
  output reg[ADDR_WIDTH -1:0]AWADDR_mem_contlr_out,
  output reg[BURST_TYPE -1:0]AWBURST_mem_contlr_out,
  output reg[BURST_LEN -1:0]AWLEN_mem_contlr_out,
  output reg[BEAT_SIZE -1:0]AWSIZE_mem_contlr_out,
  output reg[ID -1:0]AWID_mem_contlr_out,
  output reg AWVALID_mem_contlr_out,
  output reg AWREADY_mem_contlr_out,
  
  input wire[DATA_WIDTH -1:0]WDATA_mem_contlr_in,
  input wire[STRB_WIDTH -1:0]WSTRB_mem_contlr_in,
  input wire WLAST_mem_contlr_in,
  input wire WVALID_mem_contlr_in,
  input wire WREADY_mem_contlr_in,
  
  input wire W_fifo_empty_in,
  input wire [BURST_LEN -1:0]fifo_occupancy,
  
  output reg[DATA_WIDTH -1:0]WDATA_mem_contlr_out,
  output reg[STRB_WIDTH -1:0]WSTRB_mem_contlr_out,
  output reg WLAST_mem_contlr_out,
  output reg WVALID_mem_contlr_out,
  output reg WREADY_mem_contlr_out,
  
  output wire[RESP_WIDTH -1:0]BRESP_mem_contlr_out,
  output wire[ID -1:0]BID_mem_contlr_out,
  output reg BVALID_mem_contlr_out,
  input  wire BREADY_mem_contlr_in,
  
  input wire[RESP_WIDTH -1:0]BRESP_mem_contlr_in,
  input wire[ID -1:0]BID_mem_contlr_in,
  input wire BVALID_mem_contlr_in,
  output reg BREADY_mem_contlr_out,
  
  input wire[ADDR_WIDTH -1:0]ARADDR_mem_contlr_in,
  input wire[BURST_TYPE -1:0]ARBURST_mem_contlr_in,
  input wire[BURST_LEN -1:0]ARLEN_mem_contlr_in,
  input wire[BEAT_SIZE -1:0]ARSIZE_mem_contlr_in,
  input wire[ID -1:0]ARID_mem_contlr_in,
  input wire ARVALID_mem_contlr_in,
  input wire ARREADY_mem_contlr_in,
  
  input wire ECC_DE_complete,
  input wire AR_fifo_empty_in,
  
  output reg[ADDR_WIDTH -1:0]ARADDR_mem_contlr_out,
  output reg[BURST_TYPE -1:0]ARBURST_mem_contlr_out,
  output reg[BURST_LEN -1:0]ARLEN_mem_contlr_out,
  output reg[BEAT_SIZE -1:0]ARSIZE_mem_contlr_out,
  output reg[ID -1:0]ARID_mem_contlr_out,
  output reg ARVALID_mem_contlr_out,
  output reg ARREADY_mem_contlr_out,
  
  input wire[DATA_WIDTH -1:0]RDATA_mem_contlr_in,
  input wire[ID -1:0]RID_mem_contlr_in,
  input wire RLAST_mem_contlr_in,
  input wire RVALID_mem_contlr_in,
  input wire RREADY_mem_contlr_in,
  
  output reg[DATA_WIDTH -1:0]RDATA_mem_contlr_out,
  output reg[ID -1:0]RID_mem_contlr_out,
  output reg RLAST_mem_contlr_out,
  output reg RVALID_mem_contlr_out,
  output reg RREADY_mem_contlr_out
  
);
  //parameters for burst type in AXI MEMORY CONTROLLER
  localparam FIXED_BURST = 2'b00;
  localparam INCR_BURST = 2'b01;
  localparam WRAP_BURST = 2'b10;
  //parameter for wrap boundary mask
  localparam WRAP_WIDTH = 6;

  //INTERNAL REGISTERS for write transaction OF AXI MEMORY CONTROLLER
  wire [WRAP_WIDTH -1:0]wrap_boundary_mask;
  reg [BURST_LEN -1:0]mem_contlr_burst_counter;
  
  reg burst_progress = 0;
  reg burst_complete = 1;
  reg [ADDR_WIDTH -1:0]incr_addr_reg;
  reg [ADDR_WIDTH -1:0]base_addr_reg;
  reg [ADDR_WIDTH -1:0]wrap_addr_reg;
  reg [ADDR_WIDTH -1:0]starting_addr_reg;
  reg [ADDR_WIDTH -1:0]next_addr_reg;
  reg [BURST_TYPE -1:0]mem_contlr_burst_type_reg;
  reg [BURST_LEN -1:0]mem_contlr_awlen_reg;
  reg [BEAT_SIZE -1:0]mem_contlr_beat_size_reg;
  reg [ID -1:0]mem_contlr_awid_reg;
  
  reg [1:0]AW_txn_state;
  localparam IDLE_AW = 2'b00;
  localparam LATCH_AW = 2'b01;
  localparam SEND_AW = 2'b10;
  localparam BURST_ADDR = 2'b11;
  
  assign wrap_boundary_mask = (AW_txn_state == LATCH_AW)? ((1 << AWSIZE_mem_contlr_in) * (AWLEN_mem_contlr_in + 1) ) - 1 : 0;
  
  //AW Channel 
  always @(posedge mem_contlr_CLK)begin
    if(!mem_contlr_RST)begin
      //control signal Initialisation
      AW_r_en <= 0;
      //initialization of AW Channel flip-flop registers 
      incr_addr_reg <= 0;
      base_addr_reg <= 0;
      wrap_addr_reg <= 0;
      starting_addr_reg <= 0;
      next_addr_reg <= 0;
      mem_contlr_burst_type_reg <= 0;
      mem_contlr_awlen_reg <= 1'bz;
      mem_contlr_beat_size_reg <= 0;
      mem_contlr_awid_reg <= 1'bz;
      //initialization of counters
      mem_contlr_burst_counter <= 0;
      //FSM's initialization   
      AW_txn_state <= IDLE_AW;
      //Initialization of AXI Interface Signals (READY && VALID)
      AWVALID_mem_contlr_out <= 0;
      AWREADY_mem_contlr_out <= 0;
    end
    else begin
      case(AW_txn_state)
        IDLE_AW:begin
          if(burst_complete && !AW_fifo_empty_in)begin
//            AWREADY_mem_contlr_out <= 1;
            AW_r_en <= 1;
            AW_txn_state <= LATCH_AW;
            mem_contlr_burst_counter <= 0;
            incr_addr_reg <= 0;
            starting_addr_reg <= 0;
            base_addr_reg <= 0;
            next_addr_reg <= 0;
          end
          else begin
            AWREADY_mem_contlr_out <= 0;
            AW_txn_state <= IDLE_AW;
          end
        end
        
        LATCH_AW:begin
          AW_r_en <= 0;
          AWREADY_mem_contlr_out <= 1;
          if(AWVALID_mem_contlr_in && AWREADY_mem_contlr_out)begin
            base_addr_reg <= AWADDR_mem_contlr_in;
            starting_addr_reg <= AWADDR_mem_contlr_in;
            mem_contlr_burst_type_reg <= AWBURST_mem_contlr_in;
            mem_contlr_awlen_reg <= AWLEN_mem_contlr_in;
            mem_contlr_beat_size_reg <= AWSIZE_mem_contlr_in;
            mem_contlr_awid_reg <= AWID_mem_contlr_in;
            AW_txn_state <= BURST_ADDR;
            AWREADY_mem_contlr_out <= 0;
            burst_progress <= 1;
            burst_complete <= 0;
            
          end
          else begin
            AW_txn_state <= LATCH_AW;
            AWREADY_mem_contlr_out <= 1;
            AWVALID_mem_contlr_out <= 0;
          end
        end
        
        
        BURST_ADDR:begin
          if(mem_contlr_burst_counter <= mem_contlr_awlen_reg)begin
            AWVALID_mem_contlr_out <= 1;
            AWBURST_mem_contlr_out <= mem_contlr_burst_type_reg;
            AWLEN_mem_contlr_out <= mem_contlr_awlen_reg;
            AWSIZE_mem_contlr_out <= mem_contlr_beat_size_reg;
            AWID_mem_contlr_out <= mem_contlr_awid_reg;
            case(mem_contlr_burst_type_reg)
              FIXED_BURST:begin
                AWADDR_mem_contlr_out <= base_addr_reg;
                if(AWREADY_mem_contlr_in && AWVALID_mem_contlr_out)begin
                  AWVALID_mem_contlr_out <= 0;
                  mem_contlr_burst_counter <= mem_contlr_burst_counter + 1;
                  AW_txn_state <= BURST_ADDR;
                end
                else begin
                  AWVALID_mem_contlr_out <= 1;
                  AW_txn_state <= BURST_ADDR;
                end
              end
            
              INCR_BURST:begin
                incr_addr_reg <= starting_addr_reg + (1 << mem_contlr_beat_size_reg);
                AWADDR_mem_contlr_out <= starting_addr_reg;
                if(AWREADY_mem_contlr_in && AWVALID_mem_contlr_out)begin
                  starting_addr_reg <= incr_addr_reg;
                  AWVALID_mem_contlr_out <= 0;
                  mem_contlr_burst_counter <= mem_contlr_burst_counter + 1;
                  AW_txn_state <= BURST_ADDR;
                end
                else begin
                  AWVALID_mem_contlr_out <= 1;
                  AW_txn_state <= BURST_ADDR;
                end
              end
            
              WRAP_BURST:begin
                //NEXT address logic
                next_addr_reg <= starting_addr_reg + (1 << mem_contlr_beat_size_reg);
              
                //Applying WRAP Boundary Condition
                if((next_addr_reg & ~wrap_boundary_mask) != (base_addr_reg & ~wrap_boundary_mask))begin
                  wrap_addr_reg <= (base_addr_reg & ~wrap_boundary_mask) | (next_addr_reg & wrap_boundary_mask);
                end
                else begin
                  wrap_addr_reg <= next_addr_reg;
                end
                AWADDR_mem_contlr_out <= starting_addr_reg;
                if(AWREADY_mem_contlr_in && AWVALID_mem_contlr_out)begin
                  starting_addr_reg <= next_addr_reg;
                  mem_contlr_burst_counter <= mem_contlr_burst_counter + 1;
                  AW_txn_state <= BURST_ADDR;
                  AWVALID_mem_contlr_out <= 0;
                end
              end
            endcase
          end
          else begin
            AW_txn_state <= IDLE_AW;
            mem_contlr_burst_counter <= 0;
          end
        end
      endcase
    end
  end
  
  
  reg [BURST_LEN -1:0]data_beat_counter;
  reg [1:0]W_txn_state;
  localparam IDLE_W = 2'b00;
  localparam WDATA_LATCH = 2'b01; 
  localparam SEND_WDATA = 2'b10;
  
  reg [DATA_WIDTH -1:0]mem_contlr_wdata_reg;
  reg [STRB_WIDTH -1:0]mem_contlr_wstrb_reg;
  reg mem_contlr_wlast_reg;
  
  reg [ID -1:0]id_index=0;
  reg [ID -1:0]len_index = 0;
  

  //W Channel
  always@(posedge mem_contlr_CLK)begin
    if(!mem_contlr_RST)begin
      W_r_en <= 0;
      mem_contlr_wdata_reg <= 0;
      mem_contlr_wstrb_reg <= 0;
      mem_contlr_wlast_reg <= 0;
      WVALID_mem_contlr_out <= 0;
      WREADY_mem_contlr_out <= 1;
      W_txn_state <= IDLE_W;
      data_beat_counter <= 0;
    end
    else begin
      case(W_txn_state)
        IDLE_W:begin
          if(!W_fifo_empty_in && fifo_occupancy)begin
            WREADY_mem_contlr_out <= 1;
            W_txn_state <= WDATA_LATCH;
          end
          else begin
            W_txn_state <= IDLE_W;
          end
        end
        
        WDATA_LATCH:begin
          W_r_en <= 1;
          mem_contlr_wdata_reg <= WDATA_mem_contlr_in;
          mem_contlr_wstrb_reg <= WSTRB_mem_contlr_in;
          mem_contlr_wlast_reg <= WLAST_mem_contlr_in;
          if(WVALID_mem_contlr_in && WREADY_mem_contlr_out)begin
            WREADY_mem_contlr_out <= 0;
            W_r_en <= 0;
            W_txn_state <= SEND_WDATA;
            WVALID_mem_contlr_out <= 1;
          end
          else begin
            W_txn_state <= WDATA_LATCH;
            WREADY_mem_contlr_out <= 1;
          end
        end
        
        SEND_WDATA: begin
          if (WREADY_mem_contlr_in && WVALID_mem_contlr_out) begin
            WVALID_mem_contlr_out <= 0;
            data_beat_counter <= data_beat_counter + 1;
            if (mem_contlr_wlast_reg) begin // LAST beat
//              if(burst_progress)begin
                burst_progress <= 0;
                W_r_en <= 0;
                burst_complete <= 1;
//                id_index = id_index + 1;
//                len_index = len_index + 1;
                WVALID_mem_contlr_out <= 0;           // Deasserting after handshake
                W_txn_state <= IDLE_W;
                data_beat_counter <= 0;
                WREADY_mem_contlr_out <= 1;
//              end
            end 
            else begin // Not last
              W_txn_state <= WDATA_LATCH;
              WREADY_mem_contlr_out <= 1;
              W_r_en <= 1;
              // Latching new values in WDATA_LATCH state
            end
          end
          else begin
            WVALID_mem_contlr_out <= 1;
            W_txn_state <= SEND_WDATA;
          end
        end
      endcase
    end
  end
  
  assign WDATA_mem_contlr_out = mem_contlr_wdata_reg;
  assign WSTRB_mem_contlr_out = mem_contlr_wstrb_reg;
  assign WLAST_mem_contlr_out = mem_contlr_wlast_reg;

 
 
 localparam stored_mem_width = BURST_LEN + ID;
 reg [stored_mem_width -1:0]stored_mem[ID -1:0];
 
 localparam stored_id_width = ID;
 localparam stored_awlen_width = BURST_LEN;
 localparam stored_id_lsb = 0;
 localparam stored_id_msb = (stored_id_lsb + stored_awlen_width) -1;
 localparam stored_awlen_lsb = stored_id_msb + 1;
 localparam stored_awlen_msb = (stored_awlen_lsb + stored_awlen_width) -1;
 
 reg [ID -1:0]b_index_count =0;
 reg [ID -1:0]b_read_count =0;
 reg valid_entry = 0;
 reg [BURST_LEN -1:0]valid_counter = 0;
 
// typedef enum logic [1:0]{B_IDLE, RECEIVE_BRESP, SEND_BRESP}B_txn_state_t;
// B_txn_state_t B_txn_state;
 reg [1:0]B_txn_state ;
 localparam B_IDLE = 2'b00;
 localparam RECEIVE_BRESP = 2'b01;
 localparam SEND_BRESP = 2'b10;
 
 
 
 //parameters for BRESP 
  localparam OKAY = 2'b00;    //OKAY 
  localparam EXOKAY = 2'b01;  //EXCLUSIVE OKAY
  localparam SLVERR = 2'b10;  //SLAVE ERROR
  localparam DECERR = 2'b11;  //DECODE ERROR
  
    always@(posedge mem_contlr_CLK) begin
      $display("%b - stored_memory_length", stored_mem[b_index_count - 1]);
      if ((AW_txn_state == LATCH_AW) && AWVALID_mem_contlr_in && AWREADY_mem_contlr_out) begin
        stored_mem[b_index_count]  <= {AWLEN_mem_contlr_in, AWID_mem_contlr_in};
        valid_entry <= 1;
        b_index_count <= (b_index_count == stored_id_width ) ? 0 : b_index_count + 1;
      end
    end
     
   always @(posedge mem_contlr_CLK)begin
     if(!mem_contlr_RST)begin
       b_index_count <= 0;
       b_read_count <= 0;
       valid_counter <= 0;
       valid_entry <= 0;
       BVALID_mem_contlr_out <= 0;
       BREADY_mem_contlr_out <= 1;
       B_txn_state <= B_IDLE;
     end
     else begin
       case(B_txn_state)
         B_IDLE:begin
           BREADY_mem_contlr_out <= 1;
           if(valid_entry)begin
             B_txn_state <= RECEIVE_BRESP;
           end
           else begin
             B_txn_state <= B_IDLE;
           end
         end
       
         RECEIVE_BRESP:begin
           if(BVALID_mem_contlr_in && BREADY_mem_contlr_out)begin
//             valid_counter <= valid_counter + 1;
             $display("%d - valid_counter", valid_counter);
             $display("%b - stored_memory_length", stored_mem[b_read_count][12:5]);
             if(valid_counter == stored_mem[b_read_count][12:5])begin
               B_txn_state <= SEND_BRESP;
               valid_counter <= 0;
                $display("%b - valid_counter", valid_counter);
               BVALID_mem_contlr_out <= 1;
             end
             else begin
               valid_counter <= valid_counter + 1;
               B_txn_state <= RECEIVE_BRESP; 
             end
           end
           else begin
             B_txn_state <= RECEIVE_BRESP; 
           end
         end
         
         SEND_BRESP:begin
           if(BREADY_mem_contlr_in && BVALID_mem_contlr_out)begin
             BVALID_mem_contlr_out <= 0;
             b_read_count <= b_read_count + 1;
             B_txn_state <= B_IDLE;
           end 
           else begin
             BVALID_mem_contlr_out <= 1;
             B_txn_state <= SEND_BRESP; 
           end
         end
       endcase
     end 
   end
   
  assign BID_mem_contlr_out = (B_txn_state == SEND_BRESP) ? stored_mem[b_read_count][stored_id_msb : stored_id_lsb] : 'z;
  assign BRESP_mem_contlr_out = (B_txn_state == SEND_BRESP) ? OKAY : SLVERR;
  
//  reg [BURST_LEN -1:0]stored_awlen;
//  reg [ID -1:0]stored_awid;
//  reg [BURST_LEN -1:0]valid_counter=0;
//  reg [BURST_LEN -1:0]stored_awlen[4:0];
//  reg [ID -1:0]stored_awid[4:0];
//  reg [ID -1:0]id_index=0;
//  reg [ID -1:0]len_index = 0;
//  reg [ID -1:0]index_read;
//  reg [ID -1:0]id_read_index;    
//  reg [1:0]B_txn_state;
//  localparam RECEIVE_BRESP = 2'b00;
//  localparam SEND_BRESP = 2'b01;
  
  //parameters for BRESP 
//  localparam OKAY = 2'b00;    //OKAY 
//  localparam EXOKAY = 2'b01;  //EXCLUSIVE OKAY
//  localparam SLVERR = 2'b10;  //SLAVE ERROR
//  localparam DECERR = 2'b11;  //DECODE ERROR
  
//  reg [2:0]write_ptr = 0;
//  reg [2:0]read_ptr = 0;
//  reg valid_entry[3:0];

//    always@(posedge mem_contlr_CLK) begin
//      if (!mem_contlr_RST) begin
//        write_ptr <= 0;
//        for (integer i = 0; i < 5; i = i + 1) begin
//          stored_awid[i]  <= 'bz;
//          stored_awlen[i] <= 'bz;
//          valid_entry[i]  <= 0;
//        end
//      end
//      else if ((AW_txn_state == LATCH_AW) && AWVALID_mem_contlr_in && AWREADY_mem_contlr_out) begin
//        stored_awid[write_ptr]  <= mem_contlr_awid_reg;
//        stored_awlen[write_ptr] <= mem_contlr_awlen_reg;
//        valid_entry[write_ptr]  <= 1;
//        write_ptr <= (write_ptr == 4) ? 0 : write_ptr + 1;
//      end
//    end
    

//    always@(posedge mem_contlr_CLK) begin
//      if (!mem_contlr_RST) begin
//        for(integer i=0;i<stored_awlen[write_ptr];i=i+1)
//          valid_entry[i] <= 0;
//      end
//      else if (AW_txn_state == LATCH_AW) begin
//        valid_entry[write_ptr] <= 1;
//      end
//      else if (B_txn_state == SEND_BRESP && BREADY_mem_contlr_in && BVALID_mem_contlr_out) begin
//        valid_entry[read_ptr] <= 0; // clear valid after BRESP sent
//      end
//    end


  
//  assign BRESP_mem_contlr_out = (BREADY_mem_contlr_in && BVALID_mem_contlr_out )? OKAY : SLVERR ;  
//  assign BID_mem_contlr_out = (BREADY_mem_contlr_in && BVALID_mem_contlr_out ) ? stored_awid[read_ptr] : 0; 
//  //B Channel
//  always@(posedge mem_contlr_CLK) begin
//    if(!mem_contlr_RST) begin
//        read_ptr <= 0;
//        write_ptr <= 0;
//        for(integer i=0; i<5; i=i+1) begin
//          stored_awlen[i] <= 'bz;
//          stored_awid[i] <= 'bz;
//        end

//        B_txn_state <= RECEIVE_BRESP;
//        BREADY_mem_contlr_out <= 1;
//        BVALID_mem_contlr_out <= 0;
//        valid_counter <= 0;
//    end 
//    else begin
//      case(B_txn_state)
//        RECEIVE_BRESP: begin
////          if(valid_entry[read_ptr])begin
//            BREADY_mem_contlr_out <= 1;
//            if(BVALID_mem_contlr_in && BREADY_mem_contlr_out) begin
//              valid_counter <= valid_counter + 1;
//              if(valid_counter + 1== stored_awlen[read_ptr]) begin
//                BVALID_mem_contlr_out <= 1;
//                valid_counter <= 0;
//                B_txn_state <= SEND_BRESP;
//              end
//              else begin
//                BVALID_mem_contlr_out <= 0;
//                B_txn_state <= RECEIVE_BRESP;
//              end
//            end
//            else begin
//            BREADY_mem_contlr_out <= 1;
//            B_txn_state <= RECEIVE_BRESP;
//            end
////          end
////          else begin
////            BREADY_mem_contlr_out <= 1;
////            B_txn_state <= RECEIVE_BRESP;
////          end
//        end
//        SEND_BRESP: begin
//          if(BREADY_mem_contlr_in && BVALID_mem_contlr_out) begin
//            BVALID_mem_contlr_out <= 0;
//            read_ptr <= (read_ptr == 4) ? 0 : read_ptr + 1;
//            B_txn_state <= RECEIVE_BRESP;
//          end
//        end
//       endcase
//     end
//   end

//  reg [BURST_LEN-1:0] valid_counter = 0;
//    reg [BURST_LEN-1:0] stored_awlen[4:0];
//    reg [ID-1:0] stored_awid[4:0];
//    reg [1:0] B_txn_state;
    
//    localparam RECEIVE_BRESP = 2'b00;
//    localparam SEND_BRESP    = 2'b01;
    
//    localparam OKAY   = 2'b00;
//    localparam SLVERR = 2'b10;
    
//    reg [2:0] write_ptr = 0;
//    reg [2:0] read_ptr = 0;
    
//    reg valid_entry[4:0];
    
//    // Write block gated with handshake
//    always@(posedge mem_contlr_CLK) begin
//      if (!mem_contlr_RST) begin
//        write_ptr <= 0;
//        for (integer i = 0; i < 5; i = i + 1) begin
//          stored_awid[i]  <= 'bz;
//          stored_awlen[i] <= 'bz;
//          valid_entry[i]  <= 0;
//        end
//      end
//      else if ((AW_txn_state == LATCH_AW) && AWVALID_mem_contlr_in && AWREADY_mem_contlr_out) begin
//        stored_awid[write_ptr]  <= mem_contlr_awid_reg;
//        stored_awlen[write_ptr] <= mem_contlr_awlen_reg;
//        valid_entry[write_ptr]  <= 1;
//        write_ptr <= (write_ptr == 4) ? 0 : write_ptr + 1;
//      end
//    end
    
//    // BRESP outputs
//    assign BRESP_mem_contlr_out = BVALID_mem_contlr_out ? OKAY : SLVERR;
//    assign BID_mem_contlr_out   = BVALID_mem_contlr_out ? stored_awid[read_ptr] : 0;
    
//    // B channel FSM - Corrected and Robust Logic
//    assign BRESP_mem_contlr_out = (BREADY_mem_contlr_in && BVALID_mem_contlr_out )? OKAY : SLVERR ;  
//    assign BID_mem_contlr_out = (BREADY_mem_contlr_in && BVALID_mem_contlr_out ) ? stored_awid[read_ptr] : 0; 
//      //B Channel
//      always@(posedge mem_contlr_CLK) begin
//        if(!mem_contlr_RST) begin
//            read_ptr <= 0;
//            write_ptr <= 0;
//            for(integer i=0; i<stored_awlen[write_ptr]; i=i+1) begin
//                stored_awlen[i] <= 1'bz;
//                stored_awid[i]  <= 1'bz;
//            end
//            B_txn_state <= RECEIVE_BRESP;
//            BREADY_mem_contlr_out <= 1;
//            BVALID_mem_contlr_out <= 0;
//            valid_counter <= 0;
//        end 
//        else begin
//          case(B_txn_state)
//            RECEIVE_BRESP: begin
//              if(valid_entry[read_ptr])begin
//                BREADY_mem_contlr_out <= 1;
//                if(BVALID_mem_contlr_in && BREADY_mem_contlr_out) begin
//                  valid_counter <= valid_counter + 1;
//                  if(valid_counter == stored_awlen[read_ptr]) begin
//                    BVALID_mem_contlr_out <= 1;
//                    B_txn_state <= SEND_BRESP;
//                  end
//                  else begin
//                    BVALID_mem_contlr_out <= 0;
//                    B_txn_state <= RECEIVE_BRESP;
//                  end
//                end
//                else begin
//                BREADY_mem_contlr_out <= 1;
//                B_txn_state <= RECEIVE_BRESP;
//                end
//              end
//              else begin
//                BREADY_mem_contlr_out <= 1;
//                B_txn_state <= RECEIVE_BRESP;
//              end
//            end
//            SEND_BRESP: begin
//              if(BREADY_mem_contlr_in && BVALID_mem_contlr_out) begin
//                BVALID_mem_contlr_out <= 0;
//                valid_counter <= 0;
//                write_ptr <= 0;
//                read_ptr <= read_ptr + 1; // move to next transaction
//                B_txn_state <= RECEIVE_BRESP;
//              end
//            end
//           endcase
//         end
//       end


  
 
  
  wire [WRAP_WIDTH -1:0]r_wrap_boundary_mask;
  reg [BURST_LEN -1:0]mem_contlr_rburst_counter;
  
  reg rburst_progress = 0;
  reg rburst_complete = 1;
  reg [ADDR_WIDTH -1:0]incr_raddr_reg;
  reg [ADDR_WIDTH -1:0]base_raddr_reg;
  reg [ADDR_WIDTH -1:0]wrap_raddr_reg;
  reg [ADDR_WIDTH -1:0]starting_raddr_reg;
  reg [ADDR_WIDTH -1:0]next_raddr_reg;
  reg [BURST_TYPE -1:0]mem_contlr_rburst_type_reg;
  reg [BURST_LEN -1:0]mem_contlr_arlen_reg;
  reg [BEAT_SIZE -1:0]mem_contlr_rbeat_size_reg;
  reg [ID -1:0]mem_contlr_arid_reg;
  
  reg [1:0]AR_txn_state;
  localparam IDLE_AR = 2'b00;
  localparam LATCH_AR = 2'b01;
  localparam SEND_AR = 2'b10;
  localparam RBURST_ADDR = 2'b11;
  
  assign r_wrap_boundary_mask = (AR_txn_state == LATCH_AR)? ((1 << ARSIZE_mem_contlr_in) * (ARLEN_mem_contlr_in + 1) ) - 1 : 0;
  
  //AR Channel 
  always @(posedge mem_contlr_CLK)begin
    if(!mem_contlr_RST)begin
      //control signal Initialisation
      AR_r_en <= 0;
      //initialization of AR Channel flip-flop registers 
      incr_raddr_reg <= 0;
      base_raddr_reg <= 0;
      wrap_raddr_reg <= 0;
      starting_raddr_reg <= 0;
      next_raddr_reg <= 0;
      mem_contlr_rburst_type_reg <= 0;
      mem_contlr_arlen_reg <= 0;
      mem_contlr_rbeat_size_reg <= 0;
      mem_contlr_arid_reg <= 0;
      rburst_complete <= 1;
      rburst_progress <= 0;
      //initialization of counters
      mem_contlr_rburst_counter <= 0;
      //FSM's initialization   
      AR_txn_state <= IDLE_AR;
      //Initialization of AXI Interface Signals (READY && VALID)
      ARVALID_mem_contlr_out <= 0;
      ARREADY_mem_contlr_out <= 0;
    end
    else begin
      case(AR_txn_state)
        IDLE_AR:begin
          if(rburst_complete && !AR_fifo_empty_in)begin
            ARREADY_mem_contlr_out <= 1;
            AR_txn_state <= LATCH_AR;
            mem_contlr_rburst_counter <= 0;
            incr_raddr_reg <= 0;
            starting_raddr_reg <= 0;
            base_raddr_reg <= 0;
            next_raddr_reg <= 0;
          end
          else begin
            ARREADY_mem_contlr_out <= 0;
            AR_txn_state <= IDLE_AR;
          end
        end
        
        LATCH_AR:begin
          AR_r_en <= 1;
          if(ARVALID_mem_contlr_in && ARREADY_mem_contlr_out)begin
            base_raddr_reg <= ARADDR_mem_contlr_in;
            starting_raddr_reg <= ARADDR_mem_contlr_in;
            mem_contlr_rburst_type_reg <= ARBURST_mem_contlr_in;
            mem_contlr_arlen_reg <= ARLEN_mem_contlr_in;
            mem_contlr_rbeat_size_reg <= ARSIZE_mem_contlr_in;
            mem_contlr_arid_reg <= ARID_mem_contlr_in;
            AR_txn_state <= RBURST_ADDR;
            ARREADY_mem_contlr_out <= 0;
            rburst_progress <= 1;
            rburst_complete <= 0;
            AR_r_en <= 0;
          end
          else begin
            AR_txn_state <= LATCH_AR;
            ARREADY_mem_contlr_out <= 1;
            ARVALID_mem_contlr_out <= 0;
          end
        end
        
        RBURST_ADDR:begin
          if(mem_contlr_rburst_counter <= mem_contlr_arlen_reg)begin
            ARVALID_mem_contlr_out <= 1;
            ARBURST_mem_contlr_out <= mem_contlr_rburst_type_reg;
            ARLEN_mem_contlr_out <= mem_contlr_arlen_reg;
            ARSIZE_mem_contlr_out <= mem_contlr_rbeat_size_reg;
            ARID_mem_contlr_out <= mem_contlr_arid_reg;
            case(mem_contlr_rburst_type_reg)
              FIXED_BURST:begin
                ARADDR_mem_contlr_out <= base_raddr_reg;
                if(ARREADY_mem_contlr_in && ARVALID_mem_contlr_out && ECC_DE_complete)begin
                  ARVALID_mem_contlr_out <= 0;
                  mem_contlr_rburst_counter <= mem_contlr_rburst_counter + 1;
                  AR_txn_state <= RBURST_ADDR;
                end
              end
            
              INCR_BURST:begin
                incr_raddr_reg <= starting_raddr_reg + (1 << mem_contlr_rbeat_size_reg);
                ARADDR_mem_contlr_out <= starting_raddr_reg;
                if(ARREADY_mem_contlr_in && ARVALID_mem_contlr_out && ECC_DE_complete)begin
                  starting_raddr_reg <= incr_raddr_reg;
                  ARVALID_mem_contlr_out <= 0;
                  mem_contlr_rburst_counter <= mem_contlr_rburst_counter + 1;
                  AR_txn_state <= RBURST_ADDR;
                end
              end
            
              WRAP_BURST:begin
                //NEXT address logic
                next_raddr_reg <= starting_raddr_reg + (1 << mem_contlr_rbeat_size_reg);
              
                //Applying WRAP Boundary Condition
                if((next_raddr_reg & ~r_wrap_boundary_mask) != (base_raddr_reg & ~r_wrap_boundary_mask))begin
                  wrap_raddr_reg <= (base_raddr_reg & ~r_wrap_boundary_mask) | (next_raddr_reg & r_wrap_boundary_mask);
                end
                else begin
                  wrap_raddr_reg <= next_raddr_reg;
                end
                ARADDR_mem_contlr_out <= starting_raddr_reg;
                if(ARREADY_mem_contlr_in && ARVALID_mem_contlr_out && ECC_DE_complete)begin
                  starting_raddr_reg <= next_raddr_reg;
                  mem_contlr_rburst_counter <= mem_contlr_rburst_counter + 1;
                  AR_txn_state <= RBURST_ADDR;
                  ARVALID_mem_contlr_out <= 0;
                end
              end
            endcase
          end
          else begin
            AR_txn_state <= IDLE_AR;
            mem_contlr_rburst_counter <= 0;
          end
        end
      endcase
    end
  end
  
  reg [DATA_WIDTH -1:0]rdata_reg;
//  reg [ID -1:0]rid_reg;
  reg rlast_reg;
  reg [BURST_LEN -1:0]rdata_beat_counter;
  
  reg [1:0]R_txn_state;
//  localparam R_IDLE = 2'b00;
  localparam R_LATCH = 2'b01;
  localparam SEND_RDATA  = 2'b10;
  
  
  //R Channel
  always@(posedge mem_contlr_CLK)begin
    if(!mem_contlr_RST)begin
      //initialization of R Channel flip-flop registers
      rdata_reg <= 0;
      rlast_reg <= 0;
      R_txn_state <= R_LATCH;
      rdata_beat_counter <= 0;
      RVALID_mem_contlr_out <= 0;
      RREADY_mem_contlr_out <= 1;
    end
    else begin
      case(R_txn_state)
        R_LATCH:begin
          rdata_reg <= RDATA_mem_contlr_in;
          rlast_reg <=0;
          if(RVALID_mem_contlr_in && RREADY_mem_contlr_out)begin
//            RREADY_mem_contlr_out <= 0;
            R_txn_state <= SEND_RDATA;
            RVALID_mem_contlr_out <= 1;
            $display("read data - %h:",rdata_reg);
          end
          else begin
            RREADY_mem_contlr_out <= 1;
            R_txn_state <= R_LATCH;
          end
        end
        
        SEND_RDATA: begin
          if (RVALID_mem_contlr_out && RREADY_mem_contlr_in) begin
            RVALID_mem_contlr_out <= 0;
            rdata_beat_counter <= rdata_beat_counter + 1;
            if (rdata_beat_counter == mem_contlr_arlen_reg) begin // LAST beat
                rburst_progress <= 0;
                rburst_complete <= 1;
                rlast_reg <= 1;
                RVALID_mem_contlr_out <= 0;           // Deasserting after handshake
                R_txn_state <= R_LATCH;
                rdata_beat_counter <= 0;
                WREADY_mem_contlr_out <= 1;
            end 
            else begin // Not last
              R_txn_state <= R_LATCH;
              RREADY_mem_contlr_out <= 1;
              // Latching new values in R_LATCH state
            end
          end
          else begin
            RVALID_mem_contlr_out <= 1;
            R_txn_state <= SEND_RDATA;
          end
        end
      endcase
    end
  end
  always@(*) begin
    $monitor("[%0t] RVALID_IN=%b, RREADY_OUT=%b, ", $time, RVALID_mem_contlr_in, RREADY_mem_contlr_out);
  end

  assign RDATA_mem_contlr_out = rdata_reg;
  assign RID_mem_contlr_out = mem_contlr_arid_reg;
  assign RLAST_mem_contlr_out = (R_txn_state == SEND_RDATA && rdata_beat_counter == mem_contlr_arlen_reg);
  
  
endmodule    
        
        


