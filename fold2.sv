module max_sum_index #(
    parameter DATA_WIDTH = 8,
    parameter ROWS = 8,
    parameter COLS = 8
)(
    input  logic                        clk,
    input  logic                        rst_n,
    input  logic                        valid_in,
    input  logic [DATA_WIDTH-1:0]       array_in [ROWS-1:0][COLS-1:0],
    output logic                        valid_out,
    output logic [DATA_WIDTH+1:0]       max,
    output logic [$clog2(ROWS)-1:0]     max_index_row,
    output logic [$clog2(COLS)-1:0]     max_index_col
);

    // Pipeline Stage Registers
    logic [DATA_WIDTH+1:0] stage_max;
    logic [$clog2(ROWS)-1:0] stage_row;
    logic [$clog2(COLS)-1:0] stage_col;

    logic [$clog2(ROWS)-1:0] i;
    logic [$clog2(COLS)-1:0] j;

    typedef enum logic [1:0] {
        IDLE,
        SCAN,
        DONE
    } state_t;

    state_t state, next_state;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            i <= 0;
            j <= 0;
            stage_max <= 0;
            stage_row <= 0;
            stage_col <= 0;
            valid_out <= 0;
        end else begin
            state <= next_state;
            case (state)
                IDLE: begin
                    if (valid_in) begin
                        i <= 0;
                        j <= 0;
                        stage_max <= 0;
                        stage_row <= 0;
                        stage_col <= 0;
                    end
                    valid_out <= 0;
                end
                SCAN: begin
                    if (array_in[i][j] > stage_max) begin
                        stage_max <= array_in[i][j];
                        stage_row <= i;
                        stage_col <= j;
                    end
                    if (j == COLS-1) begin
                        j <= 0;
                        i <= i + 1;
                    end else begin
                        j <= j + 1;
                    end
                end
                DONE: begin
                    valid_out <= 1;
                end
            endcase
        end
    end

    always_comb begin
        next_state = state;
        case (state)
            IDLE: if (valid_in) next_state = SCAN;
            SCAN: if (i == ROWS-1 && j == COLS-1) next_state = DONE;
            DONE: next_state = IDLE;
        endcase
    end

    // Output assignments
    assign max = stage_max;
    assign max_index_row = stage_row;
    assign max_index_col = stage_col;

endmodule