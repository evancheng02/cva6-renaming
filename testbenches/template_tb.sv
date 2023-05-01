// Template for writing your own testbench
module template_tb import ariane_pkg::*; #(
    parameter int unsigned ARCH_REG_WIDTH = 5,
    parameter int unsigned PHYS_REG_WIDTH = 6
);
    reg clk_i;
    reg rst_ni;
    logic fetch_entry_ready_i;
    issue_struct_t issue_n;
    issue_struct_t issue_q;
    logic [PHYS_REG_WIDTH-1:0] waddr_i;
    logic we_gp_i;

    initial begin
        while(1) begin
            #10 clk_i = 1'b0;
            #10 clk_i = 1'b1;
        end
    end

    initial begin
        rst_ni = 1'b1;
        #10
        rst_ni = 1'b0;
        fetch_entry_ready_i = 1'b0;
        issue_n.valid = 1'b0;
        #10 // Cycle 0
        rst_ni = 1'b1;
        #20 // Cycle 1
        $display("I0: rd %d rs1 %d rs2 %d", 
                 issue_q.sbe.rd[PHYS_REG_WIDTH-1:0],
                 issue_q.sbe.rs1[PHYS_REG_WIDTH-1:0],
                 issue_q.sbe.rs2[PHYS_REG_WIDTH-1:0]);
        #20 // Cycle 2
        $display("I1: rd %d rs1 %d rs2 %d", 
                 issue_q.sbe.rd[PHYS_REG_WIDTH-1:0],
                 issue_q.sbe.rs1[PHYS_REG_WIDTH-1:0],
                 issue_q.sbe.rs2[PHYS_REG_WIDTH-1:0]);
    end

    renaming_map i_renaming_map (
        .clk_i(clk_i),
        .rst_ni(rst_ni),
        .fetch_entry_ready_i(fetch_entry_ready_i),
        .issue_n(issue_n),
        .issue_q(issue_q),
        .waddr_i(waddr_i),
        .we_gp_i(we_gp_i)
    );
endmodule
