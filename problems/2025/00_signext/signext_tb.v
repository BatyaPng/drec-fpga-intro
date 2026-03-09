`timescale 1ns/1ps

module signext_tb;

localparam N = 20;
localparam M = 32;

reg  [N-1:0] i_data;
wire [M-1:0] o_data_behavioral;
wire [M-1:0] o_data_structural;

integer errors = 0;

signext_b #(
    .N(N),
    .M(M)
) dut_b (
    .i_data(i_data),
    .o_data(o_data_behavioral)
);

signext_s #(
    .N(N),
    .M(M)
) dut_s (
    .i_data(i_data),
    .o_data(o_data_structural)
);

initial begin
    $dumpvars;

    i_data = $unsigned($random) % N;
    #10;
    compare(i_data, o_data_behavioral, o_data_structural);

    i_data = -($unsigned($random) % N) - 1;
    #10;
    compare(i_data, o_data_behavioral, o_data_structural);

    i_data = {1'b1, {(N-1){1'b0}}};
    #10;
    compare(i_data, o_data_behavioral, o_data_structural);

    if (errors == 0)
        $display("\n[RESULT] SUCCESS: All tests passed for N=%0d.", N);
    else
        $display("\n[RESULT] FAILURE: %d mismatches found for N=%0d.", errors, N);

    $finish;
end

task compare(
    input [N-1:0] in,
    input [M-1:0] behavioral,
    input [M-1:0] structural
);
    integer dec_in, dec_beh, dec_str;
    begin
        dec_in  = $signed(in);
        dec_beh = $signed(behavioral);
        dec_str = $signed(structural);

        if (dec_in !== dec_beh || dec_in !== dec_str) begin
            $display("[ERROR] Decimal Mismatch!");
            $display("  In (dec): %0d | Behavioral (dec): %0d | Structural (dec): %0d",
                     dec_in, dec_beh, dec_str);
            errors = errors + 1;
        end else begin
            $display("[PASS] Dec: %0d | Hex In: %h -> Hex Out: %h", dec_in, in, behavioral);
        end
    end
endtask

endmodule
