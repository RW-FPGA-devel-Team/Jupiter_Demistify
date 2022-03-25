//============================================================================
//  Jupiter Ace replica for MiSTer
//  Copyright (C) 2018-2019 Sorgelig
//
//  This program is free software; you can redistribute it and/or modify it
//  under the terms of the GNU General Public License as published by the Free
//  Software Foundation; either version 2 of the License, or (at your option)
//  any later version.
//
//  This program is distributed in the hope that it will be useful, but WITHOUT
//  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
//  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
//  more details.
//
//  You should have received a copy of the GNU General Public License along
//  with this program; if not, write to the Free Software Foundation, Inc.,
//  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
//============================================================================

module guest_mist
(       
        output        LED,                                              
        output        VGA_HS,
        output        VGA_VS,
        output        AUDIO_L,
        output        AUDIO_R, 
		  output [15:0]  DAC_L, 
		  output [15:0]  DAC_R, 
        input         TAPE_IN,
        input         UART_RX,
        output        UART_TX,
        input         SPI_SCK,
        output        SPI_DO,
        input         SPI_DI,
        input         SPI_SS2,
        input         SPI_SS3,
		  input         SPI_SS4,
        input         CONF_DATA0,
        input         CLOCK_27,
        output  [5:0] VGA_R,
        output  [5:0] VGA_G,
        output  [5:0] VGA_B,
		  
		  output [12:0] SDRAM_A,
		  inout  [15:0] SDRAM_DQ,
		  output        SDRAM_DQML,
        output        SDRAM_DQMH,
        output        SDRAM_nWE,
        output        SDRAM_nCAS,
        output        SDRAM_nRAS,
        output        SDRAM_nCS,
        output  [1:0] SDRAM_BA,
        output        SDRAM_CLK,
        output        SDRAM_CKE
);

`include "build_id.v"
parameter CONF_STR = {
	"Jupiter;;",
	"O23,Scandoubler Fx,None,HQ2x,CRT 25%,CRT 50%;",
	"O45,CPU Speed,Normal,x2,x4;",
	"T0,Reset;",
	"V,v",`BUILD_DATE
};

/////////////////  CLOCKS  ////////////////////////

wire clk_sys,pll_ready;

pll pll(0, CLOCK_27, clk_sys,pll_ready);


wire [1:0] turbo = status[5:4];

reg ce_pix;
reg ce_cpu;
always @(negedge clk_sys) begin
	reg [3:0] div;

	div <= div + 1'd1;
	ce_pix <= !div[2:0];
	ce_cpu <= (!div[3:0] && !turbo) | (!div[2:0] && turbo[0]) | turbo[1];
end


reg rom_ready=0;
reg [23:0] counter;
always @ (posedge ce_cpu) begin
  if (!reset && counter == 24'b1) begin
    rom_ready = 1'b1;
  end else begin
    counter <= counter +1;    
  end 
end

/////////////////  HPS  ///////////////////////////

wire [31:0] status;
wire  [1:0] buttons;

wire [15:0] joya, joyb;
wire [10:0] ps2_key;

wire        ioctl_download;
wire  [7:0] ioctl_index;
wire        ioctl_wr;
wire [24:0] ioctl_addr;
wire  [7:0] ioctl_dout;
reg         ioctl_wait = 0;
wire        forced_scandoubler;

wire ypbpr;


user_io #(.STRLEN($size(CONF_STR)>>3)) user_io
(
	.clk_sys             (clk_sys          ),
   .clk_sd              (clk_sys          ),
	.SPI_SS_IO           (CONF_DATA0),
	.SPI_CLK             (SPI_SCK),
	.SPI_MOSI            (SPI_DI),
	.SPI_MISO            (SPI_DO),

	.conf_str            (CONF_STR),
	.status              (status),
	.scandoubler_disable (forced_scandoubler),
	.ypbpr               (ypbpr),
	.no_csync            (),
	.buttons             (buttons),
	
	.ps2_key             (ps2_key),

	.joystick_0          (joya          ),
	.joystick_1          (joyb          )
);

data_io data_io
(
	.clk_sys             (clk_sys),
	.SPI_SCK             (SPI_SCK),
	.SPI_DI              (SPI_DI),
	.SPI_SS2             (SPI_SS2),

	.clkref_n            (ioctl_wait),
	.ioctl_wr            (ioctl_wr),
	.ioctl_addr          (ioctl_addr),
	.ioctl_dout          (ioctl_dout),
	.ioctl_download      (ioctl_download),
	.ioctl_index         (ioctl_index)
);



///////////////////////////////////////////////////


assign LED = !ioctl_wait;
wire reset = !pll_ready | status[0] | buttons[1];

wire mic,spk;
wire ear = UART_RX;

wire [7:0] kbd_row;
wire [4:0] kbd_col;
wire       video_out;

ace ace
(
	.*,
	.clk(clk_sys),
	.no_wait(|turbo),
	.rom_ready (rom_ready),
	.reset(reset)
);

keyboard keyboard (.*);


assign DAC_L = {1'b0, spk, mic,ear, 12'd0};
assign DAC_R = DAC_L;

wire hsync, vsync, hblank, vblank;
wire 			blankn = ~(hblank | vblank);
wire [1:0] R,G,B;
video_mixer #(.LINE_LENGTH(280), .HALF_DEPTH(0)) video_mixer
(
	.clk_sys(clk_sys),
	.ce_pix(ce_pix),
	.ce_pix_actual(ce_pix),
	.SPI_SCK(SPI_SCK),
	.SPI_SS3(SPI_SS3),
	.SPI_DI(SPI_DI),
	.scanlines(forced_scandoubler ? 2'b00 : {status[3:2] == 3, status[3:2] == 2}),
	.scandoubler_disable(forced_scandoubler),
	.hq2x(status[3:2]==1),
	.ypbpr(ypbpr),
	.ypbpr_full(1),
	.R(blankn ? { R[0],R[0],{4{R[0] & R[1]}}} : 6'b0),
	.G(blankn ? { G[0],G[0],{4{G[0] & G[1]}}} : 6'b0),
	.B(blankn ? { B[0],B[0],{4{B[0] & B[1]}}} : 6'b0),
	.mono(0),
	.HSync(~hsync),
	.VSync(~vsync),
	.line_start(hblank),
	.VGA_R(VGA_R),
	.VGA_G(VGA_G),
	.VGA_B(VGA_B),
	.VGA_VS(VGA_VS),
	.VGA_HS(VGA_HS)
);

dac #(16) dac_l (
   .clk_i        (clk_sys),
   .res_n_i      (1      ),
   .dac_i        (DAC_L  ),
   .dac_o        (AUDIO_L)
);
assign AUDIO_R=AUDIO_L;


endmodule
