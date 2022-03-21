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

`default_nettype none
/*
 *-------------------------------------------------------------
 *
 * user_proj_example
 *
 * This is an example of a (trivially simple) user project,
 * showing how the user project can connect to the logic
 * analyzer, the wishbone bus, and the I/O pads.
 *
 * This project generates an integer count, which is output
 * on the user area GPIO pads (digital output only).  The
 * wishbone connection allows the project to be controlled
 * (start and stop) from the management SoC program.
 *
 * See the testbenches in directory "mprj_counter" for the
 * example programs that drive this user project.  The three
 * testbenches are "io_ports", "la_test1", and "la_test2".
 *
 *-------------------------------------------------------------
 */

module user_proj_example #(
    parameter BITS = 32
)(
`ifdef USE_POWER_PINS
    inout vccd1,	// User area 1 1.8V supply
    inout vssd1,	// User area 1 digital ground
`endif

    // Wishbone Slave ports (WB MI A)
    input wb_clk_i,
    input wb_rst_i,
    input wbs_stb_i,
    input wbs_cyc_i,
    input wbs_we_i,
    input [3:0] wbs_sel_i,
    input [31:0] wbs_dat_i,
    input [31:0] wbs_adr_i,
    output wbs_ack_o,
    output [31:0] wbs_dat_o,

    // Logic Analyzer Signals
    input  [127:0] la_data_in,
    output [127:0] la_data_out,
    input  [127:0] la_oenb,

    // IOs
    input  [`MPRJ_IO_PADS-1:0] io_in,
    output [`MPRJ_IO_PADS-1:0] io_out,
    output [`MPRJ_IO_PADS-1:0] io_oeb,

    // IRQ
    output [2:0] irq
);
  /*
    wire [`MPRJ_IO_PADS-1:0] io_in;
    wire [`MPRJ_IO_PADS-1:0] io_out;
    wire [`MPRJ_IO_PADS-1:0] io_oeb;
  */
    // IO
	assign io_out[0] = vram_offset;
	assign io_out[1] = vram_write_pixel;
	assign io_out[2] = vram_clk_o;
	assign io_out[3] = vram_rst_o;
	assign io_out[4 +: 16] = vram_raster_color;
	assign io_out[20 +: 18] = vram_raster_address;
	assign io_oeb = {(`MPRJ_IO_PADS-1){vram_rst_o}};
  
	wire [`MPRJ_IO_PADS-1:0] unused_io_in = io_in;
	wire [127:0]             unused_la_data_in = la_data_in;
	wire [127:0]             unused_la_oenb = la_oenb;
  
    // IRQ
    assign irq = 3'b000;// Unused

    // LA 
    assign la_data_out = 128'd0;
	
	wire [17:0] vram_raster_address;
	wire [15:0] vram_raster_color;
	wire        vram_clk_o;
	wire        vram_rst_o;
	wire        vram_write_pixel;
	wire        vram_offset;
	

    gpu_wrapper gpu_instance(
      .wb_clk_i				(wb_clk_i),
      .wb_rst_i				(wb_rst_i),
      .wbs_stb_i				(wbs_stb_i),
      .wbs_cyc_i				(wbs_cyc_i),
      .wbs_we_i				(wbs_we_i),
      .wbs_sel_i				(wbs_sel_i),
      .wbs_dat_i				(wbs_dat_i),
      .wbs_adr_i				(wbs_adr_i),
      .wbs_ack_o				(wbs_ack_o),
      .wbs_dat_o				(wbs_dat_o),
      .vram_raster_address	(vram_raster_address),
      .vram_raster_color		(vram_raster_color),
      .vram_clk_o				(vram_clk_o),
      .vram_rst_o				(vram_rst_o),
      .vram_write_pixel		(vram_write_pixel),
      .vram_offset			(vram_offset)
    );

endmodule
`default_nettype wire
