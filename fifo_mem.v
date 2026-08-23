`timescale 1ns / 1ps

module fifo_mem #(
    parameter DEPTH = 8,
    parameter DATA_WIDTH = 16
)(
    input w_clk,
    input r_clk,

    input w_en,
    input r_en,

    input [DATA_WIDTH-1:0] data_in,
    output reg [DATA_WIDTH-1:0] data_out,

    input [$clog2(DEPTH):0] bin_wptr,
    input [$clog2(DEPTH):0] bin_rptr,

    input full,
    input empty
);

    // FIFO memory
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];


    // ------------------------------------------------
    // WRITE
    // ------------------------------------------------
    always @(posedge w_clk) begin

        if (w_en && !full) begin

            mem[bin_wptr[$clog2(DEPTH)-1:0]]
                <= data_in;

        end

    end


    // ------------------------------------------------
    // READ
    // ------------------------------------------------
    always @(posedge r_clk) begin

        if (r_en && !empty) begin

            data_out <=
                mem[bin_rptr[$clog2(DEPTH)-1:0]];

        end

    end

endmodule