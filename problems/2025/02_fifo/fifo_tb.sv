`timescale 1ns/1ps

module fifo_tb;

parameter DATA_WIDTH = 8;
parameter ADDR_WIDTH = 3;

logic                  clk;
logic                  rst_n;
logic [DATA_WIDTH-1:0] i_wr_data;
logic                  i_wr_vld;
logic                  o_wr_rdy;
logic [DATA_WIDTH-1:0] o_rd_data;
logic                  o_rd_vld;
logic                  i_rd_rdy;

fifo #(
    .DATA_WIDTH(DATA_WIDTH),
    .ADDR_WIDTH(ADDR_WIDTH)
) dut (
    .clk      (clk),
    .rst_n    (rst_n),
    .i_wr_data(i_wr_data),
    .i_wr_vld (i_wr_vld),
    .o_wr_rdy (o_wr_rdy),
    .o_rd_data(o_rd_data),
    .o_rd_vld (o_rd_vld),
    .i_rd_rdy (i_rd_rdy)
);

always #5 clk = ~clk;

task automatic write_data(input logic [DATA_WIDTH-1:0] data);
    begin
        i_wr_vld  = 1'b1;
        i_wr_data = data;
        @(posedge clk);
        while (!o_wr_rdy) @(posedge clk);
        i_wr_vld  = 1'b0;
    end
endtask

task automatic read_data();
    begin
        i_rd_rdy = 1'b1;
        @(posedge clk);
        while (!o_rd_vld) @(posedge clk);
        i_rd_rdy = 1'b0;
    end
endtask

initial begin
    begin
        clk       = 1'b0;
        rst_n     = 1'b0;
        i_wr_data = 0;
        i_wr_vld  = 1'b0;
        i_rd_rdy  = 1'b0;

        #20;
        rst_n = 1'b1;
        #10;

        write_data(8'hAA);
        write_data(8'hBB);
        write_data(8'hCC);

        #20;
        read_data();
        read_data();
        read_data();

       #20;
        for (int i = 0; i < 8; i++)
            write_data(i + 10);

        #5;
        if (o_wr_rdy)
            $fatal;

        for (int i = 0; i < 8; i++)
            read_data();

        #5;
        if (o_rd_vld)
            $fatal;

        #20;
        i_wr_vld  = 1'b1;
        i_wr_data = 8'h99;
        i_rd_rdy  = 1'b1;

        @(posedge clk);
        while (!o_wr_rdy || !o_rd_vld) @(posedge clk);

        i_wr_vld  = 1'b0;
        i_rd_rdy  = 1'b0;

        #50;
        $finish;
    end
end

always @(posedge clk) begin
    begin
        if (i_wr_vld && o_wr_rdy)
            $display("[Write] Data: %h", i_wr_data);
        if (i_rd_rdy && o_rd_vld)
            $display("[Read ] Data: %h", o_rd_data);
    end
end

endmodule
