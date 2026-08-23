`timescale 1ns / 1ps

module write_pointer #(
    parameter DEPTH = 8
)(
    input w_clk,
    input rstn,
    input w_en,

    input [$clog2(DEPTH):0] gry_rptr,

    output reg full,
    output reg [$clog2(DEPTH):0] bin_wptr,
    output reg [$clog2(DEPTH):0] gry_wptr
);

    wire [$clog2(DEPTH):0] bin_nxt_ptr;
    wire [$clog2(DEPTH):0] gry_nxt_ptr;
    wire wr_full;


    // ------------------------------------------------
    // NEXT WRITE POINTER
    // ------------------------------------------------
    assign bin_nxt_ptr =
        (w_en && !full) ?
        (bin_wptr + 1'b1) :
        bin_wptr;


    // Binary to Gray conversion
    assign gry_nxt_ptr =
        (bin_nxt_ptr >> 1) ^ bin_nxt_ptr;


    // ------------------------------------------------
    // WRITE POINTER REGISTERS
    // ------------------------------------------------
    always @(posedge w_clk or negedge rstn) begin

        if (!rstn) begin

            bin_wptr <= 0;
            gry_wptr <= 0;

        end
        else begin

            bin_wptr <= bin_nxt_ptr;
            gry_wptr <= gry_nxt_ptr;

        end

    end


    // ------------------------------------------------
    // FULL FLAG REGISTER
    // ------------------------------------------------
    always @(posedge w_clk or negedge rstn) begin

        if (!rstn)
            full <= 1'b0;

        else
            full <= wr_full;

    end


    // ------------------------------------------------
    // FULL DETECTION
    // For power-of-2 FIFO depth
    // ------------------------------------------------
    assign wr_full =
        (gry_nxt_ptr ==
        {
            ~gry_rptr[$clog2(DEPTH):$clog2(DEPTH)-1],
            gry_rptr[$clog2(DEPTH)-2:0]
        });

endmodule