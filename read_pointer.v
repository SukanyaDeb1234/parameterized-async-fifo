`timescale 1ns / 1ps

module read_pointer #(
    parameter DEPTH = 8
)(
    input r_clk,
    input rstn,
    input r_en,

    input [$clog2(DEPTH):0] gry_wptr,

    output reg empty,
    output reg [$clog2(DEPTH):0] gry_rptr,
    output reg [$clog2(DEPTH):0] bin_rptr
);

    wire [$clog2(DEPTH):0] bin_nxt_ptr;
    wire [$clog2(DEPTH):0] gry_nxt_ptr;
    wire r_emp;


    // ------------------------------------------------
    // NEXT READ POINTER
    // ------------------------------------------------
    assign bin_nxt_ptr =
        (r_en && !empty) ?
        (bin_rptr + 1'b1) :
        bin_rptr;


    // Binary to Gray conversion
    assign gry_nxt_ptr =
        (bin_nxt_ptr >> 1) ^ bin_nxt_ptr;


    // ------------------------------------------------
    // READ POINTER REGISTERS
    // ------------------------------------------------
    always @(posedge r_clk or negedge rstn) begin

        if (!rstn) begin

            gry_rptr <= 0;
            bin_rptr <= 0;

        end
        else begin

            gry_rptr <= gry_nxt_ptr;
            bin_rptr <= bin_nxt_ptr;

        end

    end


    // ------------------------------------------------
    // EMPTY FLAG REGISTER
    // ------------------------------------------------
    always @(posedge r_clk or negedge rstn) begin

        if (!rstn)
            empty <= 1'b1;

        else
            empty <= r_emp;

    end


    // ------------------------------------------------
    // EMPTY DETECTION
    // ------------------------------------------------
    assign r_emp = (gry_wptr == gry_nxt_ptr);

endmodule