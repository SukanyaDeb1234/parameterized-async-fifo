`timescale 1ns / 1ps

module async_fifo_check_tb;

    parameter DEPTH = 8;
    parameter DATA_WIDTH = 16;

    // =====================================================
    // SIGNALS
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
    // REFERENCE MEMORY
    // =====================================================

    reg [DATA_WIDTH-1:0] expected_mem [0:31];

    integer expected_wr_ptr;
    integer expected_rd_ptr;

    integer pass_count;
    integer error_count;


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
    // CLOCK GENERATION
    // =====================================================

    // Write clock = 60 ns period
    always #30 wr_clk = ~wr_clk;

    // Read clock = 50 ns period
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

        expected_wr_ptr = 0;
        expected_rd_ptr = 0;

        pass_count = 0;
        error_count = 0;

        #100;

        rd_rstn = 1;
        wr_rstn = 1;

        $display("");
        $display("========================================");
        $display("RESET CHECK");
        $display("========================================");

        #1;

        if (empty == 1'b1) begin
            $display("PASS: FIFO is EMPTY after reset");
            pass_count = pass_count + 1;
        end
        else begin
            $display("FAIL: FIFO is NOT EMPTY after reset");
            error_count = error_count + 1;
        end

        if (full == 1'b0) begin
            $display("PASS: FIFO is NOT FULL after reset");
            pass_count = pass_count + 1;
        end
        else begin
            $display("FAIL: FIFO is FULL after reset");
            error_count = error_count + 1;
        end

    end


    // =====================================================
    // WRITE TASK
    // =====================================================

    task write_data;

        input [DATA_WIDTH-1:0] value;

        begin

            @(negedge wr_clk);

            // Check overflow protection
            if (full == 1'b1) begin

                $display(
                    "[%0t] WRITE BLOCKED - FIFO FULL",
                    $time
                );

            end
            else begin

                data_in = value;
                wr_en = 1'b1;

                @(posedge wr_clk);

                #1;

                // Save expected value
                expected_mem[expected_wr_ptr] = value;
                expected_wr_ptr = expected_wr_ptr + 1;

                $display(
                    "[%0t] WRITE PASS: data=%0d",
                    $time,
                    value
                );

                pass_count = pass_count + 1;

                @(negedge wr_clk);

                wr_en = 1'b0;

            end

        end

    endtask


    // =====================================================
    // READ TASK
    // =====================================================

    task read_data;

        reg [DATA_WIDTH-1:0] expected_value;

        begin

            @(negedge rd_clk);

            // Check underflow protection
            if (empty == 1'b1) begin

                $display(
                    "[%0t] READ BLOCKED - FIFO EMPTY",
                    $time
                );

            end
            else begin

                rd_en = 1'b1;

                @(posedge rd_clk);

                #1;

                expected_value =
                    expected_mem[expected_rd_ptr];

                if (data_out === expected_value) begin

                    $display(
                        "[%0t] READ PASS: Expected=%0d Actual=%0d",
                        $time,
                        expected_value,
                        data_out
                    );

                    pass_count = pass_count + 1;

                end
                else begin

                    $display(
                        "[%0t] READ FAIL: Expected=%0d Actual=%0d",
                        $time,
                        expected_value,
                        data_out
                    );

                    error_count = error_count + 1;

                end

                expected_rd_ptr = expected_rd_ptr + 1;

                @(negedge rd_clk);

                rd_en = 1'b0;

            end

        end

    endtask


    // =====================================================
    // MAIN TEST
    // =====================================================

    initial begin

        wait(rd_rstn == 1);
        wait(wr_rstn == 1);

        #100;


        // =================================================
        // TEST 1: BASIC FIFO OPERATION
        // =================================================

        $display("");
        $display("========================================");
        $display("TEST 1: BASIC FIFO OPERATION");
        $display("========================================");

        write_data(16'd10);
        write_data(16'd20);
        write_data(16'd30);
        write_data(16'd40);
        write_data(16'd50);

        #300;

        read_data;
        read_data;
        read_data;
        read_data;
        read_data;

        #200;


        // =================================================
        // TEST 2: EMPTY CHECK
        // =================================================

        $display("");
        $display("========================================");
        $display("TEST 2: EMPTY FLAG");
        $display("========================================");

        if (empty == 1'b1) begin

            $display("PASS: FIFO is EMPTY");
            pass_count = pass_count + 1;

        end
        else begin

            $display("FAIL: FIFO is NOT EMPTY");
            error_count = error_count + 1;

        end


        // =================================================
        // TEST 3: FILL FIFO
        // =================================================

        $display("");
        $display("========================================");
        $display("TEST 3: FILL FIFO");
        $display("========================================");

        write_data(16'd100);
        write_data(16'd101);
        write_data(16'd102);
        write_data(16'd103);
        write_data(16'd104);
        write_data(16'd105);
        write_data(16'd106);
        write_data(16'd107);

        #200;


        // =================================================
        // TEST 4: FULL CHECK
        // =================================================

        $display("");
        $display("========================================");
        $display("TEST 4: FULL FLAG");
        $display("========================================");

        if (full == 1'b1) begin

            $display("PASS: FIFO is FULL");
            pass_count = pass_count + 1;

        end
        else begin

            $display("FAIL: FIFO is NOT FULL");
            error_count = error_count + 1;

        end


        // =================================================
        // TEST 5: OVERFLOW PROTECTION
        // =================================================

        $display("");
        $display("========================================");
        $display("TEST 5: OVERFLOW PROTECTION");
        $display("========================================");

        @(negedge wr_clk);

        if (full == 1'b1) begin

            $display(
                "PASS: Write correctly blocked while FULL"
            );

            pass_count = pass_count + 1;

        end
        else begin

            $display(
                "FAIL: FIFO should be FULL here"
            );

            error_count = error_count + 1;

        end


        // =================================================
        // TEST 6: READ ALL DATA
        // =================================================

        $display("");
        $display("========================================");
        $display("TEST 6: READ FIFO CONTENT");
        $display("========================================");

        #300;

        read_data;
        read_data;
        read_data;
        read_data;
        read_data;
        read_data;
        read_data;
        read_data;

        #200;


        // =================================================
        // TEST 7: UNDERFLOW PROTECTION
        // =================================================

        $display("");
        $display("========================================");
        $display("TEST 7: UNDERFLOW PROTECTION");
        $display("========================================");

        if (empty == 1'b1) begin

            $display(
                "PASS: FIFO correctly reports EMPTY"
            );

            pass_count = pass_count + 1;

        end
        else begin

            $display(
                "FAIL: FIFO should be EMPTY"
            );

            error_count = error_count + 1;

        end


        // =================================================
        // FINAL RESULT
        // =================================================

        $display("");
        $display("========================================");
        $display("ASYNC FIFO CHECK COMPLETE");
        $display("========================================");

        $display(
            "PASS COUNT  = %0d",
            pass_count
        );

        $display(
            "ERROR COUNT = %0d",
            error_count
        );


        if (error_count == 0) begin

            $display("");
            $display("************************************");
            $display("*    ASYNC FIFO TEST : PASSED      *");
            $display("************************************");
            $display("");

        end
        else begin

            $display("");
            $display("************************************");
            $display("*    ASYNC FIFO TEST : FAILED      *");
            $display("************************************");
            $display("");

        end


        #100;

        $finish;

    end

endmodule

    