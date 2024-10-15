// Main Module for Two-pass Connected Component Labeling with Perimeter and Area Calculation
module two_pass_labeling #(
    parameter IMG_HDISP = 1280,      // Image width
    parameter IMG_VDISP = 720,       // Image height
    parameter MAX_LABELS = 1024,     // Maximum number of labels
    parameter ADDR_WIDTH = 8         // Address width for labels
) (
    input               clk,
    input               rst_n,
    // Input binary image signals
    input               per_frame_vsync,    // Frame sync
    input               per_frame_href,     // Line sync
    input       [7:0]   per_img_Y,          // Input pixel (0 or 255)

    // Output labeled image
    output              post_frame_vsync,
    output              post_frame_href,
    output      [31:0]  post_label          // Output label (0 for background)
);

    // Internal signal declarations
    wire                matrix_frame_vsync;
    wire                matrix_frame_href;
    wire        [7:0]   matrix_p11, matrix_p12, matrix_p13;
    wire        [7:0]   matrix_p21, matrix_p22, matrix_p23;
    wire        [7:0]   matrix_p31, matrix_p32, matrix_p33;

    // Instantiate 3x3 Matrix Generator Module
    VIP_Matrix_Generate_3X3_8Bit #(
        .IMG_HDISP(IMG_HDISP),
        .IMG_VDISP(IMG_VDISP)
    ) u_VIP_Matrix_Generate_3X3_8Bit (
        .clk                (clk),
        .rst_n              (rst_n),
        .per_frame_vsync    (per_frame_vsync),
        .per_frame_href     (per_frame_href),
        .per_img_Y          (per_img_Y),
        .matrix_frame_vsync (matrix_frame_vsync),
        .matrix_frame_href  (matrix_frame_href),
        .matrix_p11         (matrix_p11),
        .matrix_p12         (matrix_p12),
        .matrix_p13         (matrix_p13),
        .matrix_p21         (matrix_p21),
        .matrix_p22         (matrix_p22),
        .matrix_p23         (matrix_p23),
        .matrix_p31         (matrix_p31),
        .matrix_p32         (matrix_p32),
        .matrix_p33         (matrix_p33)
    );

    // Instantiate Union-Find Module
    wire [1:0]            union_find_op;
    wire [ADDR_WIDTH-1:0] label_a, label_b;
    wire                  find_en;
    wire [ADDR_WIDTH-1:0] find_label_in;
    wire [ADDR_WIDTH-1:0] find_label_out;
    wire                  invalidate_en;
    wire [ADDR_WIDTH-1:0] invalidate_label;
    wire                  valid_out;

    union_find #(
        .N(MAX_LABELS),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) u_union_find (
        .clk              (clk),
        .reset            (!rst_n),
        .op               (op), // UNION operation//这里有问题
        .node1            (label_a),
        .node2            (label_b),
        .result           (find_label_out),
        .done             (valid_out)
    );
    wire find_union_req;
    wire [ADDR_WIDTH*2 + 2 - 1:0]find_union_op;
    assign find_union_op = {union_find_op, label_a, label_b};
    find_union_fifo_512  u_find_union_fifo_512(
    .full_o ( full_o ),
    .empty_o ( empty_o ),
    .clk_i ( clk_i ),
    .wr_en_i ( find_en | union_en),
    .rd_en_i ( rd_en_i ),
    .wdata ( wdata ),
    .datacount_o ( datacount_o ),
    .rst_busy ( rst_busy ),
    .rdata ( rdata ),
    .a_rst_i ( a_rst_i )
    );
    // Instantiate Perimeter Calculation Module
    wire [3:0] perimeter_out;

    perimeter_calc u_perimeter_calc (
        .p11            (matrix_p11),
        .p12            (matrix_p12),
        .p13            (matrix_p13),
        .p21            (matrix_p21),
        .p22            (matrix_p22),
        .p23            (matrix_p23),
        .p31            (matrix_p31),
        .p32            (matrix_p32),
        .p33            (matrix_p33),
        .perimeter_out  (perimeter_out)
    );

    // Combinational logic for Labeling Process
    reg [ADDR_WIDTH-1:0]    current_label;
    reg [ADDR_WIDTH-1:0]    label_image      [0:IMG_HDISP-1];
    reg [ADDR_WIDTH-1:0]    parent_label     [0:IMG_HDISP-1];//暂存的父label
    reg [ADDR_WIDTH-1:0]    prev_label_image [0:IMG_HDISP-1];
    reg [13:0]              x;
    reg [ADDR_WIDTH-1:0]    label_count;
    reg [31:0]              area             [0:MAX_LABELS-1];// Area for each label
    reg [31:0]              perimeter        [0:MAX_LABELS-1];// Perimeter for each label
    reg                     valid            [0:MAX_LABELS-1];// Validity of each label

    wire [ADDR_WIDTH-1:0] left_label = (x == 0) ? 0 : label_image[x - 1];
    wire [ADDR_WIDTH-1:0] above_label = prev_label_image[x];
    wire [ADDR_WIDTH-1:0] next_label;
    wire [31:0] updated_area;
    wire [31:0] updated_perimeter;
    wire        new_valid;

    assign next_label = (left_label == 0 && above_label == 0) ? label_count + 1 :
                        (left_label != 0 && above_label == 0) ? left_label :
                        (left_label == 0 && above_label != 0) ? above_label :
                        (left_label < above_label) ? left_label : above_label;

    assign updated_area = area[next_label] + 1;
    assign updated_perimeter = perimeter[next_label] + perimeter_out;

    assign new_valid = (next_label == 1) ? 0 :
                       (updated_area > MAX_AREA || updated_area < MIN_AREA) ? 0 : 1;

    // Sequential logic for updating connected component features and label count
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            integer i;
            for (i = 0; i < MAX_LABELS; i = i + 1) begin
                area[i] <= 0;
                perimeter[i] <= 0;
                valid[i] <= 1;
            end
            label_count <= 1;
        end else if (matrix_frame_href && matrix_p22 == 8'd255) begin
            area[next_label] <= updated_area;
            perimeter[next_label] <= updated_perimeter;
            valid[next_label] <= new_valid;
            if (left_label == 0 && above_label == 0) begin
                label_count <= label_count + 1;
            end
        end
    end

    always @(*) begin
        if (matrix_p22 == 8'd255) begin // Only label foreground pixels
            label_image[x] = next_label;
        end else begin
            label_image[x] = 0; // Background pixels have no label
        end

        if (!per_frame_vsync) begin // Perform union operation at frame end
            if (left_label != above_label && left_label != 0 && above_label != 0) begin
                union_en = 1;
                label_a = left_label;
                label_b = above_label;
            end else begin
                union_en = 0;
            end
        end else begin
            union_en = 0;
        end
    end

    // Move to next pixel
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            x <= 0;
        end else if (~matrix_frame_href) begin
            if (x == IMG_HDISP - 1) begin
                x <= 0;
                // Update previous line labels
                integer i;
                for (i = 0; i < IMG_HDISP; i = i + 1) begin
                    prev_label_image[i] <= label_image[i];
                end
            end else begin
                x <= x + 1;
            end
        end else begin
            x <= 0;
        end
    end

    // Immediate update of labels during first pass
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            post_label <= 0;
            find_en <= 0;
        end else if (!per_frame_vsync) begin // Perform union at the end of each frame
            // Find and update current pixel's label immediately
            if (label_image[x] != 0) begin
                find_en <= 1;
                find_label_in <= label_image[x];
                post_label <= find_label_out;
                if (!valid_out) begin
                    post_label <= 0;
                end
            end else begin
                find_en <= 0;
                post_label <= 0;
            end
        end else begin
            post_label <= 0;
        end
    end
endmodule

// Line Counter Module
module line_counter (
    input               clk,
    input               rst_n,
    input               per_frame_href, // Line sync signal
    output reg [13:0]   line_count      // Line count output
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            line_count <= 0;
        end else if (!per_frame_href) begin
            if (line_count == IMG_VDISP - 1) begin
                line_count <= 0;
            end else begin
                line_count <= line_count + 1;
            end
        end
    end
endmodule

module perimeter_calc (
    input       [7:0]   p11, p12, p13,
    input       [7:0]   p21, p22, p23,
    input       [7:0]   p31, p32, p33,
    output reg  [3:0]   perimeter_out  // Perimeter increment, range 0-4
);
    always @(*) begin
        perimeter_out = 0;
        if (p12 != 8'd255) perimeter_out = perimeter_out + 1; // Left
        if (p32 != 8'd255) perimeter_out = perimeter_out + 1; // Right
        if (p21 != 8'd255) perimeter_out = perimeter_out + 1; // Top
        if (p23 != 8'd255) perimeter_out = perimeter_out + 1; // Bottom
    end
endmodule