// Testbench modeled off Example 1 from the assignment handout
// Input sequence:
// Cycle  0:  I0:  LI   ar10,   0x4          (VALID)   Commit:  None
// Cycle  1:  I1:  LI   ar11,   0x8          (VALID)   Commit:  I0
// Cycle  2:  I2:  LI   ar16,   0xb          (VALID)   Commit:  I1
// Cycle  3:  I3:  ADD   ar8,  ar10,  ar11   (VALID)   Commit:  None
// Cycle  4:  I4:  MUL   ar8,  ar16,  ar11   (VALID)   Commit:  I2
// Cycle  5:  I5:  ADD  ar12,   ar8,  ar10   (INVALID) Commit:  I3
// Cycle  6:  I6:  MUL  ar12,   ar8,  ar22   (VALID)   Commit:  I4
// Cycle  7:                                           Commit:  I6
// Cycle  8:  I7:  DIV  ar12,   ar8,  ar10   (VALID)   Commit:  None
// Cycle  9:                                           Commit:  I7
// Cycle 10:  I8:  ADD   ar0,   ar0,   ar0   (VALID)   Commit:  None
// Cycle 11:                                           Commit:  I8
// Expected issue_q register values with commit / deallocation implemented:
// I0:  LI    pr1,   0x4 (rs1 and rs2 values don't matter)
// I1:  LI    pr2,   0x8 (rs1 and rs2 values don't matter)
// I2:  LI    pr3,   0xb (rs1 and rs2 values don't matter)
// I3:  ADD   pr4,   pr1,   pr2
// I4:  MUL   pr5,   pr3,   pr2
// I5:  Invalid Instruction (register values don't matter)
// I6:  MUL   pr6,   pr5,   pr0
// I7:  DIV   pr4,   pr5,   pr1
// I8:  ADD   pr0,   pr0,   pr0
// Expected issue_q register values without commit / deallocation implemented:
// I0:  LI    pr1,   0x4 (rs1 and rs2 values don't matter)
// I1:  LI    pr2,   0x8 (rs1 and rs2 values don't matter)
// I2:  LI    pr3,   0xb (rs1 and rs2 values don't matter)
// I3:  ADD   pr4,   pr1,   pr2
// I4:  MUL   pr5,   pr3,   pr2
// I5:  Invalid Instruction (register values don't matter)
// I6:  MUL   pr6,   pr5,   pr0
// I7:  DIV   pr7,   pr5,   pr1
// I8:  ADD   pr0,   pr0,   pr0
module example1_tb import ariane_pkg::*; #(
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
        issue_n.sbe.rd[PHYS_REG_WIDTH-1:0] = 10; // ar10
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
        issue_n.valid = 1'b1; // I1
        issue_n.sbe.rd[PHYS_REG_WIDTH-1:0] = 11; // ar11
        issue_n.sbe.rs1[PHYS_REG_WIDTH-1:0] = 1'bx; // don't care
        issue_n.sbe.rs2[PHYS_REG_WIDTH-1:0] = 1'bx; // don't care
        fetch_entry_ready_i = 1'b1;
        we_gp_i = 1'b1;
        waddr_i = 1; // I0 commit
        #20 // Cycle 2
        $display("I1: rd %d rs1 %d rs2 %d", 
                 issue_q.sbe.rd[PHYS_REG_WIDTH-1:0],
                 issue_q.sbe.rs1[PHYS_REG_WIDTH-1:0],
                 issue_q.sbe.rs2[PHYS_REG_WIDTH-1:0]);
        issue_n.valid = 1'b1; // I2
        issue_n.sbe.rd[PHYS_REG_WIDTH-1:0] = 16; // ar16 
        issue_n.sbe.rs1[PHYS_REG_WIDTH-1:0] = 1'bx; // don't care
        issue_n.sbe.rs2[PHYS_REG_WIDTH-1:0] = 1'bx; // don't care
        fetch_entry_ready_i = 1'b1;
        we_gp_i = 1'b1;
        waddr_i = 2; // I1 commit
        #20 // Cycle 3
        $display("I2: rd %d rs1 %d rs2 %d", 
                 issue_q.sbe.rd[PHYS_REG_WIDTH-1:0],
                 issue_q.sbe.rs1[PHYS_REG_WIDTH-1:0],
                 issue_q.sbe.rs2[PHYS_REG_WIDTH-1:0]);
        issue_n.valid = 1'b1; // I3
        issue_n.sbe.rd[PHYS_REG_WIDTH-1:0] = 8; // ar8 
        issue_n.sbe.rs1[PHYS_REG_WIDTH-1:0] = 10; // ar10 
        issue_n.sbe.rs2[PHYS_REG_WIDTH-1:0] = 11; // ar11
        fetch_entry_ready_i = 1'b1;
        we_gp_i = 1'b0; // No committing instruction
        waddr_i = 0;
        #20 // Cycle 4
        $display("I3: rd %d rs1 %d rs2 %d", 
                 issue_q.sbe.rd[PHYS_REG_WIDTH-1:0],
                 issue_q.sbe.rs1[PHYS_REG_WIDTH-1:0],
                 issue_q.sbe.rs2[PHYS_REG_WIDTH-1:0]);
        issue_n.valid = 1'b1; // I4
        issue_n.sbe.rd[PHYS_REG_WIDTH-1:0] = 8; // ar8 
        issue_n.sbe.rs1[PHYS_REG_WIDTH-1:0] = 16; // ar16 
        issue_n.sbe.rs2[PHYS_REG_WIDTH-1:0] = 11; // ar11
        fetch_entry_ready_i = 1'b1;
        we_gp_i = 1'b1;
        waddr_i = 3; // I2 commit
        #20 // Cycle 5
        $display("I4: rd %d rs1 %d rs2 %d", 
                 issue_q.sbe.rd[PHYS_REG_WIDTH-1:0],
                 issue_q.sbe.rs1[PHYS_REG_WIDTH-1:0],
                 issue_q.sbe.rs2[PHYS_REG_WIDTH-1:0]);
        issue_n.valid = 1'b0; // I5 invalid
        issue_n.sbe.rd[PHYS_REG_WIDTH-1:0] = 12; // ar12 
        issue_n.sbe.rs1[PHYS_REG_WIDTH-1:0] = 8; // ar8 
        issue_n.sbe.rs2[PHYS_REG_WIDTH-1:0] = 10; // ar10
        fetch_entry_ready_i = 1'b1;
        we_gp_i = 1'b1;
        waddr_i = 4; // I3 commit
        #20 // Cycle 6
        $display("I5: rd %d rs1 %d rs2 %d", 
                 issue_q.sbe.rd[PHYS_REG_WIDTH-1:0],
                 issue_q.sbe.rs1[PHYS_REG_WIDTH-1:0],
                 issue_q.sbe.rs2[PHYS_REG_WIDTH-1:0]);
        issue_n.valid = 1'b1; // I6
        issue_n.sbe.rd[PHYS_REG_WIDTH-1:0] = 12; // ar12 
        issue_n.sbe.rs1[PHYS_REG_WIDTH-1:0] = 8; // ar8 
        issue_n.sbe.rs2[PHYS_REG_WIDTH-1:0] = 22; // ar22
        fetch_entry_ready_i = 1'b1;
        we_gp_i = 1'b1;
        waddr_i = 5; // I4 commit
        #20 // Cycle 7
        $display("I6: rd %d rs1 %d rs2 %d", 
                 issue_q.sbe.rd[PHYS_REG_WIDTH-1:0],
                 issue_q.sbe.rs1[PHYS_REG_WIDTH-1:0],
                 issue_q.sbe.rs2[PHYS_REG_WIDTH-1:0]);
        fetch_entry_ready_i = 1'b0; // No new instruction
        we_gp_i = 1'b1;
        waddr_i = 6; // I6 commit
        #20 // Cycle 8
        issue_n.valid = 1'b1; // I7
        issue_n.sbe.rd[PHYS_REG_WIDTH-1:0] = 12; // ar12 
        issue_n.sbe.rs1[PHYS_REG_WIDTH-1:0] = 8; // ar8
        issue_n.sbe.rs2[PHYS_REG_WIDTH-1:0] = 10; // ar10
        fetch_entry_ready_i = 1'b1;
        we_gp_i = 1'b0; // No committing instruction
        waddr_i = 0;
        #20 // Cycle 9
        $display("I7: rd %d rs1 %d rs2 %d", 
                 issue_q.sbe.rd[PHYS_REG_WIDTH-1:0],
                 issue_q.sbe.rs1[PHYS_REG_WIDTH-1:0],
                 issue_q.sbe.rs2[PHYS_REG_WIDTH-1:0]);
        fetch_entry_ready_i = 1'b0; // No new instruction
        we_gp_i = 1'b1;
        waddr_i = 4; // I7 commit
        #20 // Cycle 10
        issue_n.valid = 1'b1; // I8
        issue_n.sbe.rd[PHYS_REG_WIDTH-1:0] = 0; // ar0 
        issue_n.sbe.rs1[PHYS_REG_WIDTH-1:0] = 0; // ar0
        issue_n.sbe.rs2[PHYS_REG_WIDTH-1:0] = 0; // ar0
        fetch_entry_ready_i = 1'b1;
        we_gp_i = 1'b0; // No committing instruction
        waddr_i = 0;
        #20 // Cycle 11
        $display("I8: rd %d rs1 %d rs2 %d", 
                 issue_q.sbe.rd[PHYS_REG_WIDTH-1:0],
                 issue_q.sbe.rs1[PHYS_REG_WIDTH-1:0],
                 issue_q.sbe.rs2[PHYS_REG_WIDTH-1:0]);
        fetch_entry_ready_i = 1'b0; // No new instruction
        we_gp_i = 1'b1;
        waddr_i = 0; // I8 commit
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
