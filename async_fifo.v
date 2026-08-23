`timescale 1ns / 1ps

module async_fifo #(
    parameter DEPTH = 8,
    parameter DATA_WIDTH = 16
)(
    input  r_clk,
    input  w_clk,

    input  r_rstn,
    input  w_rstn,

    input  r_en,
    input  w_en,

    input  [DATA_WIDTH-1:0] data_in,
    output [DATA_WIDTH-1:0] data_out,

    output full,
    output empty
);

    // Pointer width:
    // DEPTH = 8 -> $clog2(8) = 3
    // Total pointer width = 4 bits
    wire [$clog2(DEPTH):0] rptr;
    wire [$clog2(DEPTH):0] wptr;

    wire [$clog2(DEPTH):0] gry_rptr;
    wire [$clog2(DEPTH):0] gry_wptr;

    wire [$clog2(DEPTH):0] read_pointer_synced;
    wire [$clog2(DEPTH):0] write_pointer_synced;


    // ------------------------------------------------
    // WRITE POINTER
    // ------------------------------------------------
    write_pointer #(
        .DEPTH(DEPTH)
    ) wr_pointer_inst (

        .w_clk(w_clk),
        .rstn(w_rstn),
        .w_en(w_en),

        .gry_rptr(read_pointer_synced),

        .full(full),
        .bin_wptr(wptr),
        .gry_wptr(gry_wptr)
    );


    // ------------------------------------------------
    // READ POINTER
    // ------------------------------------------------
    read_pointer #(
        .DEPTH(DEPTH)
    ) rd_pointer_inst (

        .r_clk(r_clk),
        .rstn(r_rstn),
        .r_en(r_en),

        .gry_wptr(write_pointer_synced),

        .empty(empty),
        .gry_rptr(gry_rptr),
        .bin_rptr(rptr)
    );


    // ------------------------------------------------
    // READ POINTER -> WRITE CLOCK DOMAIN
    // ------------------------------------------------
    flop_synchronizer #(
        .DEPTH(DEPTH)
    ) ff_sync_one (

        .clk(w_clk),
        .rstn(w_rstn),

        .data_in(gry_rptr),
        .data_out(read_pointer_synced)
    );


    // ------------------------------------------------
    // WRITE POINTER -> READ CLOCK DOMAIN
    // ------------------------------------------------
    flop_synchronizer #(
        .DEPTH(DEPTH)
    ) ff_sync_two (

        .clk(r_clk),
        .rstn(r_rstn),

        .data_in(gry_wptr),
        .data_out(write_pointer_synced)
    );


    // ------------------------------------------------
    // FIFO MEMORY
    // ------------------------------------------------
    fifo_mem #(
        .DEPTH(DEPTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) fifo_inst (

        .w_clk(w_clk),
        .r_clk(r_clk),

        .w_en(w_en),
        .r_en(r_en),

        .data_in(data_in),
        .data_out(data_out),

        .bin_wptr(wptr),
        .bin_rptr(rptr),

        .full(full),
        .empty(empty)
    );

endmodule
