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

// Include caravel global defines for the number of the user project IO pads 
`include "defines.v"
`define USE_POWER_PINS

`ifdef GL
    // Assume default net type to be wire because GL netlists don't have the wire definitions
    `default_nettype wire
    `include "gl/user_project_wrapper.v"
    `include "gl/user_proj_example.v"
`else
    `include "user_project_wrapper.v"
    `include "user_proj_example.v"
    `include "src/bbox_iterator.v"
    `include "src/clk_divider.v"
    `include "src/div_uu.v"
    `include "src/edge_function.v"
    `include "src/edge_function_evaluator.v"
    `include "src/fixedpt.vh"
    `include "src/pipeline_ctrl.v"
    `include "src/raster_pipeline_ex1.v"
    `include "src/raster_pipeline_ex2.v"
    `include "src/raster_pipeline_ex3.v"
    `include "src/tri_raster_engine.v"
    `include "src/lfsr5.v"
    `include "src/vram_ctrl.v"
    `include "src/huedeon_ctrl.v"
    `include "src/gpu_wrapper.v"
`endif
