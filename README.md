# Raster Engine

An implementation of rasterization engine using Skywater 130 nm PDK. 

Even through open-source RISC-V processor architectures provide huge performance and flexibility for computation tasks, an accompanying GPU is required for user interaction and visualization. For this purpose, this project aims to integrate a rasterizer to the existing RISC-V core for the visualization purpose on the path of obtaining a fully open-source computational platform in the future.

The rasterizer can be programmed using the Wishbone interface. Since we don't have enough silicon area to put SRAMs for storing a frame, we made the signals that goes to VRAM output. So, to display the result of the rasterization engine, an FPGA with VRAM and VGA controller is needed.


# Contributors

* Can Kurt
* Mehmet Fatih Gülakar
