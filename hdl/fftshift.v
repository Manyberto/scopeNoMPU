
module fftshift #(
parameter	ADDR_WIDTH	= 16
)
(
input		wire[ADDR_WIDTH-1:0]		addr_in,
output	wire[ADDR_WIDTH-1:0]		addr_out
);

assign addr_out = (addr_in < 7'd64) ? addr_in + 7'd64 : addr_in - 7'd64;

endmodule