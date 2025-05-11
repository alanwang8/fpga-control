
module tb_max_sum_index;

    parameter DATA_WIDTH = 8;
    parameter ROWS = 8;
    parameter COLS = 8;

    // Inputs
    logic clk;
    logic rst_n;
    logic valid_in;
    logic [DATA_WIDTH-1:0] array_in [0:ROWS-1][0:COLS-1];

    // Outputs
    logic [DATA_WIDTH+1:0] max;
    logic [$clog2(ROWS)-1:0] max_index_row;
    logic [$clog2(COLS)-1:0] max_index_col;
    logic valid_out;

    // Instantiate the module
    max_sum_index #(
        .DATA_WIDTH(DATA_WIDTH),
        .ROWS(ROWS),
        .COLS(COLS)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .valid_in(valid_in),
        .array_in(array_in),
        .max(max),
        .max_index_row(max_index_row),
        .max_index_col(max_index_col),
        .valid_out(valid_out)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Task to print results
    task print_result;
        $display("Time: %0t | Max: %0d at (%0d, %0d)", $time, max, max_index_row, max_index_col);
    endtask

    // Test logic
    initial begin
        integer i, j;
        clk = 0;
        rst_n = 0;
        valid_in = 0;

        // Reset
        #10;
        rst_n = 1;

        // Initialize array with predictable values
        for (i = 0; i < ROWS; i = i + 1) begin
            for (j = 0; j < COLS; j = j + 1) begin
                array_in[i][j] = i * COLS + j;
            end
        end

        // Overwrite one value to make it the max
        array_in[1][1] = 8'd255;

        // Apply input
        #10;
        valid_in = 1;
        #10;
        valid_in = 0;

        // Wait for output to be valid
        wait (valid_out);
        print_result();

        // Check result
        if (max == 255 && max_index_row == 1 && max_index_col == 1)
            $display("TEST PASSED");
        else begin
            $display("TEST FAILED");
            $stop;
        end

        $finish;
    end

endmodule
