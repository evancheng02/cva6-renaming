module my_module (
    input clk_i,
    input rst_ni,
    input [32-1:0] instn,
    output reg [32-1:0] instn_o
);
    always @(posedge clk_i) begin
        instn_o <= instn;
    end
endmodule
