`timescale  1ns/1ns
module two_pass_tb();

localparam image_width  = 450;
localparam image_height = 280;
//----------------------------------------------------------------------
//  clk & rst_n
reg                             clk;
reg                             rst_n;

initial
begin
    clk = 1'b0;
    forever #5 clk = ~clk;
end

initial
begin
    rst_n = 1'b0;
    repeat(50) @(posedge clk);
    rst_n = 1'b1;
end

//----------------------------------------------------------------------
//  Image data prepred to be processed
reg                             per_img_vsync;
reg                             per_img_href;
reg                             per_img_bit;

//  Image data has been processed
wire                            post1_img_vsync;
wire                            post1_img_href;
wire                            post1_img_bit;

wire                            post2_img_vsync;
wire                            post2_img_href;
wire                            post2_img_bit;

//----------------------------------------------------------------------
//  task and function
task image_input;
    bit             [31:0]      row_cnt;
    bit             [31:0]      col_cnt;
    bit                         mem     [image_width*image_height-1:0];
    $readmemh("img_Bin1.dat",mem);
    
    for(row_cnt = 0;row_cnt < image_height;row_cnt++)
    begin
        repeat(5) @(posedge clk);
        per_img_vsync = 1'b1;
        repeat(5) @(posedge clk);
        for(col_cnt = 0;col_cnt < image_width;col_cnt++)
        begin
            per_img_href = 1'b1;
            per_img_bit  = mem[row_cnt*image_width+col_cnt];
            @(posedge clk);
        end
        per_img_href = 1'b0;
    end
    per_img_vsync = 1'b0;
    #200
    @(posedge clk);
    
endtask : image_input
task image_input_again;
    bit             [31:0]      row_cnt;
    bit             [31:0]      col_cnt;
    bit                         mem     [image_width*image_height-1:0];
    $readmemh("img_Bin1.dat",mem);
    
    for(row_cnt = 0;row_cnt < image_height;row_cnt++)
    begin
        repeat(5) @(posedge clk);
        per_img_vsync = 1'b1;
        repeat(5) @(posedge clk);
        for(col_cnt = 0;col_cnt < image_width;col_cnt++)
        begin
            per_img_href = 1'b1;
            per_img_bit  = mem[row_cnt*image_width+col_cnt];
            @(posedge clk);
        end
        per_img_href = 1'b0;
    end
    per_img_vsync = 1'b0;
    #200
    @(posedge clk);
    
endtask : image_input_again
reg                             post2_img_vsync_r;

always @(posedge clk)
begin
    if(rst_n == 1'b0)
        post2_img_vsync_r <= 1'b0;
    else
        post2_img_vsync_r <= post2_img_vsync;
end

wire                            post2_img_vsync_pos;
wire                            post2_img_vsync_neg;

assign post2_img_vsync_pos = ~post2_img_vsync_r &  post2_img_vsync;
assign post2_img_vsync_neg =  post2_img_vsync_r & ~post2_img_vsync;

task image_result_check;
    bit                         frame_flag;
    bit         [31:0]          row_cnt;
    bit         [31:0]          col_cnt;
    bit                         mem     [image_width*image_height-1:0];
    
    frame_flag = 0;
    $readmemh("img_Bin1.dat",mem);
    
    while(1)
    begin
        @(posedge clk);
        if(post2_img_vsync_pos == 1'b1)
        begin
            frame_flag = 1;
            row_cnt = 0;
            col_cnt = 0;
            $display("##############image result check begin##############");
        end
        
        if(frame_flag == 1'b1)
        begin
            if(post2_img_href == 1'b1)
            begin
                if(post2_img_bit != mem[row_cnt*image_width+col_cnt])
                begin
                    $display("result error ---> row_num : %0d;col_num : %0d;pixel data : %h;reference data : %h",row_cnt+1,col_cnt+1,post2_img_bit,mem[row_cnt*image_width+col_cnt]);
                end
                col_cnt = col_cnt + 1;
            end
            
            if(col_cnt == image_width)
            begin
                col_cnt = 0;
                row_cnt = row_cnt + 1;
            end
        end
        
        if(post2_img_vsync_neg == 1'b1)
        begin
            frame_flag = 0;
            $display("##############image result check end##############");
        end
    end
endtask : image_result_check

//----------------------------------------------------------------------

    parameter MAX_LABELS = 50;        // Maximum number of labels
    parameter MAX_AREA  = 2500;       // Maximum area for labels
    parameter MAX_PERIMETER_CALC = 1024; // Maximum perimeter for labels
    parameter ADDR_WIDTH = 8;         // Address width for labels
    parameter LABEL_INF_WIDTH = 32;   // Label information width

    // 信号定义

    // 输出信号
    wire post_frame_vsync;
    wire post_frame_href;
    wire [MAX_LABELS-1:0] merged_area;
    wire [MAX_LABELS-1:0] merged_perimeter;
    wire [MAX_LABELS-1:0] merged_valid;
    wire [MAX_LABELS-1:0] merged;
    wire [LABEL_INF_WIDTH-1:0] merged_pos;

    // 实例化 two_pass_labeling 模块
    two_pass_labeling #(
        .IMG_HDISP          (image_width),
        .IMG_VDISP          (image_height),
        .MAX_LABELS         (MAX_LABELS),
        .MAX_AREA           (MAX_AREA),
        .MAX_PERIMETER_CALC (MAX_PERIMETER_CALC),
        .ADDR_WIDTH         (ADDR_WIDTH),
        .LABEL_INF_WIDTH    (LABEL_INF_WIDTH)
    ) uut (
        .clk(clk),
        .rst_n(rst_n),
        .per_frame_vsync(per_img_vsync),
        .per_frame_href(per_img_href),
        .per_img_Y(per_img_bit?255:0),
        .post_frame_vsync(post_frame_vsync),
        .post_frame_href(post_frame_href)
    );


initial
begin
    per_img_vsync = 0;
    per_img_href  = 0;
    per_img_bit   = 0;
end

initial 
begin
    wait(rst_n);
    fork
        begin 
            repeat(5) @(posedge clk);
            image_input;
            
            repeat(200) @(posedge clk);
            image_input;
            repeat(200) @(posedge clk);
            image_input;
            repeat(200) @(posedge clk);
            image_input;
            repeat(200) @(posedge clk);
            image_input;
            repeat(200) @(posedge clk);
            image_input;
            repeat(200) @(posedge clk);
            image_input;
            repeat(200) @(posedge clk);
            image_input;
            repeat(200) @(posedge clk);
            image_input;
            repeat(200) @(posedge clk);
            image_input;
            repeat(200) @(posedge clk);
            image_input;
            repeat(200) @(posedge clk);
            image_input;
        end 
        image_result_check;
    join
end 

endmodule