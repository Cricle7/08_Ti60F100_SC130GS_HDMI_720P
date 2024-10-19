`timescale 1ns/1ps

module union_find_tb;

    // Parameters
    parameter N = 8;
    parameter ADDR_WIDTH = 3;

    // Inputs to the DUT
    reg clk;
    reg reset;
    reg start;
    reg [1:0] op;  // Operation code: 00 - find, 01 - union
    reg [ADDR_WIDTH-1:0] node1;
    reg [ADDR_WIDTH-1:0] node2;

    // Outputs from the DUT
    wire [ADDR_WIDTH-1:0] result;
    wire done;

    // Instantiate the DUT (Device Under Test)
    union_find #(
        .N(N),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) dut (
        .clk(clk),
        .reset(reset),
        .op(op),
        .node1(node1),
        .node2(node2),
        .result(result),
        .done(done)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;  // 100MHz clock

    // Test sequence
    initial begin
        // Initialize inputs
        reset = 1;
        start = 0;
        op = 0;
        node1 = 0;
        node2 = 0;

        // Wait for reset
        #20;
        reset = 0;

        // Wait for the DUT to initialize
        #20;

        // Test sequence
        // Union(1, 2)
        start_operation(2'b01, 1, 2);
        wait_for_done();

        // Union(3, 4)
        start_operation(2'b01, 3, 4);
        wait_for_done();

        // Now we have two separate sets: {1,2} and {3,4}

        // Find(1) and Find(2)
        start_operation(2'b10, 1, 0);
        wait_for_done();
        $display("Find(1): Root = %d", result);

        start_operation(2'b10, 2, 0);
        wait_for_done();
        $display("Find(2): Root = %d", result);

        // Find(3) and Find(4)
        start_operation(2'b10, 3, 0);
        wait_for_done();
        $display("Find(3): Root = %d", result);

        start_operation(2'b10, 4, 0);
        wait_for_done();
        $display("Find(4): Root = %d", result);

        // Ensure that roots of (1,2) are the same and roots of (3,4) are the same but different from (1,2)

        // Union(5, 6)
        start_operation(2'b01, 5, 6);
        wait_for_done();

        // Union(5, 1)
        start_operation(2'b01, 5, 1);
        wait_for_done();

        // Now nodes 1,2,5,6 are in one set, and nodes 3,4 are in another set

        // Find(5) and Find(6)
        start_operation(2'b10, 5, 0);
        wait_for_done();
        $display("Find(5): Root = %d", result);

        start_operation(2'b10, 6, 0);
        wait_for_done();
        $display("Find(6): Root = %d", result);

        // Find(3) and Find(4) again to confirm they are still in a separate set
        start_operation(2'b10, 3, 0);
        wait_for_done();
        $display("Find(3): Root = %d", result);

        start_operation(2'b10, 4, 0);
        wait_for_done();
        $display("Find(4): Root = %d", result);

        // Finish simulation
        #20;
        $finish;
    end

    // Task to start an operation
    task start_operation(input [1:0] op_code, input [ADDR_WIDTH-1:0] n1, input [ADDR_WIDTH-1:0] n2);
    begin
        @(posedge clk);
        op <= op_code;
        node1 <= n1;
        node2 <= n2;
        start <= 1;
        @(posedge clk);
        start <= 0;
    end
    endtask

    // Task to wait until the operation is done
    task wait_for_done;
    begin
        @(posedge clk);
        while (!done) begin
            @(posedge clk);
        end
    end
    endtask

endmodule
