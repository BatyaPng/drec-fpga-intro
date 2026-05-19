module fifo #(
    parameter DATA_WIDTH = 0,
    parameter ADDR_WIDTH = 0
)(
    input logic                  clk,
    input logic                  rst_n,

    input  logic [DATA_WIDTH-1:0] i_wr_data,
    input  logic                  i_wr_vld,
    output logic                  o_wr_rdy,

    output logic [DATA_WIDTH-1:0] o_rd_data,
    output logic                  o_rd_vld,
    input  logic                  i_rd_rdy
);

localparam DEPTH = 2**ADDR_WIDTH;

logic [ADDR_WIDTH:0]   wr_ptr, rd_ptr;
logic [ADDR_WIDTH-1:0] wr_addr, rd_addr;
logic                  full, empty;
logic                  wr_en, rd_en;

logic [DATA_WIDTH-1:0] mem[DEPTH];

assign wr_addr  = wr_ptr[ADDR_WIDTH-1:0];
assign rd_addr  = rd_ptr[ADDR_WIDTH-1:0];
assign full     = (wr_addr == rd_addr) && (wr_ptr[ADDR_WIDTH] != rd_ptr[ADDR_WIDTH]);
assign empty    = (wr_addr == rd_addr) && (wr_ptr[ADDR_WIDTH] == rd_ptr[ADDR_WIDTH]);

assign wr_en    = i_wr_vld && !full;
assign rd_en    = i_rd_rdy && !empty;
assign o_wr_rdy = !full;
assign o_rd_vld = !empty;

always_ff @(posedge clk) begin
    if (wr_en) begin
        mem[wr_addr] <= i_wr_data;
    end
end

assign o_rd_data = mem[rd_addr];

always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        wr_ptr <= {(ADDR_WIDTH+1){1'b0}};
        rd_ptr <= {(ADDR_WIDTH+1){1'b0}};
    end else begin
        if (wr_en) begin
            wr_ptr <= wr_ptr + 1'b1;
        end
        if (rd_en) begin
            rd_ptr <= rd_ptr + 1'b1;
        end
    end
end

endmodule
