
module state_machine_moore(clk, reset, in, out);
    parameter zero = 0, one1 = 1, two1s = 2;
    output reg out;
    input clk, reset, in;

    reg [1:0] state, next_state;

    // State register
    always @(posedge clk or posedge reset) begin
        if (reset)
            state <= zero;
        else
            state <= next_state;
    end

    // Next state logic 
    always @(*) begin
        case (state)
            zero:    next_state = in ? one1  : zero;
            one1:    next_state = in ? two1s : zero;
            two1s:   next_state = in ? two1s : zero;
            default: next_state = zero;
        endcase
    end

    // Output logic (Moore: only state-based)
    always @(*) begin
        case (state)
            zero:    out = 0;
            one1:    out = 0;
            two1s:   out = 1;
            default: out = 0;
        endcase
    end

endmodule



// Testbench ------------
module state_machine_moore_tb();
    reg clk, reset, in;
    wire out;
    integer i;

    // Internal signals for GTKWave
    wire [1:0] state_val, next_state_val;

    // Instantiate FSM
    state_machine_moore dut(clk, reset, in, out);
    assign state_val = dut.state;
    assign next_state_val = dut.next_state;

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;

    // Simulation logic
    initial begin
        $dumpfile("moore.vcd");
        $dumpvars(0, state_machine_moore_tb);

        reset = 1;
        in = 0;
        #6;
        reset = 0;

        for (i = 0; i < 15; i = i + 1) begin
            @(negedge clk); #1;
            in = $random % 2;
            $display("T=%0t | in=%b | out=%b | state=%0d | next_state=%0d", 
                     $time, in, out, state_val, next_state_val);
            if (out == 1)
                $display(">>> PASS: Moore FSM detected sequence '11' at time %0t", $time);
        end

        #20;
        $finish;
    end
endmodule
