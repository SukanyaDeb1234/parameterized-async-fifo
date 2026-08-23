`timescale 1ns / 1ps

module flop_synchronizer #(
    parameter DEPTH = 8
)(
    input clk,
    input rstn,

    input [$clog2(DEPTH):0] data_in,
    output reg [$clog2(DEPTH):0] data_out
);

    reg [$clog2(DEPTH):0] sync_ff1;


    always @(posedge clk or negedge rstn) begin

        if (!rstn) begin

            sync_ff1 <= 0;
            data_out <= 0;

        end
        else begin

            sync_ff1 <= data_in;
            data_out <= sync_ff1;

        end

    end

endmodule