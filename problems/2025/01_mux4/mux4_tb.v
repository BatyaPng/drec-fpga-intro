module mux4_tb;

    // Parameter to match the DUT (scaled down to 16 for standard hex viewing)
    parameter W = 16;

    // Declare testbench signals
    reg  [1:0]        tb_i_sel;

    // This packed array syntax matches your module but requires SystemVerilog
    reg  [3:0][W-1:0] tb_i_data;

    wire [W-1:0]      tb_o_data;

    // Instantiate the Unit Under Test (UUT)
    mux4 #(
        .WIDTH(W)
    ) uut (
        .i_sel(tb_i_sel),
        .i_data(tb_i_data),
        .o_data(tb_o_data)
    );

    // Stimulus generation
    initial begin
        $display("Starting MUX4 Simulation...");

        // Monitor changes
        $monitor("Time: %0t | sel: %b | data in (3 to 0): %h %h %h %h | OUT: %h",
                 $time, tb_i_sel, tb_i_data[3], tb_i_data[2], tb_i_data[1], tb_i_data[0], tb_o_data);

        // Initialize the array with distinct hex values
        tb_i_data[0] = 16'hAAAA;
        tb_i_data[1] = 16'hBBBB;
        tb_i_data[2] = 16'hCCCC;
        tb_i_data[3] = 16'hDDDD;

        // Sweep through all select lines
        tb_i_sel = 2'b00; #10; // Should output AAAA
        tb_i_sel = 2'b01; #10; // Should output BBBB
        tb_i_sel = 2'b10; #10; // Should output CCCC
        tb_i_sel = 2'b11; #10; // Should output DDDD

        // Change the input array values to verify it still tracks
        tb_i_data[0] = 16'h1111;
        tb_i_data[3] = 16'h4444;

        tb_i_sel = 2'b00; #10; // Should output 1111
        tb_i_sel = 2'b11; #10; // Should output 4444

        // End simulation
        $display("Simulation complete.");
        $finish;
    end

endmodule
