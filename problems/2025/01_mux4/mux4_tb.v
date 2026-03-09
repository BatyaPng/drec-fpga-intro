module mux4_tb;

parameter W = 16;

reg  [1:0]        tb_i_sel;

reg  [3:0][W-1:0] tb_i_data;

wire [W-1:0]      tb_o_data;

mux4 #(
    .WIDTH(W)
) dut (
    .i_sel(tb_i_sel),
    .i_data(tb_i_data),
    .o_data(tb_o_data)
);

initial begin
    $display("Starting MUX4 Simulation...");

    $monitor("Time: %0t | sel: %b | data in (3 to 0): %h %h %h %h | OUT: %h",
             $time, tb_i_sel, tb_i_data[3], tb_i_data[2], tb_i_data[1], tb_i_data[0], tb_o_data);

    tb_i_data[0] = 16'hAAAA;
    tb_i_data[1] = 16'hBBBB;
    tb_i_data[2] = 16'hCCCC;
    tb_i_data[3] = 16'hDDDD;

    tb_i_sel = 2'b00; #10;
    tb_i_sel = 2'b01; #10;
    tb_i_sel = 2'b10; #10;
    tb_i_sel = 2'b11; #10;

    tb_i_data[0] = 16'h1111;
    tb_i_data[3] = 16'h4444;

    tb_i_sel = 2'b00; #10;
    tb_i_sel = 2'b11; #10;

    $display("Simulation complete.");
    $finish;
end

endmodule
