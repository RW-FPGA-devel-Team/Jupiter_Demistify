//============================================================================
//  Jupiter Ace main logic
//  Copyright (C) 2018 Sorgelig
//  Bascolace ROM and color mod (c) Antonio Villena, added by rampa.
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

module ace
(
	input        clk,
	input        ce_pix,
	input        ce_cpu,
	input        no_wait,
	input        reset,

	output [7:0] kbd_row,
	input  [4:0] kbd_col,
	output       video_out,
	output       hsync,
	output       vsync,
	output       hblank,
	output       vblank,
	
	output [1:0] R,
	output [1:0] G,
	output [1:0] B,
	
	output reg   mic,
	output reg   spk,
	input        ear,
   
	input        rom_ready
);

assign kbd_row = cpu_addr[15:8];

wire [15:0]	addr   = cpu_addr;
wire  [7:0] data   = cpu_dout;
wire        ram_we = ~wr_n;

wire rom_enable  = (~mreq_n ) && (addr[15:13] == 0);       // 0000 - 1FFF 8KB
wire sram_enable = (~mreq_n ) && (addr[15:11] == 'b00100); // 2000 - 27FF 1KB * 2
wire cram_enable = (~mreq_n ) && (addr[15:11] == 'b00101); // 2800 - 2FFF 1KB * 2
wire uram_enable = (~mreq_n ) && (addr[15:12] == 'b0011);  // 3000 - 3FFF 1KB * 4
wire xram_enable = (~mreq_n ) && (addr[15:14] == 'b01);    // 4000 - 7FFF 16KB
wire eram_enable = (~mreq_n ) && (addr[15]);               // 8000 - FFFF 32KB

wire wait_n = no_wait | ~(sram_enable | cram_enable) | hblank | vblank | ~addr[10]; // 2400 - 27FF, 2C00 - 2FFF

always @(posedge clk) begin
	if (~iorq_n & ~cpu_addr[0]) begin
		if (~rd_n) spk <= 0;
		if (~wr_n) {spk,mic} <= {1'b1,cpu_dout[3]};
	end
end

wire [7:0] io_dout = {8{iorq_n|rd_n}} | (~cpu_addr[0] ? {2'b11,ear, kbd_col} : (sram_data | cram_data));

wire [9:0] sram_addr;
wire [7:0] sram_data;
wire [7:0] sram_dout;
dpram #(10) sram
(
	.clock(clk),
	.address_a(addr[9:0]),
	.data_a(data),
	.wren_a(ram_we & sram_enable),
	.oe_a_n(~sram_enable),
	.q_a(sram_dout),
	.address_b(sram_addr),
	.q_b(sram_data)
);

wire [9:0] cram_addr;
wire [7:0] cram_data;
dpram #(10) cram
(
	.clock(clk),
	.address_a(addr[9:0]),
	.data_a(data),
	.wren_a(ram_we & cram_enable),
	.address_b(cram_addr),
	.q_b(cram_data)
);

wire [7:0] uram_dout;
dpram #(10) uram
(
	.clock(clk),
	.address_a(addr[9:0]),
	.data_a(data),
	.wren_a(ram_we & uram_enable),
	.oe_a_n(~uram_enable),
	.q_a(uram_dout)
);

wire [7:0]  xram_dout;
wire [13:0] attr_addr;
wire [7:0]  attr_data;

dpram #(14) xram
(
	.clock(clk),
	.address_a(addr[13:0]),
	.data_a(data),
	.wren_a(ram_we & xram_enable),
	.oe_a_n(~xram_enable),
	.q_a(xram_dout),
	.address_b(attr_addr),
	.q_b(attr_data)
);


wire [7:0] eram_dout;
dpram #(15) eram
(
	.clock(clk),
	.address_a(addr[14:0]),
	.data_a(data),
	.wren_a(ram_we & eram_enable),
	.oe_a_n(~eram_enable),
	.q_a(eram_dout)
);

wire [7:0] rom_dout;
dpram #(.ADDRWIDTH(14), .MEM_INIT_FILE("../soft/bascolace.mif")) rom
(
	.clock(clk),
	.address_a({rom_ready,cpu_addr[12:0]}),
	.oe_a_n(~rom_enable),
	.q_a(rom_dout)
);

wire  [7:0] cpu_dout;
wire [15:0] cpu_addr;
wire        iorq_n, mreq_n, rd_n, wr_n, int_n;
T80pa cpu
(
	.RESET_n(~reset),
	.CLK(clk),
	.CEN_p(ce_cpu),

	.WAIT_n(wait_n),
	.INT_n(vsync),
	.MREQ_n(mreq_n),
	.IORQ_n(iorq_n),
	.RD_n(rd_n),
	.WR_n(wr_n),
	.A(cpu_addr),
	.DI(rom_dout & sram_dout & uram_dout & xram_dout & eram_dout & io_dout),
	.DO(cpu_dout),
	.DIRSet(),
	.DIR()
);


video video (.*
             );

endmodule
