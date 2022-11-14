`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    00:56:12 11/11/2022 
// Design Name: 
// Module Name:    verilog 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module verilog(
    input clk,
    output vga_h_sync,
    output vga_v_sync,
    output vga_R,
    output vga_G,
    output vga_B
    );

	 wire [15:0] r_HPos;
    wire [15:0] r_VPos;
	 
    VgaProcessor processor
	 (
	     clk,
		  r_HPos,
		  r_VPos
	 );
	 
	 assign vga_h_sync = (r_HPos < 95) ? 1'b1:1'b0;
	 assign vga_v_sync = (r_VPos < 2) ? 1'b1:1'b0;

	 assign vga_R = (r_HPos < 784 && r_HPos > 143 && r_VPos < 515 && r_VPos > 34) ? 1'b1:1'b0;
	 assign vga_G = 0;
	 assign vga_B = 0;
	 //assign vga_G = (r_HPos < 784 && r_HPos > 143 && r_VPos < 515 && r_VPos > 34) ? 1'b1:1'b0;
	 //assign vga_B = (r_HPos < 784 && r_HPos > 143 && r_VPos < 515 && r_VPos > 34) ? 1'b1:1'b0;
endmodule

////////////////////////////////////////////////////////////////////////////////////////////////

module VgaProcessor
    (
        input i_Clk,
		  output reg [15:0] r_HPos_in = 0,
		  output reg [15:0] r_VPos_in = 0
    );
    localparam TOTAL_WIDTH = 635; // 800
    localparam TOTAL_HEIGHT = 525;
    always @(posedge i_Clk)
        begin
          if (r_HPos_in < TOTAL_WIDTH-1)
            begin
                r_HPos_in <= r_HPos_in + 1;
            end
          else
            begin
                r_HPos_in <= 0;
                if (r_VPos_in < TOTAL_HEIGHT-1)
                  begin
                    r_VPos_in <= r_VPos_in + 1;
                  end
                else
                  begin
                    r_VPos_in<= 0;
                  end
            end  
        end
endmodule

