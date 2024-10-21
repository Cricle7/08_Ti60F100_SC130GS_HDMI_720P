`timescale 1ns/1ps

module union_find_tb;

    // Parameters
    parameter N = 256;
    parameter ADDR_WIDTH = 8;

    // Inputs to the DUT (Device Under Test)
    reg clk;
    reg reset;
    reg frame_start;
    reg [1:0] op;  // Operation code: 00 - idle, 01 - union, 10 - find
    reg [ADDR_WIDTH-1:0] node1;
    reg [ADDR_WIDTH-1:0] node2;

    // Outputs from the DUT
    wire [ADDR_WIDTH-1:0] result;
    wire done;
    wire idle;

    // Instantiate the DUT (Device Under Test)
    union_find #(
        .N(N),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) dut (
        .clk(clk),
        .reset(reset),
        .frame_start(frame_start),
        .op(op),
        .node1(node1),
        .node2(node2),
        .result(result),
        .done(done),
        .idle(idle)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;  // Generate a 100MHz clock

    // Test sequence
    initial begin
        // Initialize inputs
        reset = 1;
        frame_start = 0;
        op = 2'b00;
        node1 = 0;
        node2 = 0;

        // Wait for reset
        #20;
        reset = 0;

        // Wait for the DUT to initialize
        #20;

        // Start of a new frame
        frame_start = 1;
        #10;
        frame_start = 0;

        // Wait for the DUT to complete initialization
        wait_for_idle();

        // Test sequence
        // Union(1, 2)
        start_operation(2'b01, 8'd1, 8'd2);
        wait_for_done();

        // Union(3, 4)
        start_operation(2'b01, 8'd3, 8'd4);
        wait_for_done();

        // Find(1)
        start_operation(2'b10, 8'd1, 8'd0);
        wait_for_done();
        $display("Find(1): Root = %d", result);

        // Find(2)
        start_operation(2'b10, 8'd2, 8'd0);
        wait_for_done();
        $display("Find(2): Root = %d", result);

        // Find(3)
        start_operation(2'b10, 8'd3, 8'd0);
        wait_for_done();
        $display("Find(3): Root = %d", result);

        // Find(4)
        start_operation(2'b10, 8'd4, 8'd0);
        wait_for_done();
        $display("Find(4): Root = %d", result);

        // Union(1, 3) to connect both sets
        start_operation(2'b01, 8'd1, 8'd3);
        wait_for_done();

        // Find(1) after union with 3
        start_operation(2'b10, 8'd1, 8'd0);
        wait_for_done();
        $display("Find(1): Root after union with 3 = %d", result);

        // Find(4) should also yield the same root
        start_operation(2'b10, 8'd4, 8'd0);
        wait_for_done();
        $display("Find(4): Root after union = %d", result);

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
        @(posedge clk);
        op <= 2'b00; // Return to idle after issuing the operation
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

    // Task to wait until the module is idle
    task wait_for_idle;
    begin
        @(posedge clk);
        while (!idle) begin
            @(posedge clk);
        end
    end
    endtask

endmodule
