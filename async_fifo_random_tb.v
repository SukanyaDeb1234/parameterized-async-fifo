`timescale 1ns / 1ps

module async_fifo_random_tb;

    parameter DEPTH = 8;
    parameter DATA_WIDTH = 16;

    // =====================================================
    // DUT SIGNALS
    // =====================================================

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


    // =====================================================
    // REFERENCE FIFO
    // =====================================================

    reg [DATA_WIDTH-1:0] expected_mem [0:1023];

    integer ref_wr_ptr;
    integer ref_rd_ptr;
    integer ref_count;

    integer pass_count;
    integer error_count;

    reg [DATA_WIDTH-1:0] expected_value;


    // =====================================================
    // DUT
    // =====================================================

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


    // =====================================================
    // CLOCKS
    // =====================================================

    // Write clock = 60 ns
    always #30 wr_clk = ~wr_clk;

    // Read clock = 50 ns
    always #25 rd_clk = ~rd_clk;


    // =====================================================
    // INITIALIZATION
    // =====================================================

    initial begin

        rd_clk = 0;
        wr_clk = 0;

        rd_rstn = 0;
        wr_rstn = 0;

        rd_en = 0;
        wr_en = 0;

        data_in = 0;

        ref_wr_ptr = 0;
        ref_rd_ptr = 0;
        ref_count = 0;

        pass_count = 0;
        error_count = 0;

        expected_value = 0;

        #100;

        rd_rstn = 1;
        wr_rstn = 1;

        $display("");
        $display("========================================");
        $display("RANDOMIZED ASYNC FIFO TEST");
        $display("========================================");

    end


    // =====================================================
    // RANDOM WRITE CONTROL
    // =====================================================

    always @(negedge wr_clk) begin

        if (wr_rstn == 1'b1) begin

            if (($random % 2) == 0) begin

                if (full == 1'b0) begin

                    wr_en = 1'b1;
                    data_in = $random;

                end
                else begin

                    wr_en = 1'b0;

                end

            end
            else begin

                wr_en = 1'b0;

            end

        end
        else begin

            wr_en = 1'b0;

        end

    end


    // =====================================================
    // REFERENCE WRITE
    // =====================================================

    always @(posedge wr_clk) begin

        if ((wr_rstn == 1'b1) &&
            (wr_en == 1'b1) &&
            (full == 1'b0)) begin

            expected_mem[ref_wr_ptr] = data_in;

            ref_wr_ptr = ref_wr_ptr + 1;

            ref_count = ref_count + 1;

            if (ref_count > 1024) begin

                $display(
                    "[%0t] ERROR: Reference FIFO overflow",
                    $time
                );

                error_count = error_count + 1;

            end

        end

    end


    // =====================================================
    // RANDOM READ CONTROL
    // =====================================================

    always @(negedge rd_clk) begin

        if (rd_rstn == 1'b1) begin

            if (($random % 2) == 0) begin

                if (empty == 1'b0)
                    rd_en = 1'b1;
                else
                    rd_en = 1'b0;

            end
            else begin

                rd_en = 1'b0;

            end

        end
        else begin

            rd_en = 1'b0;

        end

    end


    // =====================================================
    // REFERENCE READ / CHECK
    // =====================================================

    always @(posedge rd_clk) begin

        if ((rd_rstn == 1'b1) &&
            (rd_en == 1'b1) &&
            (empty == 1'b0)) begin

            #1;

            expected_value = expected_mem[ref_rd_ptr];

            if (data_out === expected_value) begin

                pass_count = pass_count + 1;

            end
            else begin

                $display(
                    "[%0t] READ ERROR: Expected=%0d Actual=%0d",
                    $time,
                    expected_value,
                    data_out
                );

                error_count = error_count + 1;

            end

            ref_rd_ptr = ref_rd_ptr + 1;
            ref_count = ref_count - 1;

        end

    end


    // =====================================================
    // TEST CONTROL
    // =====================================================

    initial begin

        wait(rd_rstn == 1'b1);
        wait(wr_rstn == 1'b1);

        // Run randomized traffic
        #20000;

        $display("");
        $display("========================================");
        $display("RANDOMIZED TEST COMPLETE");
        $display("========================================");

        $display(
            "PASS COUNT  = %0d",
            pass_count
        );

        $display(
            "ERROR COUNT = %0d",
            error_count
        );

        $display(
            "REFERENCE FIFO COUNT = %0d",
            ref_count
        );


        if (error_count == 0) begin

            $display("");
            $display("************************************");
            $display("* RANDOMIZED TEST : PASSED         *");
            $display("************************************");
            $display("");

        end
        else begin

            $display("");
            $display("************************************");
            $display("* RANDOMIZED TEST : FAILED         *");
            $display("************************************");
            $display("");

        end


        #100;

        $finish;

    end

endmodule

 
