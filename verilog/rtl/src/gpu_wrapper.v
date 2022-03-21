
`default_nettype none

module gpu_wrapper(
  input         wb_clk_i,
  input         wb_rst_i,
  input         wbs_stb_i,
  input         wbs_cyc_i,
  input         wbs_we_i,
  input [1:0]   wbs_sel_i,
  input [31:0]  wbs_dat_i, 
  input [31:0]  wbs_adr_i,
  output        wbs_ack_o,
  output [31:0] wbs_dat_o,

  output [17:0] vram_raster_address,
  output [15:0] vram_raster_color,
  output        vram_clk_o,
  output        vram_rst_o,
  output        vram_write_pixel,
  output        vram_offset
);

  wire [31:0] fb_display_offset;
  wire [17:0] fb_vram_address;
  wire [15:0] fb_pixel;
  wire        vsync;
  wire [15:0] vram_rd_data;
  wire [31:0] gpu_status;

  wire        vram_enable;
  wire [17:0] vram_addr;
  wire        vram_wr_en;

  wire        gpu_ack, vram_ack ;

  wire        gpu_write_pixel;
  wire        gpu_active = gpu_status[0] | gpu_write_pixel;
  
  wire [17:0] gpu_raster_address;

  assign vram_clk_o = wb_clk_i;
  assign vram_rst_o = wb_rst_i;

  wire [15:0] gpu_raster_color;
  

   vram_ctrl vram_ctrl1(
     .wb_clk_i   (wb_clk_i),
     .wb_rst_i   (wb_rst_i),
     .wbs_stb_i  (wbs_stb_i),
     .wbs_cyc_i  (wbs_cyc_i),
     .wbs_we_i   (wbs_we_i),
     .wbs_sel_i  (wbs_sel_i),
     .wbs_dat_i  (wbs_dat_i),
     .wbs_adr_i  (wbs_adr_i),
     .wbs_ack_o  (vram_ack),

     .gpu_active_i      (gpu_active),
     .gpu_write_pixel_i (gpu_write_pixel),
     .gpu_raster_addr_i (gpu_raster_address),
     .gpu_raster_color_i(gpu_raster_color),

     .vram_enable_o (),
     .vram_addr_o   (vram_raster_address),
     .vram_data_o   (vram_raster_color),
     .vram_wr_en_o  (vram_write_pixel)  
   );


  wire [7:0]  gpu_r8;
  wire [7:0]  gpu_g8;
  wire [7:0]  gpu_b8;


  HuedeonGPU huedeon_gpu(
    .i_clk              (wb_clk_i),
    .i_reset            (wb_rst_i),
    .i_enable           (1'b1),
    .i_chip_select      (wbs_sel_i == 2'b00 && wbs_stb_i),
    .i_wr_address       (wbs_adr_i[13:0]),
    .i_wr_data          (wbs_dat_i),
    .i_wr_enable        (wbs_we_i),
    .o_status           (gpu_status),
    .o_wr_enable        (gpu_write_pixel),
    .o_wr_address       (gpu_raster_address),
    .o_r                (gpu_r8),
    .o_g                (gpu_g8),
    .o_b                (gpu_b8),
    .o_display_offset   (fb_display_offset),
    .ack_o              (gpu_ack)
  );

  assign gpu_raster_color = ((gpu_b8 >> 3) & 5'h1F) | (((gpu_g8 >> 2) & 6'h3f) << 5) | (((gpu_r8 >> 3) & 5'h1f) << 11);

  assign vram_offset = fb_display_offset == 'd0 ? 1'b0 : 1'b1;

  assign wbs_dat_o = (wbs_sel_i == 2'b00) ? gpu_status : {16'd1};
  assign wbs_ack_o = (wbs_sel_i == 2'b00) ? gpu_ack: vram_ack;

  //Deneme
  //assign vram_raster_address = gpu_raster_address;
  //assign vram_write_pixel = gpu_write_pixel;


endmodule
