`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.06.2025 16:12:44
// Design Name: 
// Module Name: Interconnect_test_dsgn
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

module Interconnect_test_dsgn #(
                                 parameter DATA_WIDTH=32,
                                 parameter STRB_WIDTH=(DATA_WIDTH/8), 
                                 parameter ADDR_WIDTH=32, 
                                 parameter BURST_TYPE=2, 
                                 parameter BURST_LEN=8, 
                                 parameter BEAT_SIZE=3, 
                                 parameter RESP_WIDTH=2, 
                                 parameter ID=5, 
                                 parameter BYTE_COUNT=8, 
                                 parameter addr_mem_width = 50,
                                 parameter data_mem_width = 37,
                                 parameter raddr_mem_width = 50,
                                 
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
    //clock and reset signals 
    input ACLK,
    input ARESETn,
    
    // AXI MASTER to AXI INTERCONNECT i/p and o/p pins
    input [ADDR_WIDTH-1:0] I_in_AWADDR,
    input [BURST_TYPE -1:0]I_in_AWBURST,
    input [BURST_LEN-1:0]  I_in_AWLEN,
    input [BEAT_SIZE-1:0]  I_in_AWSIZE,
    input [ID -1:0]        I_in_AWID,
    
    input                  I_in_AWVALID,
    
    input                  AXI4_in_AWREADY,
    
    input                  lite_in_AWREADY,  
    
    output reg AXI4_out_AWVALID,
    output reg lite_out_AWVALID,
    
    output reg I_out_AWREADY,      //Interconnect o/p port AWREADY to Master
    
    // AXI Interconnect i/p & o/p pins to AXI4 INTERFACE 
    output reg [ADDR_WIDTH-1:0] AXI4_out_AWADDR,  
    output reg [BURST_TYPE -1:0]AXI4_out_AWBURST,
    output reg [BURST_LEN-1:0]  AXI4_out_AWLEN,
    output reg [BEAT_SIZE-1:0]  AXI4_out_AWSIZE,
    output reg [ID -1:0]        AXI4_out_AWID,
    
    // AXI Interconnect i/p & o/p pins to AXI-LITE INTERFACE 
    output reg [ADDR_WIDTH-1:0] lite_out_AWADDR,
    output reg [BURST_TYPE -1:0]lite_out_AWBURST,
    output reg [BURST_LEN-1:0]  lite_out_AWLEN,
    output reg [BEAT_SIZE-1:0]  lite_out_AWSIZE,
    output reg [ID -1:0]        lite_out_AWID,
    
    // AXI MASTER to AXI INTERCONNECT i/p pins
    input [DATA_WIDTH-1:0]      I_in_WDATA,
    input [(DATA_WIDTH/8) -1:0] I_in_WSTRB,
    input                       I_in_WLAST,
    input  wire                 I_in_WVALID,
    output reg I_out_WREADY,
    
    input AXI4_in_WREADY,
    input lite_in_WREADY,
    
    output reg AXI4_out_WVALID,
    output reg lite_out_WVALID,
    
    //AXI INTERCONNECT to AXI4 Interface signals
    output reg[DATA_WIDTH-1:0]     AXI4_out_WDATA,
    output reg[(DATA_WIDTH/8) -1:0]AXI4_out_WSTRB,
    output reg                     AXI4_out_WLAST,
    
    
    //AXI INTERCONNECT to AXI-LITE Interface signals
    output reg[DATA_WIDTH-1:0]     lite_out_WDATA,
    output reg[(DATA_WIDTH/8) -1:0]lite_out_WSTRB,
    output reg                     lite_out_WLAST,
              
    
    output reg [RESP_WIDTH -1:0] I_out_BRESP,
    output reg [ID -1:0] I_out_BID,
    input I_in_BREADY,
    output reg I_out_BVALID,
    
    input [RESP_WIDTH -1:0]AXI4_in_BRESP,
    input [ID -1:0]  AXI4_in_BID,
    input            AXI4_in_BVALID,
    output reg AXI4_out_BREADY,
    
    input [RESP_WIDTH -1:0]lite_in_BRESP,
    input [ID -1:0]lite_in_BID,
    input          lite_in_BVALID,
    output reg lite_out_BREADY,
      
        
    input [ADDR_WIDTH-1:0] I_in_ARADDR,
    input [BURST_TYPE -1:0]I_in_ARBURST,
    input [BURST_LEN-1:0]  I_in_ARLEN,
    input [BEAT_SIZE-1:0]  I_in_ARSIZE,
    input [ID -1:0]        I_in_ARID,
    
    input                  I_in_ARVALID,
    
    input                  AXI4_in_ARREADY,
    
    input                  lite_in_ARREADY,  
    
    output reg AXI4_out_ARVALID,
    output reg lite_out_ARVALID,
    
    output reg I_out_ARREADY,      //Interconnect o/p port AWREADY to Master
    
    // AXI Interconnect i/p & o/p pins to AXI4 INTERFACE 
    output reg [ADDR_WIDTH-1:0] AXI4_out_ARADDR,  
    output reg [BURST_TYPE -1:0]AXI4_out_ARBURST,
    output reg [BURST_LEN-1:0]  AXI4_out_ARLEN,
    output reg [BEAT_SIZE-1:0]  AXI4_out_ARSIZE,
    output reg [ID -1:0]        AXI4_out_ARID,
    
    // AXI Interconnect i/p & o/p pins to AXI-LITE INTERFACE 
    output reg [ADDR_WIDTH-1:0] lite_out_ARADDR,
    output reg [BURST_TYPE -1:0]lite_out_ARBURST,
    output reg [BURST_LEN-1:0]  lite_out_ARLEN,
    output reg [BEAT_SIZE-1:0]  lite_out_ARSIZE,
    output reg [ID -1:0]        lite_out_ARID,
 
    output reg [DATA_WIDTH-1:0] I_out_RDATA,
    output reg [ID -1:0]I_out_RID,
    output reg I_out_RLAST,
    input I_in_RREADY,
    output reg I_out_RVALID,
    
    input [DATA_WIDTH -1:0]AXI4_in_RDATA,
    input [ID -1:0]AXI4_in_RID,
    input AXI4_in_RLAST,
    output reg AXI4_out_RREADY,
    input AXI4_in_RVALID,
    
    input [DATA_WIDTH -1:0]lite_in_RDATA,
    input [ID -1:0]lite_in_RID,
    input lite_in_RLAST,
    output reg lite_out_RREADY,
    input lite_in_RVALID
     
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
  
//  reg [ADDR_WIDTH -1:0]addr_reg;
//  reg [BURST_TYPE -1:0]burst_type_reg;
//  reg [BURST_LEN -1:0]burst_len_reg;
//  reg [BEAT_SIZE -1:0]beat_size_reg;
//  reg [ID -1:0]awid_reg;


  reg AXI4_write_en = 0;
  reg lite_write_en = 0;
  reg burst_txn_complete = 1;
  reg lite_txn_complete = 1;
  reg [ID -1:0]aw_index_count;
  reg [addr_mem_width -1:0]addr_mem[ADDR_WIDTH/2 -1:0];
  reg [ID -1:0]aw_read_count;
  
  typedef enum logic[1:0]{AW_IDLE, AW_ADDR_DECODE, ROUTE_AXI, ROUTE_LITE}write_addr_state_t;
  write_addr_state_t write_addr_state;
  
  always@(posedge ACLK)begin
    if(!ARESETn)begin
      aw_index_count <= 0;
      AXI4_out_AWVALID <= 0;
      lite_out_AWVALID <= 0;
      I_out_AWREADY <= 0;
      write_addr_state <= AW_IDLE;
      AXI4_write_en <= 1;
      lite_write_en <= 1;
    end
    else begin
      case(write_addr_state)
        AW_IDLE:begin
          I_out_AWREADY <= 1;
          if(I_in_AWVALID && I_out_AWREADY && burst_txn_complete)begin
            addr_mem[aw_index_count]<={I_in_AWADDR, I_in_AWBURST, I_in_AWLEN, I_in_AWSIZE, I_in_AWID};
            burst_txn_complete <= 0;
            aw_read_count <= aw_index_count;
            aw_index_count <= aw_index_count + 1;
            I_out_AWREADY <= 0; 
            write_addr_state <= AW_ADDR_DECODE;
          end
          else begin
            I_out_AWREADY <= 1;
            write_addr_state <= AW_IDLE;
          end
        end
        
        AW_ADDR_DECODE:begin
          if(addr_mem[aw_read_count][AWADDR_MSB : AWADDR_LSB] >= BRAM_BASE_ADDR && addr_mem[aw_read_count][AWADDR_MSB : AWADDR_LSB] <= BRAM_END_ADDR)begin
            AXI4_write_en <= 1;
            lite_write_en <= 0;
            AXI4_out_AWVALID <= 1;
            write_addr_state <= ROUTE_AXI;
          end
          else if(addr_mem[aw_read_count][AWADDR_MSB : AWADDR_LSB] >= SLAVE_CONTLR_BASE_ADDR && addr_mem[aw_read_count][AWADDR_MSB : AWADDR_LSB] <= SLAVE_CONTLR_END_ADDR)begin
             lite_write_en <= 1;
             AXI4_write_en <= 0;
             lite_out_AWVALID <= 1;
             write_addr_state <= ROUTE_LITE;
          end             
          else begin
            write_addr_state <=  AW_IDLE;
            I_out_AWREADY <= 1;
          end
        end
        
        ROUTE_AXI:begin
          if(AXI4_in_AWREADY && AXI4_out_AWVALID)begin
            AXI4_out_AWVALID <= 0;
            write_addr_state <= AW_IDLE;
            I_out_AWREADY = 1;
          end
          else begin
            AXI4_out_AWVALID <= 1;
            write_addr_state <= ROUTE_AXI;
          end
        end
        
        ROUTE_LITE:begin
          if(lite_in_AWREADY && lite_out_AWVALID)begin
            lite_out_AWVALID <= 0;
            write_addr_state <= AW_IDLE;
            I_out_AWREADY <= 0;
          end
          else begin
            lite_out_AWVALID <= 1;
            write_addr_state <= ROUTE_LITE;
          end
        end
      endcase
    end
  end
          
  assign AXI4_out_AWADDR = (write_addr_state == ROUTE_AXI)? addr_mem[aw_read_count][AWADDR_MSB : AWADDR_LSB] : 0;
  assign AXI4_out_AWBURST = (write_addr_state == ROUTE_AXI)? addr_mem[aw_read_count][AWBURST_MSB : AWBURST_LSB] : 0;
  assign AXI4_out_AWLEN = (write_addr_state == ROUTE_AXI) ? addr_mem[aw_read_count][AWLEN_MSB : AWLEN_LSB] : 0;
  assign AXI4_out_AWSIZE = (write_addr_state == ROUTE_AXI) ? addr_mem[aw_read_count][AWSIZE_MSB : AWSIZE_LSB] : 0; 
  assign AXI4_out_AWID = (write_addr_state == ROUTE_AXI) ? addr_mem[aw_read_count][ID_MSB : ID_LSB] : 0;

  assign lite_out_AWADDR = (write_addr_state == ROUTE_LITE)? addr_mem[aw_read_count][AWADDR_MSB : AWADDR_LSB] : 0;
  assign lite_out_AWBURST = (write_addr_state == ROUTE_LITE)? addr_mem[aw_read_count][AWBURST_MSB : AWBURST_LSB] : 0;
  assign lite_out_AWLEN = (write_addr_state == ROUTE_LITE) ? addr_mem[aw_read_count][AWLEN_MSB : AWLEN_LSB] : 0;
  assign lite_out_AWSIZE = (write_addr_state == ROUTE_LITE) ? addr_mem[aw_read_count][AWSIZE_MSB : AWSIZE_LSB] : 0; 
  assign lite_out_AWID = (write_addr_state == ROUTE_LITE) ? addr_mem[aw_read_count][ID_MSB : ID_LSB] : 0;
  
//  reg [DATA_WIDTH -1:0]data_reg;
//  reg [STRB_WIDTH -1:0]strb_reg;
//  reg last_reg;
  localparam WDATA_WIDTH = DATA_WIDTH ;
  localparam WSTRB_WIDTH = STRB_WIDTH ;

  localparam DATA_LSB = 0;
  localparam DATA_MSB = DATA_LSB + DATA_WIDTH - 1;

  localparam STRB_LSB = DATA_MSB + 1;
  localparam STRB_MSB = STRB_LSB + STRB_WIDTH - 1;

  localparam W_TOTAL_WIDTH   = STRB_MSB + 1;
  
reg [data_mem_width -1:0]data_mem[DATA_WIDTH/2 -1:0];
reg [ID -1:0]w_index_count=0;
reg [ID -1:0]w_read_count=0;
reg [BURST_LEN -1:0]beat_count=0;

  typedef enum logic[1:0]{W_IDLE, ROUTE_AXI_DATA, ROUTE_LITE_DATA}write_data_state_t;
  write_data_state_t write_data_state;
  
  
  always@(posedge ACLK)begin
    if(!ARESETn)begin
      w_index_count <= 0;
      w_read_count <= 0;
      beat_count <= 0;
      AXI4_out_WVALID <= 0;
      lite_out_WVALID <= 0;
      I_out_WREADY <= 0;
      write_data_state <= W_IDLE;
    end
    else begin
      case (write_data_state)
        W_IDLE: begin
          I_out_WREADY <= 1;  // ready to accept from input
          if (I_in_WVALID && I_out_WREADY) begin
            data_mem[w_index_count] <= {I_in_WLAST, I_in_WSTRB, I_in_WDATA};   // Latch data from input
            w_read_count <= w_index_count;
//            w_index_count <= w_index_count + 1;  
            if (AXI4_write_en)begin
//              data_mem[w_index_count] <= {I_in_WLAST, I_in_WSTRB, I_in_WDATA};   // Latch data from input
//              w_read_count <= w_index_count;
//              w_index_count <= w_index_count + 1;
              AXI4_out_WVALID <= 1;
              write_data_state <= ROUTE_AXI_DATA;
            end
            else if (lite_write_en)begin
              lite_out_WVALID <= 1;
              write_data_state <= ROUTE_LITE_DATA;
            end
          end
          else begin
            I_out_WREADY <= 1;
            write_data_state <= W_IDLE;
          end
        end
        
        ROUTE_AXI_DATA: begin
//          AXI4_out_WVALID <= 1;
          if (AXI4_out_WVALID && AXI4_in_WREADY) begin
            AXI4_out_WVALID <= 0;
            w_index_count <= w_index_count + 1;
//            AXI4_out_WDATA = data_mem[w_read_count][DATA_MSB : DATA_LSB];
//            AXI4_out_WSTRB = data_mem[w_read_count][STRB_MSB : STRB_LSB] ;
//            AXI4_out_WLAST = data_mem[w_read_count][STRB_MSB + 1] ;
            beat_count <= beat_count + 1;
            if(AXI4_out_WLAST)begin
              burst_txn_complete <= 1;
              beat_count <= 0 ;
              write_data_state <= W_IDLE;
            end
            else begin
              burst_txn_complete <= 0;
              write_data_state <= W_IDLE;
            end
          end
          else begin
            AXI4_out_WVALID <= 1;
            write_data_state <= ROUTE_AXI_DATA;
          end
        end
        
        ROUTE_LITE_DATA:begin
          if(lite_out_WVALID && lite_in_WREADY)begin
            lite_out_WVALID <= 0;
            beat_count <= beat_count + 1;
            write_data_state <= W_IDLE;
            if(AXI4_out_WLAST)begin
              burst_txn_complete <= 1;
              beat_count <= 0 ;
              write_data_state <= W_IDLE;
            end
            else begin
              burst_txn_complete <= 0;
              write_data_state <= W_IDLE;
            end
          end
          else begin
            lite_out_WVALID <= 1;
            write_data_state <= ROUTE_LITE_DATA;
          end
        end
      endcase
    end
  end
  
  assign AXI4_out_WDATA = (write_data_state == ROUTE_AXI_DATA) ? data_mem[w_read_count][DATA_MSB : DATA_LSB] : 0;
  assign AXI4_out_WSTRB = (write_data_state == ROUTE_AXI_DATA) ? data_mem[w_read_count][STRB_MSB : STRB_LSB] : 0;
  assign AXI4_out_WLAST = (write_data_state == ROUTE_AXI_DATA) ? data_mem[w_read_count][STRB_MSB + 1] : 0;
  
  assign lite_out_WDATA = (write_data_state == ROUTE_LITE_DATA) ? data_mem[w_read_count][DATA_MSB : DATA_LSB] : 0;
  assign lite_out_WSTRB = (write_data_state == ROUTE_LITE_DATA) ? data_mem[w_read_count][STRB_MSB : STRB_LSB] : 0;
  assign lite_out_WLAST = (write_data_state == ROUTE_LITE_DATA) ? data_mem[w_read_count][STRB_MSB + 1] : 0;
  
  
//  reg [RESP_WIDTH -1:0]resp_reg;
//  reg [ID -1:0]bid_reg;
  
  typedef enum logic[1:0]{B_IDLE, AXI4_RESP, LITE_RESP}write_resp_state_t;
  write_resp_state_t write_resp_state;
  
  always@(posedge ACLK)begin
    if(!ARESETn)begin
//      resp_reg <= 0;
//      bid_reg <= 0;
      I_out_BVALID <= 0;
      AXI4_out_BREADY <= 1;
      lite_out_BREADY <= 1;
      write_resp_state <= B_IDLE;
    end
    else begin
      case(write_resp_state)
        B_IDLE:begin
          AXI4_out_BREADY <= 1;
          lite_out_BREADY <= 1;
          if(AXI4_in_BVALID && AXI4_out_BREADY)begin
//            resp_reg <= AXI4_in_BRESP;
//            bid_reg <= AXI4_in_BID;
//            AXI4_out_BREADY <= 0;
            write_resp_state <= AXI4_RESP;
          end
          else if(lite_in_BVALID && lite_out_BREADY)begin
//            resp_reg <= lite_in_BRESP;
//            bid_reg <= lite_in_BID;
            lite_out_BREADY <= 1;
            write_resp_state <= LITE_RESP;
          end
          else begin
            write_resp_state <= B_IDLE;
          end
        end
        
        AXI4_RESP:begin
//          I_out_BVALID <= 1;
          if(I_in_BREADY && I_out_BVALID)begin
//            I_out_BRESP <= resp_reg;
//            I_out_BID <= bid_reg;
//            I_out_BVALID <= 0;
            write_resp_state <= B_IDLE;
          end
          else begin
//            I_out_BVALID <= 1;
            write_resp_state <= AXI4_RESP;
          end
        end
        
        LITE_RESP:begin
//          I_out_BVALID <= 1;
          if(I_in_BREADY && I_out_BVALID)begin
//            I_out_BRESP <= resp_reg;
//            I_out_BID <= bid_reg;
//            I_out_BVALID <= 0;
            write_resp_state <= B_IDLE;
          end
          else begin
//            I_out_BVALID <= 1;
            write_resp_state <= LITE_RESP;
          end
        end           
      endcase
    end
  end 
  
  assign I_out_BVALID = (I_in_BREADY ==1)? AXI4_in_BVALID : 0;
  assign I_out_BRESP = (I_in_BREADY ==1)?  AXI4_in_BRESP : 'z;
  assign I_out_BID = (I_in_BREADY ==1)?  AXI4_in_BID : 'z;
  
  
  
  
  localparam ARID_WIDTH = ID;
  localparam ARADDR_WIDTH = ADDR_WIDTH;
  localparam ARBURST_WIDTH = BURST_TYPE;
  localparam ARLEN_WIDTH = BURST_LEN;
  localparam ARSIZE_WIDTH = BEAT_SIZE;
  
  localparam ARID_LSB        = 0;
  localparam ARID_MSB        = ID_LSB + ID - 1;

  localparam ARSIZE_LSB    = ID_MSB + 1;
  localparam ARSIZE_MSB    = ARSIZE_LSB + ARSIZE_WIDTH - 1;
    
  localparam ARLEN_LSB     = ARSIZE_MSB + 1;
  localparam ARLEN_MSB     = ARLEN_LSB + ARLEN_WIDTH - 1;
    
  localparam ARBURST_LSB   = ARLEN_MSB + 1;
  localparam ARBURST_MSB   = ARBURST_LSB + ARBURST_WIDTH - 1;
    
  localparam ARADDR_LSB    = ARBURST_MSB + 1;
  localparam ARADDR_MSB    = ARADDR_LSB + ARADDR_WIDTH - 1;
    
  localparam AR_TOTAL_WIDTH   = ARADDR_MSB + 1;
  
  

  reg AXI4_read_en = 1;
  reg lite_read_en = 1;
  reg rburst_txn_complete = 1;
  reg rlite_txn_complete = 1;
  reg [ID -1:0]ar_index_count=0;
  reg [ID -1:0]ar_read_count=0;
  reg [raddr_mem_width -1:0]raddr_mem[ADDR_WIDTH/2 -1:0];
  
  typedef enum logic[1:0]{AR_IDLE, AR_ADDR_DECODE, AR_ROUTE_AXI, AR_ROUTE_LITE}read_raddr_state_t;
  read_raddr_state_t read_raddr_state;
  
  always@(posedge ACLK)begin
    if(!ARESETn)begin
      ar_index_count <= 0;
      ar_read_count <= 0;
      AXI4_out_ARVALID <= 0;
      lite_out_ARVALID <= 0;
      I_out_ARREADY <= 0;
      read_raddr_state <= AR_IDLE;
      AXI4_read_en <= 1;
      lite_read_en <= 1;
    end
    else begin
      case(read_raddr_state)
        AR_IDLE:begin
          I_out_ARREADY <= 1;
          if(I_in_ARVALID && I_out_ARREADY && rburst_txn_complete)begin
            raddr_mem[ar_index_count]<={I_in_ARADDR, I_in_ARBURST, I_in_ARLEN, I_in_ARSIZE, I_in_ARID};
            ar_read_count <= ar_index_count;
            ar_index_count <= ar_index_count + 1;
//            I_out_ARREADY <= 0;
            read_raddr_state <= AR_ADDR_DECODE;
//            rburst_txn_complete <= 0;
          end
          else begin
            I_out_ARREADY <= 1;
            read_raddr_state <= AR_IDLE;
          end
        end
        
        AR_ADDR_DECODE:begin
          if(raddr_mem[ar_read_count][ARADDR_MSB : ARADDR_LSB] >= BRAM_BASE_ADDR && raddr_mem[ar_read_count][ARADDR_MSB : ARADDR_LSB] <= BRAM_END_ADDR)begin
            AXI4_read_en <= 1;
            lite_read_en <= 0;
            I_out_ARREADY <= 0; 
            AXI4_out_ARVALID <= 1;
            read_raddr_state <= AR_ROUTE_AXI;
          end
          else if(raddr_mem[ar_read_count][ARADDR_MSB : ARADDR_LSB] >= SLAVE_CONTLR_BASE_ADDR && raddr_mem[ar_read_count][ARADDR_MSB : ARADDR_LSB] <= SLAVE_CONTLR_END_ADDR)begin
             lite_read_en <= 1;
             AXI4_read_en <= 0;
             lite_out_ARVALID <= 1;
             read_raddr_state <= AR_ROUTE_LITE;
          end             
          else begin
            read_raddr_state <=  AR_IDLE;
            I_out_ARREADY <= 1;
          end
        end
        
        AR_ROUTE_AXI:begin
          if(AXI4_in_ARREADY && AXI4_out_ARVALID)begin
            AXI4_out_ARVALID <= 0;
            read_raddr_state <= AR_IDLE;
            I_out_ARREADY = 1;
          end
          else begin
            AXI4_out_ARVALID <= 1;
            read_raddr_state <= AR_ROUTE_AXI;
          end
        end
        
        ROUTE_LITE:begin
          if(lite_in_ARREADY && lite_out_ARVALID)begin
            lite_out_ARVALID <= 0;
            read_raddr_state <= AR_IDLE;
            I_out_ARREADY <= 0;
          end
          else begin
            lite_out_ARVALID <= 1;
            read_raddr_state <= AR_ROUTE_LITE;
          end
        end
      endcase
    end
  end
          
  assign AXI4_out_ARADDR = (read_raddr_state == AR_ROUTE_AXI)? raddr_mem[ar_read_count][ARADDR_MSB : ARADDR_LSB] : 0;
  assign AXI4_out_ARBURST = (read_raddr_state == AR_ROUTE_AXI)? raddr_mem[ar_read_count][ARBURST_MSB : ARBURST_LSB] : 0;
  assign AXI4_out_ARLEN = (read_raddr_state == AR_ROUTE_AXI) ? raddr_mem[ar_read_count][ARLEN_MSB : ARLEN_LSB] : 0;
  assign AXI4_out_ARSIZE = (read_raddr_state == AR_ROUTE_AXI) ? raddr_mem[ar_read_count][ARSIZE_MSB : ARSIZE_LSB] : 0; 
  assign AXI4_out_ARID = (read_raddr_state == AR_ROUTE_AXI) ? raddr_mem[ar_read_count][ID_MSB : ID_LSB] : 0;

  assign lite_out_ARADDR = (read_raddr_state == AR_ROUTE_LITE)? raddr_mem[ar_read_count][ARADDR_MSB : ARADDR_LSB] : 0;
  assign lite_out_ARBURST = (read_raddr_state == AR_ROUTE_LITE)? raddr_mem[ar_read_count][ARBURST_MSB : ARBURST_LSB] : 0;
  assign lite_out_ARLEN = (read_raddr_state == AR_ROUTE_LITE) ? raddr_mem[ar_read_count][ARLEN_MSB : ARLEN_LSB] : 0;
  assign lite_out_ARSIZE = (read_raddr_state == AR_ROUTE_LITE) ? raddr_mem[ar_read_count][ARSIZE_MSB : ARSIZE_LSB] : 0; 
  assign lite_out_ARID = (read_raddr_state == AR_ROUTE_LITE) ? raddr_mem[ar_read_count][ID_MSB : ID_LSB] : 0;
  
  reg [DATA_WIDTH -1:0]rdata_reg;
  reg [ID -1:0]rid_reg;
  reg rlast_reg;
  wire read_txn_complete;
  
  assign read_txn_complete = (rlast_reg == 1);

  typedef enum logic[1:0]{R_IDLE, ROUTE_AXI4, ROUTE_lite}read_data_state_t;
  read_data_state_t read_data_state;
  
  
  always@(posedge ACLK)begin
    if(!ARESETn)begin
      rdata_reg <= 0;
      rlast_reg <= 0;
      AXI4_out_RREADY <= 0;
      lite_out_RREADY <= 0;
      I_out_RVALID <= 0;
      AXI4_out_RREADY <= 0;
      lite_out_RREADY <= 0;
      rid_reg <= 0;
      read_data_state <= R_IDLE;
    end
    else begin
      case(read_data_state)
        R_IDLE:begin
          AXI4_out_RREADY <= 1;
          lite_out_RREADY <= 1;
          if(AXI4_in_RVALID && AXI4_out_RREADY)begin
            rdata_reg <= AXI4_in_RDATA;
            rid_reg <= AXI4_in_RID;
//            rlast_reg <= AXI4_in_RLAST;
//            AXI4_out_RREADY <= 0;
            read_data_state <= ROUTE_AXI4;
            $display("read data - %h:",rdata_reg);
          end
          else if(lite_in_RVALID && lite_out_RREADY)begin
            rdata_reg <= lite_in_RDATA;
            rid_reg <= lite_in_RID;
            rlast_reg <= lite_in_RLAST;
            lite_out_RREADY <= 0;
            read_data_state <= ROUTE_lite;
            $display("read data1 - %h:",rdata_reg);
          end
          else begin
            I_out_WREADY <= 1;
            read_data_state <= R_IDLE;
          end
        end
        
        ROUTE_AXI4:begin
          AXI4_out_RREADY <= 0;
          I_out_RVALID <= 1;
          if(I_in_RREADY && I_out_RVALID)begin
            I_out_RDATA <=  rdata_reg;
            I_out_RID <= rid_reg;
            if(I_out_RLAST)rburst_txn_complete <= 1;
//            else rburst_txn_complete <= 0;
//            I_out_RLAST <= rlast_reg;
            I_out_RVALID <= 0;
            read_data_state <= R_IDLE;
          end
          else begin
            I_out_RVALID <= 1;
            read_data_state <= ROUTE_AXI4;
          end
        end
        
        ROUTE_lite:begin
          I_out_RVALID <= 1;
          if(I_in_RREADY && I_out_RVALID)begin
            I_out_RDATA <= rdata_reg;
            I_out_RID <= rid_reg;
            if(I_out_RLAST)rburst_txn_complete <= 1;
            else rburst_txn_complete <= 0;
//            I_out_RLAST <= rlast_reg;
            I_out_RVALID <= 0;
            read_data_state <= R_IDLE;
          end
          else begin
            I_out_RVALID <= 1;
            read_data_state <= R_IDLE;
          end
        end
      endcase
    end
  end
  
  assign I_out_RLAST = (read_data_state == ROUTE_AXI4) ? AXI4_in_RLAST : 0;
  
endmodule
  
  
  

