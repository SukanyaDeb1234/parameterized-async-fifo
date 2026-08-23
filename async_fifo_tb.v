`timescale 1ns / 1ps

module async_fifo_tb;

    parameter DEPTH = 8;
    parameter DATA_WIDTH = 16;

    // ------------------------------------------------
    // TESTBENCH SIGNALS
    // ------------------------------------------------
    reg rd_clk;
    reg wr_clk;

    reg rd_rstn;
    reg wr_rstn;

    reg rd_en;
    reg wr_en;

    reg [DATA_WIDTH-1:0] data_in;

    wire [DATA_WIDTH-1:0] data_out;

    wire full;
    wire empty;


    // ------------------------------------------------
    // DUT
    // ------------------------------------------------
    async_fifo #(
        .DEPTH(DEPTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .r_clk(rd_clk),
        .w_clk(wr_clk),
        .r_rstn(rd_rstn),
        .w_rstn(wr_rstn),
        .r_en(rd_en),
        .w_en(wr_en),
        .data_in(data_in),
        .data_out(data_out),
        .full(full),
        .empty(empty)
    );


    // ------------------------------------------------
    // WRITE CLOCK
    // Period = 60 ns
    // ------------------------------------------------
    always #30 wr_clk = ~wr_clk;


    // ------------------------------------------------
    // READ CLOCK
    // Period = 50 ns
    // ------------------------------------------------
    always #25 rd_clk = ~rd_clk;


    // ------------------------------------------------
    // INITIAL RESET
    // ------------------------------------------------
    initial begin

        rd_clk  = 0;
        wr_clk  = 0;

        rd_rstn = 0;
        wr_rstn = 0;

        rd_en   = 0;
        wr_en   = 0;

        data_in = 0;

        #40;

        rd_rstn = 1;
        wr_rstn = 1;

    end


    // ------------------------------------------------
    // WRITE PROCESS
    // Writes: 1, 2, 3, 4, 5
    // ------------------------------------------------
    initial begin

        #60;

        // Write 1
        @(negedge wr_clk);
        if (!full) begin
            wr_en   = 1;
            data_in = 16'd1;
        end

        @(negedge wr_clk);
        wr_en = 0;


        // Write 2
        @(negedge wr_clk);
        if (!full) begin
            wr_en   = 1;
            data_in = 16'd2;
        end

        @(negedge wr_clk);
        wr_en = 0;


        // Write 3
        @(negedge wr_clk);
        if (!full) begin
            wr_en   = 1;
            data_in = 16'd3;
        end

        @(negedge wr_clk);
        wr_en = 0;


        // Write 4
        @(negedge wr_clk);
        if (!full) begin
            wr_en   = 1;
            data_in = 16'd4;
        end

        @(negedge wr_clk);
        wr_en = 0;


        // Write 5
        @(negedge wr_clk);
        if (!full) begin
            wr_en   = 1;
            data_in = 16'd5;
        end

        @(negedge wr_clk);
        wr_en = 0;

    end


    // ------------------------------------------------
    // READ PROCESS
    // Reads 1, 2, 3, 4, 5
    // ------------------------------------------------
    initial begin

        // Wait for writes and clock-domain synchronization
        #500;


        // Read 1
        @(negedge rd_clk);
        if (!empty)
            rd_en = 1;

        @(negedge rd_clk);
        rd_en = 0;


        // Read 2
        @(negedge rd_clk);
        if (!empty)
            rd_en = 1;

        @(negedge rd_clk);
        rd_en = 0;


        // Read 3
        @(negedge rd_clk);
        if (!empty)
            rd_en = 1;

        @(negedge rd_clk);
        rd_en = 0;


        // Read 4
        @(negedge rd_clk);
        if (!empty)
            rd_en = 1;

        @(negedge rd_clk);
        rd_en = 0;


        // Read 5
        @(negedge rd_clk);
        if (!empty)
            rd_en = 1;

        @(negedge rd_clk);
        rd_en = 0;


        #100;

        $finish;

    end


    // ------------------------------------------------
    // MONITOR
    // ------------------------------------------------
    initial begin

        $monitor(
            "Time=%0t | data_in=%0d | data_out=%0d | wr_en=%b | rd_en=%b | full=%b | empty=%b",
            $time,
            data_in,
            data_out,
            wr_en,
            rd_en,
            full,
            empty
        );

    end

endmodule

