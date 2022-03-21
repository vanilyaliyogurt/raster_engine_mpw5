// SPDX-FileCopyrightText: 2020 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

`default_nettype wire

`timescale 1 ns / 1 ps

`ifndef RASTER_STANDALONE_TB
`define RASTER_STANDALONE_TB
module raster_standalone_tb;

  localparam CLK_PERIOD = 10;
  
  reg                       wb_clk_i    ;          
  reg                       wb_rst_i    ;
  reg                       wbs_stb_i   ;
  reg                       wbs_cyc_i   ;
  reg                       wbs_we_i    ;
  reg [3:0]                 wbs_sel_i   ;
  reg [31:0]                wbs_dat_i   ;
  reg [31:0]                wbs_adr_i   ;
  wire                      wbs_ack_o   ;
  wire [31:0]               wbs_dat_o   ;
  reg [127:0]               la_data_in  ;
  wire [127:0]              la_data_out ;
  reg [127:0]               la_oenb     ;
  reg [38-1:0]   io_in       ;
  wire [38-1:0]  io_out      ;
  wire [38-1:0]  io_oeb      ;
  wire [2:0]                irq         ;
  
  wire [17:0] vram_raster_address = io_out[20 +: 18];
  wire [15:0] vram_raster_color   = io_out[4 +: 16];
  wire        vram_clk_o          = io_out[2];
  wire        vram_rst_o          = io_out[3];
  wire        vram_write_pixel    = io_out[1];
  wire        vram_offset         = io_out[0];
  
  task automatic reset_wb(input a);
  begin
    wb_rst_i     <= 1'b0;
    wb_addr   <= 32'd0;
    wb_dat_i  <= 32'd0;
    wb_cyc    <= 1'b0;
    wb_stb    <= 1'b0;
    wb_sel    <= 1'b0;
    wb_we     <= 1'b0;
    #(4*CLK_PERIOD);
    wb_rst_i     <= 1'b1;
    #(1*CLK_PERIOD);
  end
  endtask

  task wb_write(
    input [31:0] addr,
    input [31:0] data,
    input [3:0]  sel
  );
  begin
    @(posedge wb_clk_i) begin
      wb_addr   <= addr;
      wb_dat_i  <= data;
      wb_sel    <= sel;
      wb_we     <= 1'b1;
      wb_stb    <= 1'b1;
      wb_cyc    <= 1'b1;
    end
    @(posedge wb_ack_o) begin
      @(negedge wb_clk_i) begin
        wb_addr   <= 32'd0;
        wb_dat_i  <= 32'd0;
        wb_cyc    <= 1'b0;
        wb_stb    <= 1'b0;
        wb_sel    <= 1'b0;
        wb_we     <= 1'b0;
      end
    end
  end
  endtask

  task wb_read(
    input [31:0] addr,
    input [3:0]  sel
  );
  begin
    @(posedge wb_clk_i) begin
      wb_addr   <= addr;
      wb_sel    <= sel;
      wb_we     <= 1'b0;
      wb_stb    <= 1'b1;
      wb_cyc    <= 1'b1;
    end
    @(posedge wb_ack_o) begin
      @(negedge wb_clk_i) begin
        wb_addr   <= 32'd0;
        wb_cyc    <= 1'b0;
        wb_stb    <= 1'b0;
        wb_sel    <= 1'b0;
        wb_we     <= 1'b0;
      end
    end
  end
  endtask

  task draw_triangle(
    input [31:0] v1_x, v1_y, v1_z, v1_color, v1_uv,
    input [31:0] v2_x, v2_y, v2_z, v2_color, v2_uv,
    input [31:0] v3_x, v3_y, v3_z, v3_color, v3_uv,
    input [31:0] draw_offset, disp_offset
  );
  begin
    wb_write(32'd0,32'd1,4'd0);
    #(CLK_PERIOD);
    wb_write(32'd1,32'd1,4'd0);

    wb_write(32'd18,draw_offset,4'd0);
    wb_write(32'd19,disp_offset,4'd0);

    wb_write(32'd3 ,v1_x,4'd0);
    wb_write(32'd4 ,v1_y,4'd0);
    wb_write(32'd5 ,v1_z,4'd0);
    wb_write(32'd6 ,v1_color,4'd0);
    wb_write(32'd7 ,v1_uv,4'd0);

    wb_write(32'd8 ,v2_x,4'd0);
    wb_write(32'd9 ,v2_y,4'd0);
    wb_write(32'd10,v2_z,4'd0);
    wb_write(32'd11,v2_color,4'd0);
    wb_write(32'd12,v2_uv,4'd0);

    wb_write(32'd13,v3_x,4'd0);
    wb_write(32'd14,v3_y,4'd0);
    wb_write(32'd15,v3_z,4'd0);
    wb_write(32'd16,v3_color,4'd0);
    wb_write(32'd17,v3_uv,4'd0);
    
    wb_write(32'd2,32'd1,4'd0);
    $fwrite(file, "///////////////////////////////////////////////////////////////\n");
    $fwrite(file,"v1 => %h, %h => %h \n", v1_x, v1_y, v1_color);
    $fwrite(file,"v2 => %h, %h => %h \n", v2_x, v2_y, v2_color);
    $fwrite(file,"v3 => %h, %h => %h \n", v3_x, v3_y, v3_color);
    $fwrite(file, "///////////////////////////////////////////////////////////////\n");
  end
  endtask
  
  always #(CLK_PERIOD/2) clock <= (clock === 1'b0);

	initial begin
		clock = 0;
	end
  
  initial begin
    $dumpfile("raster_standalone.vcd");
		$dumpvars(0, raster_standalone_tb);
    
    // Repeat cycles of 1000 clock edges as needed to complete testbench
		repeat (50) begin
			repeat (1000) @(posedge wb_clk_i);
			// $display("+1000 cycles");
		end
    
    $display("%c[1;31m",27);
    `ifdef GL
			$display ("Monitor: Timeout, Test Mega-Project WB Port (GL) Failed");
		`else
			$display ("Monitor: Timeout, Test Mega-Project WB Port (RTL) Failed");
		`endif
    $display("%c[0m",27);
		$finish;
  end
  
  initial begin
    file = $fopen("results.txt");
    reset_wb();
    wb_read(32'd0,4'd0);

    #(10*CLK_PERIOD);
    draw_triangle(
    32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000, 32'h00000000,
    32'h00000000, 32'h0003C000, 32'h00000000, 32'h00000000, 32'h00000000,
    32'h00050000, 32'h0003C000, 32'h00000000, 32'h00000000, 32'h00000000,
    32'h00000000, 32'h00012C00);
    #(10*CLK_PERIOD);
    //wb_read(32'd0,4'd1);
    #(9000*CLK_PERIOD);
    $fclose(file);
    $finish;
  end

  always @(posedge wb_clk_i) begin
    if(vram_write_pixel) begin
      $display("%b, %h, %h", vram_offset, vram_raster_address, vram_raster_color);
      $fwrite(file,"%b, %h, %h \n", vram_offset, vram_raster_address, vram_raster_color);
    end
  end
  
  user_proj_example mprj(
`ifdef USE_POWER_PINS
    .vccd1,	// User area 1 1.8V supply
    .vssd1,	// User area 1 digital ground
`endif
    .wb_clk_i,
    .wb_rst_i,
    .wbs_stb_i,
    .wbs_cyc_i,
    .wbs_we_i,
    .wbs_sel_i,
    .wbs_dat_i,
    .wbs_adr_i,
    .wbs_ack_o,
    .wbs_dat_o,
    .la_data_in,
    .la_data_out,
    .la_oenb,
    .io_in,
    .io_out,
    .io_oeb, 
    .irq
  );
endmodule
`endif