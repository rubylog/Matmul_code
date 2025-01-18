`timescale 1ns/1ps

module TB_PE_array_top;

    // Parameter 설정
    parameter DATA_WIDTH = 16;
    parameter ARRAY_SIZE = 128;
    parameter ROW_SIZE = 16;
    localparam INPUT_WIDTH = DATA_WIDTH * ARRAY_SIZE;

    // 입력 및 출력 신호 선언
    reg [(DATA_WIDTH*ARRAY_SIZE)-1:0] A;
    reg [(DATA_WIDTH*ARRAY_SIZE)-1:0] B;
    wire [(DATA_WIDTH*ARRAY_SIZE)-1:0] Mul;

    // DUT (Device Under Test) 인스턴스화
    PE_array_top #(
        .DATA_WIDTH(DATA_WIDTH),
        .ARRAY_SIZE(ARRAY_SIZE),
        .ROW_SIZE(ROW_SIZE)
    ) uut (
        .A(A),
        .B(B),
        .Mul(Mul)
    );

    reg [DATA_WIDTH-1:0] input_mem_A [ARRAY_SIZE-1:0];
    reg [DATA_WIDTH-1:0] input_mem_B [ARRAY_SIZE-1:0];

    integer i;
    integer file; // 파일 핸들러

    initial begin
        A = 0;
        B = 0;
        #10
        // 파일에서 데이터 읽기
        $readmemb("C:\\Users\\conqu\\Desktop\\2025_winter\\0119\\Matmul_code\\python\\A_1x128_raw.txt", input_mem_A);
        $readmemb("C:\\Users\\conqu\\Desktop\\2025_winter\\0119\\Matmul_code\\python\\B_1x128_raw.txt", input_mem_B);

        // input_mem_A와 input_mem_B의 값을 A와 B로 변환하여 저장
        for (i = 0; i < ARRAY_SIZE; i = i + 1) begin
            A[((ARRAY_SIZE-i)*DATA_WIDTH - 1) -: DATA_WIDTH] = input_mem_A[i];
            B[((ARRAY_SIZE-i)*DATA_WIDTH - 1) -: DATA_WIDTH] = input_mem_B[i]; 
        end
    end

    integer k;

    initial begin
        #20
        $display("Simulation started.");

        // 결과 파일 열기
        file = $fopen("C:\\Users\\conqu\\Desktop\\2025_winter\\0119\\Matmul_code\\python\\tb_PE_Array_raw.txt", "w");
        if (file == 0) begin
            $display("Error: Could not open file.");
            $stop;
        end

        for (k = 0; k < ARRAY_SIZE; k = k + 1) begin
            $fwrite(file, "%b\n", Mul[((ARRAY_SIZE-k)*DATA_WIDTH - 1) -: DATA_WIDTH]); 
        end

        // 파일 닫기
        $fclose(file);

        $display("Simulation completed. Results saved to tb_PE_Array_raw.txt.");

        // 종료
        $stop;
    end

endmodule
