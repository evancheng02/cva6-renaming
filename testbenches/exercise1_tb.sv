// Testbench modeled off Exercise 1 from the assignment handout
// IMPORTANT NOTE: In order for this testbench to work correctly
// with instruction commits and register deallocation, you must 
// replace the placeholder pr0 in the lines marked with instruction
// commit with the physical register rd values of the renamed
// instructions. Since these are worked out as part of the written
// exercise, they are not provided for you here.
// Input sequence:
// Cycle  0:  I0:  LI    ar7,   0xa          (VALID)   Commit: None 
// Cycle  1:  I1:  LI   ar11,   0x4          (VALID)   Commit: I0 
// Cycle  2:  I2:  LI   ar19,   0xc          (VALID)   Commit: I1 
// Cycle  3:  I3:  MUL   ar6,   ar7,  ar11   (VALID)   Commit: I2
// Cycle  4:                                           Commit: I3
// Cycle  5:  I4:  ADD   ar0,   ar0,   ar0   (VALID)   Commit: None
// Cycle  6:  I5:  MUL   ar7,  ar19,   ar7   (VALID)   Commit: I4 
// Cycle  7:  I6:  MUL   ar6,  ar11,  ar25   (VALID)   Commit: None
// Cycle  8:  I7:  ADD   ar7,   ar7,   ar6   (INVALID) Commit: I5
// Cycle  9:  I8:  SUB   ar7,   ar6,   ar0   (VALID)   Commit: I6
// Cycle 10:                                           Commit: I8
module exercise1_tb import ariane_pkg::*; #(
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
        issue_n.sbe.rd[PHYS_REG_WIDTH-1:0] = 7; // ar7
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
        waddr_i = 0; // I0 commit - replace with I0 physical rd
        #20 // Cycle 2
        $display("I1: rd %d rs1 %d rs2 %d", 
                 issue_q.sbe.rd[PHYS_REG_WIDTH-1:0],
                 issue_q.sbe.rs1[PHYS_REG_WIDTH-1:0],
                 issue_q.sbe.rs2[PHYS_REG_WIDTH-1:0]);
        issue_n.valid = 1'b1; // I2
        issue_n.sbe.rd[PHYS_REG_WIDTH-1:0] = 19; // ar6
        issue_n.sbe.rs1[PHYS_REG_WIDTH-1:0] = 1'bx; // don't care
        issue_n.sbe.rs2[PHYS_REG_WIDTH-1:0] = 1'bx; // don't care
        fetch_entry_ready_i = 1'b1;
        we_gp_i = 1'b1;
        waddr_i = 0; // I1 commit - replace with I1 physical rd
        #20 // Cycle 3
        $display("I2: rd %d rs1 %d rs2 %d", 
                 issue_q.sbe.rd[PHYS_REG_WIDTH-1:0],
                 issue_q.sbe.rs1[PHYS_REG_WIDTH-1:0],
                 issue_q.sbe.rs2[PHYS_REG_WIDTH-1:0]);
        issue_n.valid = 1'b1; // I3
        issue_n.sbe.rd[PHYS_REG_WIDTH-1:0] = 6; // ar6 
        issue_n.sbe.rs1[PHYS_REG_WIDTH-1:0] = 7; // ar7
        issue_n.sbe.rs2[PHYS_REG_WIDTH-1:0] = 11; // ar11
        fetch_entry_ready_i = 1'b1;
        we_gp_i = 1'b1;
        waddr_i = 0; // I2 commit - replace with I2 physical rd
        #20 // Cycle 4
        $display("I3: rd %d rs1 %d rs2 %d", 
                 issue_q.sbe.rd[PHYS_REG_WIDTH-1:0],
                 issue_q.sbe.rs1[PHYS_REG_WIDTH-1:0],
                 issue_q.sbe.rs2[PHYS_REG_WIDTH-1:0]);
        issue_n.valid = 1'b0; // No new instruction
        fetch_entry_ready_i = 1'b1;
        we_gp_i = 1'b1;
        waddr_i = 0; // I3 commit - replace with I3 physical rd
        #20 // Cycle 5
        issue_n.valid = 1'b1; // I4
        issue_n.sbe.rd[PHYS_REG_WIDTH-1:0] = 0; // ar0 
        issue_n.sbe.rs1[PHYS_REG_WIDTH-1:0] = 0; // ar0
        issue_n.sbe.rs2[PHYS_REG_WIDTH-1:0] = 0; // ar0
        fetch_entry_ready_i = 1'b1;
        we_gp_i = 1'b0; // No committing instruction
        waddr_i = 0;
        #20 // Cycle 6
        $display("I4: rd %d rs1 %d rs2 %d", 
                 issue_q.sbe.rd[PHYS_REG_WIDTH-1:0],
                 issue_q.sbe.rs1[PHYS_REG_WIDTH-1:0],
                 issue_q.sbe.rs2[PHYS_REG_WIDTH-1:0]);
        issue_n.valid = 1'b1; // I5
        issue_n.sbe.rd[PHYS_REG_WIDTH-1:0] = 7; // ar7 
        issue_n.sbe.rs1[PHYS_REG_WIDTH-1:0] = 19; // ar19 
        issue_n.sbe.rs2[PHYS_REG_WIDTH-1:0] = 7; // ar7
        fetch_entry_ready_i = 1'b1;
        we_gp_i = 1'b1;
        waddr_i = 0; // I4 commit - replace with I4 physical rd
        #20 // Cycle 7
        $display("I5: rd %d rs1 %d rs2 %d", 
                 issue_q.sbe.rd[PHYS_REG_WIDTH-1:0],
                 issue_q.sbe.rs1[PHYS_REG_WIDTH-1:0],
                 issue_q.sbe.rs2[PHYS_REG_WIDTH-1:0]);
        issue_n.valid = 1'b1; // I6
        issue_n.sbe.rd[PHYS_REG_WIDTH-1:0] = 6; // ar6
        issue_n.sbe.rs1[PHYS_REG_WIDTH-1:0] = 11; // ar11
        issue_n.sbe.rs2[PHYS_REG_WIDTH-1:0] = 25; // ar25
        fetch_entry_ready_i = 1'b1;
        we_gp_i = 1'b0; // No committing instruction
        waddr_i = 0;
        #20 // Cycle 8
        $display("I6: rd %d rs1 %d rs2 %d", 
                 issue_q.sbe.rd[PHYS_REG_WIDTH-1:0],
                 issue_q.sbe.rs1[PHYS_REG_WIDTH-1:0],
                 issue_q.sbe.rs2[PHYS_REG_WIDTH-1:0]);
        issue_n.valid = 1'b0; // I7 invalid
        issue_n.sbe.rd[PHYS_REG_WIDTH-1:0] = 7; // ar7
        issue_n.sbe.rs1[PHYS_REG_WIDTH-1:0] = 7; // ar7
        issue_n.sbe.rs2[PHYS_REG_WIDTH-1:0] = 6; // ar6
        fetch_entry_ready_i = 1'b1;
        we_gp_i = 1'b1;
        waddr_i = 0; // I5 commit - replace with I5 physical rd
        #20 // Cycle 9
        $display("I7: rd %d rs1 %d rs2 %d", 
                 issue_q.sbe.rd[PHYS_REG_WIDTH-1:0],
                 issue_q.sbe.rs1[PHYS_REG_WIDTH-1:0],
                 issue_q.sbe.rs2[PHYS_REG_WIDTH-1:0]);
        issue_n.valid = 1'b1; // I8
        issue_n.sbe.rd[PHYS_REG_WIDTH-1:0] = 7; // ar7
        issue_n.sbe.rs1[PHYS_REG_WIDTH-1:0] = 6; // ar6
        issue_n.sbe.rs2[PHYS_REG_WIDTH-1:0] = 0; // ar0
        fetch_entry_ready_i = 1'b1;
        we_gp_i = 1'b1;
        waddr_i = 0; // I6 commit - replace with I6 physical rd
        #20 // Cycle 10
        $display("I8: rd %d rs1 %d rs2 %d", 
                 issue_q.sbe.rd[PHYS_REG_WIDTH-1:0],
                 issue_q.sbe.rs1[PHYS_REG_WIDTH-1:0],
                 issue_q.sbe.rs2[PHYS_REG_WIDTH-1:0]);
        fetch_entry_ready_i = 1'b0; // No new instruction
        we_gp_i = 1'b1;
        waddr_i = 0; // I8 commit - replace with I8 physical rd
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
