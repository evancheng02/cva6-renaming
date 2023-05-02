// Renaming map module
// While you are free to structure your implementation however you
// like, you are advised to only add code to the TODO sections
module renaming_map import ariane_pkg::*; #(
    parameter int unsigned ARCH_REG_WIDTH = 5,
    parameter int unsigned PHYS_REG_WIDTH = 6
)(
    // Clock and reset signals
    input logic clk_i,
    input logic rst_ni,

    // Indicator that there is a new instruction to rename
    input logic fetch_entry_ready_i,

    // Input decoded instruction entry from the ID stage
    input issue_struct_t issue_n,

    // Output instruction entry with registers renamed
    output issue_struct_t issue_q,

    // Destination register of the committing instruction
    input logic [PHYS_REG_WIDTH-1:0] waddr_i,
    
    // Indicator signal that there is a new committing instruction
    input logic we_gp_i
);

    // 32 architectural registers and 64 physical registers
    localparam ARCH_NUM_REGS = 2**ARCH_REG_WIDTH;
    localparam PHYS_NUM_REGS = 2**PHYS_REG_WIDTH;

    logic [PHYS_REG_WIDTH-1:0] rs1;
    logic [PHYS_REG_WIDTH-1:0] rs2;
    logic [PHYS_REG_WIDTH-1:0] rd;

    // TODO: ADD STRUCTURES TO EXECUTE REGISTER RENAMING

    // Positive clock edge used for renaming new instructions
    always @(posedge clk_i, negedge rst_ni) begin
        // Processor reset: revert renaming state to reset conditions    
        if (~rst_ni) begin

            // TODO: ADD LOGIC TO RESET RENAMING STATE
    
        // New incoming valid instruction to rename   
        end else if (fetch_entry_ready_i && issue_n.valid) begin
            // Get values of registers in new instruction
            rs1 = issue_n.sbe.rs1[PHYS_REG_WIDTH-1:0];
            rs2 = issue_n.sbe.rs2[PHYS_REG_WIDTH-1:0];
            rd = issue_n.sbe.rd[PHYS_REG_WIDTH-1:0];

            // Set outgoing instruction to incoming instruction without
            // renaming by default. Keep this line since all fields of the 
            // incoming issue_struct_t should carry over to the output
            // except for the register values, which you may rename below
            issue_q = issue_n;

            // TODO: ADD LOGIC TO RENAME OUTGOING INSTRUCTION
            // The registers of the outgoing instruction issue_q can be set like so:
            // issue_q.sbe.rs1[PHYS_REG_WIDTH-1:0] = your new rs1 register value;
            // issue_q.sbe.rs2[PHYS_REG_WIDTH-1:0] = your new rs2 register value;
            // issue_q.sbe.rd[PHYS_REG_WIDTH-1:0] = your new rd register value;
    
        // If there is no new instruction this clock cycle, simply pass on the
        // incoming instruction without renaming
        end else begin
            issue_q = issue_n;
        end
    end
    

    // Negative clock edge used for physical register deallocation 
    always @(negedge clk_i) begin
        if (rst_ni) begin
            // If there is a new committing instruction and its prd is not pr0,
            // execute register deallocation logic to reuse physical registers
            if (we_gp_i && waddr_i != 0) begin
        
                // TODO: IMPLEMENT REGISTER DEALLOCATION LOGIC    

            end
        end
    end
endmodule
