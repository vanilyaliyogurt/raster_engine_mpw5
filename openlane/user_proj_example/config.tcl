# SPDX-FileCopyrightText: 2020 Efabless Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# SPDX-License-Identifier: Apache-2.0

set ::env(PDK) "sky130A"
set ::env(STD_CELL_LIBRARY) "sky130_fd_sc_hd"

set script_dir [file dirname [file normalize [info script]]]

set ::env(DESIGN_NAME) user_proj_example

set ::env(VERILOG_FILES) "\
	$::env(CARAVEL_ROOT)/verilog/rtl/defines.v \
	$script_dir/../../verilog/rtl/user_proj_example.v \
	$script_dir/../../verilog/rtl/src/bbox_iterator.v \
	$script_dir/../../verilog/rtl/src/clk_divider.v \
	$script_dir/../../verilog/rtl/src/div_uu.v \
	$script_dir/../../verilog/rtl/src/pipeline_ctrl.v \
	$script_dir/../../verilog/rtl/src/edge_function.v \
	$script_dir/../../verilog/rtl/src/edge_function_evaluator.v \
	$script_dir/../../verilog/rtl/src/fixedpt.vh \
	$script_dir/../../verilog/rtl/src/raster_pipeline_ex1.v \
	$script_dir/../../verilog/rtl/src/raster_pipeline_ex2.v \
	$script_dir/../../verilog/rtl/src/raster_pipeline_ex3.v \
	$script_dir/../../verilog/rtl/src/tri_raster_engine.v \
	$script_dir/../../verilog/rtl/src/lfsr5.v \
	$script_dir/../../verilog/rtl/src/vram_ctrl.v \
	$script_dir/../../verilog/rtl/src/huedeon_ctrl.v \
	$script_dir/../../verilog/rtl/src/gpu_wrapper.v"


set ::env(DESIGN_IS_CORE) 0

set ::env(CLOCK_PORT) "wb_clk_i"
set ::env(CLOCK_PERIOD) "33"

set ::env(FP_SIZING) absolute
set ::env(DIE_AREA) "0 0 1900 1800"

set ::env(FP_PIN_ORDER_CFG) $script_dir/pin_order.cfg


set ::env(PL_BASIC_PLACEMENT) 0
set ::env(PL_MAX_DISPLACEMENT_Y) 600
set ::env(PL_MAX_DISPLACEMENT_X) 600
set ::env(PL_TARGET_DENSITY) 0.28
set ::env(PL_RESIZER_HOLD_SLACK_MARGIN) 0.5
set ::env(PL_RESIZER_HOLD_MAX_BUFFER_PERCENT) 65

set ::env(ROUTING_CORES) 16

set ::env(CTS_TOLERANCE) 25
set ::env(CTS_TARGET_SKEW) 135
set ::env(CTS_CLK_BUFFER_LIST) "sky130_fd_sc_hd__clkbuf_4 sky130_fd_sc_hd__clkbuf_8"
set ::env(CTS_SINK_CLUSTERING_SIZE) "16"
set ::env(CLOCK_BUFFER_FANOUT) "8"

# Maximum layer used for routing is metal 4.
# This is because this macro will be inserted in a top level (user_project_wrapper) 
# where the PDN is planned on metal 5. So, to avoid having shorts between routes
# in this macro and the top level metal 5 stripes, we have to restrict routes to metal4.  

#set ::env(GLB_RT_MAXLAYER) 5
set ::env(RT_MAX_LAYER) {met4}

set ::env(GLB_RT_ANT_ITERS) 15
set ::env(GLB_RESIZER_ALLOW_SETUP_VIOS) 1
set ::env(GLB_RESIZER_TIMING_OPTIMIZATIONS) 0
set ::env(GLB_RESIZER_HOLD_MAX_BUFFER_PERCENT) 65
set ::env(GLB_RT_OVERFLOW_ITERS) 70
set ::env(GLB_RESIZER_HOLD_SLACK_MARGIN) 0.8


set ::env(DRT_OPT_ITERS) 110

set ::env(TAKE_LAYOUT_SCROT) 1
# You can draw more power domains if you need to 
set ::env(VDD_NETS) [list {vccd1}]
set ::env(GND_NETS) [list {vssd1}]

set ::env(DIODE_INSERTION_STRATEGY) 4 
# If you're going to use multiple power domains, then disable cvc run.
set ::env(RUN_CVC) 1
