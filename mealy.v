
module state_machine_mealy(clk, reset, in, out);
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
    zero: begin
      if (in) begin
        next_state = one1;
        out = 0;
      end else begin
        next_state = zero;
        out = 0;
      end
    end
    one1: begin
      if (in) begin
        next_state = two1s;
        out = 0;
      end else begin
        next_state = zero;
        out = 0;
      end
    end
    two1s: begin
      if (in) begin
        next_state = two1s;
        out = 1;
      end else begin
        next_state = zero;
        out = 1;
      end
    end
    default: begin
      next_state = zero;
      out = 0;
    end
  endcase
end



    // For GTKWave visibility
    // Declare state names as strings for debugging
    function [79:0] state_name;
        input [1:0] s;
        case (s)
            zero:   state_name = "zero";
            one1:   state_name = "one1";
            two1s:  state_name = "two1s";
            default:state_name = "UNKNOWN";
        endcase
    endfunction

endmodule



// Testbench
module state_machine_mealy_tb();
    reg clk, reset, in;
    wire out;
    integer i;

    // Internal visibility
    wire [1:0] state_val;
    wire [1:0] next_state_val;

    // Instantiate FSM
    state_machine_mealy dut(clk, reset, in, out);

    // Hook up internal state for GTKWave 
    assign state_val = dut.state;
    assign next_state_val = dut.next_state;

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;

    // Simulation and stimulus
    initial begin
        $dumpfile("mealy.vcd");
        $dumpvars(0, state_machine_mealy_tb);

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
                $display(">>> PASS: Sequence '11' detected at time %0t", $time);
        end

        #20;
        $finish;
    end
endmodule
