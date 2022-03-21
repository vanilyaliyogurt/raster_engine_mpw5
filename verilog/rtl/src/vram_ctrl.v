

`default_nettype none

module vram_ctrl(
  input         wb_clk_i,
  input         wb_rst_i,
  input         wbs_stb_i,
  input         wbs_cyc_i,
  input         wbs_we_i,
  input [1:0]   wbs_sel_i,
  input [31:0]  wbs_dat_i,
  input [31:0]  wbs_adr_i,
  output reg    wbs_ack_o,

  input         gpu_active_i,
  input         gpu_write_pixel_i,
  input [17:0]  gpu_raster_addr_i,
  input [15:0]  gpu_raster_color_i,

  output        vram_enable_o,
  output [17:0] vram_addr_o,
  output [15:0] vram_data_o,
  output        vram_wr_en_o
);

wire vram_bus_enable = wbs_sel_i == 2'b01;

assign  vram_enable_o = gpu_active_i ? 1'b1 : vram_bus_enable && wbs_stb_i;
assign  vram_addr_o   = gpu_active_i ? gpu_raster_addr_i : wbs_adr_i;
assign  vram_wr_en_o  = gpu_active_i ? gpu_write_pixel_i : vram_bus_enable && wbs_we_i;
assign  vram_data_o   = gpu_active_i ? gpu_raster_color_i : wbs_dat_i[15:0];


always @(posedge wb_clk_i) begin
  if(vram_bus_enable & wbs_stb_i & ~gpu_active_i) begin
    wbs_ack_o <= 1'b1;
  end else begin
    wbs_ack_o <= 1'b0;
  end
end




endmodule