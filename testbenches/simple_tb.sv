// Simple testbench with three identical add instructions
// Input sequence:
// Cycle  0:  I0:  LI    ar4,   0xa          (VALID)   Commit:  None
// Cycle  1:                                 (VALID)   Commit:  I0
// Cycle  2:  I1:  LI    ar5,   0xb          (VALID)   Commit:  None
// Cycle  3:                                 (VALID)   Commit:  I1
// Cycle  4:  I2:  ADD   ar3,   ar4,   ar5   (VALID)   Commit:  None
// Cycle  5:                                 (VALID)   Commit:  I2
// Cycle  6:  I3:  ADD   ar3,   ar4,   ar5   (VALID)   Commit:  None
// Cycle  7:                                 (VALID)   Commit:  I3
// Cycle  8:  I4:  ADD   ar3,   ar4,   ar5   (VALID)   Commit:  None
// Cycle  9:                                 (VALID)   Commit:  I4
// Expected issue_q register values with commit / deallocation implemented:
// I0:  LI    pr1,   0xa (rs1 and rs2 values don't matter)
// I1:  LI    pr2,   0xb (rs1 and rs2 values don't matter)
// I2:  ADD   pr3,   pr1,   pr2
// I3:  ADD   pr4,   pr1,   pr2
// I4:  ADD   pr3,   pr1,   pr2
// Expected issue_q register values without commit / deallocation implemented:
// I0:  LI    pr1,   0xa (rs1 and rs2 values don't matter)
// I1:  LI    pr2,   0xb (rs1 and rs2 values don't matter)
// I2:  ADD   pr3,   pr1,   pr2
// I3:  ADD   pr4,   pr1,   pr2
// I4:  ADD   pr5,   pr1,   pr2
module simple_tb import ariane_pkg::*; #(
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
        issue_n.valid = 1'b1; // I0
        issue_n.sbe.rd[PHYS_REG_WIDTH-1:0] = 4; // ar4
        issue_n.sbe.rs1[PHYS_REG_WIDTH-1:0] = 1'bx; // don't care
        issue_n.sbe.rs2[PHYS_REG_WIDTH-1:0] = 1'bx; // don't care 
        fetch_entry_ready_i = 1'b1;
        we_gp_i = 1'b0; // No committing instruction
        waddr_i = 0;
        #20 // Cycle 1
        $display("I0: rd %d rs1 %d rs2 %d", 
                 issue_q.sbe.rd[PHYS_REG_WIDTH-1:0],
                 issue_q.sbe.rs1[PHYS_REG_WIDTH-1:0],
                 issue_q.sbe.rs2[PHYS_REG_WIDTH-1:0]);
        fetch_entry_ready_i = 1'b0; // No new instruction
        we_gp_i = 1'b1;
        waddr_i = 1; // I0 commit
        #20 // Cycle 2
        issue_n.valid = 1'b1; // I1
        issue_n.sbe.rd[PHYS_REG_WIDTH-1:0] = 5; // ar5 
        issue_n.sbe.rs1[PHYS_REG_WIDTH-1:0] = 1'bx; // don't care 
        issue_n.sbe.rs2[PHYS_REG_WIDTH-1:0] = 1'bx; // don't care
        fetch_entry_ready_i = 1'b1;
        we_gp_i = 1'b0; // No committing instruction
        waddr_i = 0;
        #20 // Cycle 3
        $display("I1: rd %d rs1 %d rs2 %d", 
                 issue_q.sbe.rd[PHYS_REG_WIDTH-1:0],
                 issue_q.sbe.rs1[PHYS_REG_WIDTH-1:0],
                 issue_q.sbe.rs2[PHYS_REG_WIDTH-1:0]);
        fetch_entry_ready_i = 1'b0; // No new instruction
        we_gp_i = 1'b1;
        waddr_i = 2; // I1 commit
        #20 // Cycle 4
        issue_n.valid = 1'b1; // I2
        issue_n.sbe.rd[PHYS_REG_WIDTH-1:0] = 3; // ar3
        issue_n.sbe.rs1[PHYS_REG_WIDTH-1:0] = 4; // ar4 
        issue_n.sbe.rs2[PHYS_REG_WIDTH-1:0] = 5; // ar5
        fetch_entry_ready_i = 1'b1;
        we_gp_i = 1'b0; // No committing instruction
        waddr_i = 0;
        #20 // Cycle 5
        $display("I2: rd %d rs1 %d rs2 %d", 
                 issue_q.sbe.rd[PHYS_REG_WIDTH-1:0],
                 issue_q.sbe.rs1[PHYS_REG_WIDTH-1:0],
                 issue_q.sbe.rs2[PHYS_REG_WIDTH-1:0]);
        fetch_entry_ready_i = 1'b0; // No new instruction
        we_gp_i = 1'b1;
        waddr_i = 3; // I2 commit
        #20 // Cycle 6
        issue_n.valid = 1'b1; // I3
        issue_n.sbe.rd[PHYS_REG_WIDTH-1:0] = 3; // ar3
        issue_n.sbe.rs1[PHYS_REG_WIDTH-1:0] = 4; // ar4 
        issue_n.sbe.rs2[PHYS_REG_WIDTH-1:0] = 5; // ar5
        fetch_entry_ready_i = 1'b1;
        we_gp_i = 1'b0; // No committing instruction
        waddr_i = 0;
        #20 // Cycle 7
        $display("I3: rd %d rs1 %d rs2 %d", 
                 issue_q.sbe.rd[PHYS_REG_WIDTH-1:0],
                 issue_q.sbe.rs1[PHYS_REG_WIDTH-1:0],
                 issue_q.sbe.rs2[PHYS_REG_WIDTH-1:0]);
        fetch_entry_ready_i = 1'b0; // No new instruction
        we_gp_i = 1'b1;
        waddr_i = 4; // I3 commit
        #20 // Cycle 8
        issue_n.valid = 1'b1; // I4
        issue_n.sbe.rd[PHYS_REG_WIDTH-1:0] = 3; // ar3
        issue_n.sbe.rs1[PHYS_REG_WIDTH-1:0] = 4; // ar4 
        issue_n.sbe.rs2[PHYS_REG_WIDTH-1:0] = 5; // ar5
        fetch_entry_ready_i = 1'b1;
        we_gp_i = 1'b0; // No committing instruction
        waddr_i = 0;
        #20 // Cycle 9
        $display("I4: rd %d rs1 %d rs2 %d", 
                 issue_q.sbe.rd[PHYS_REG_WIDTH-1:0],
                 issue_q.sbe.rs1[PHYS_REG_WIDTH-1:0],
                 issue_q.sbe.rs2[PHYS_REG_WIDTH-1:0]);
        fetch_entry_ready_i = 1'b0; // No new instruction
        we_gp_i = 1'b1;
        waddr_i = 3; // I4 commit
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
