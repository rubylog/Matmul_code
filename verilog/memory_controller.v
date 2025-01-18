module memory_controller(
    input clk,
    input rst_n,
    input start,

    output we_A, we_B, we_out,
    output en_A, en_B, en_out,
    output [5:0] addr_a, addr_b,
    output reg [11:0] addr_out,
    output done
);

localparam IDLE = 2'b00, 
           A_LOAD = 2'b01,
           A_STOP = 2'b10,
           DONE = 2'b11;

reg [1:0] state, next_state;
reg [3:0] counter_a_stop;
reg [3:0] counter_done;
reg [6:0] addr_a_reg, addr_b_reg;

assign addr_a = addr_a_reg[5:0];
assign addr_b = addr_b_reg[5:0];

 always @(*) begin
    case(state)
        IDLE : begin
            if(start && !done) next_state = A_LOAD;
            else next_state = IDLE;
        end
        A_LOAD : begin
            next_state = A_STOP; // 1 clk 동안 A와 B 각각의의 첫번때 데이터 읽어오고 A_STOP으로 넘어가면서 연산 시작
        end
        A_STOP : begin
            if(addr_a_reg == 7'd64 && addr_b_reg == 7'd63) next_state = DONE; // a 63을 받고 addra가 64로 증가, addrb 63에선 state 전환동안 63 읽음
            // A의 마지막 행, B의 마지막 열인 경우, 데이터를 입력 받고서 다음 clk에 DONE으로 이동
            else if(addr_a_reg != 7'd64 && addr_b_reg == 7'd63) next_state = A_LOAD;
            // A가 아직 마지막이 아닌 경우 B가 마지막 열에 도달하면 데이터를 입력 받고서(상태 전환 clk) 다시 A를 로드하러 감감
            else next_state = A_STOP;
            // 그 외의 경우 연산 유지
        end
        DONE : begin
            if(counter_done == 4'd8) next_state = IDLE; 
            // astop에서 마지막으로 읽은 데이터가 버퍼에 도달 할 때까지 기다려준다. 마지막 데이터는 A_STOP의 마지막 
            // clk에서 읽고 DONE에서 8 clk 동안 연산됨 추가로 쓰는데 1clk(done -> idle 상태 전환동안 완료료) 더걸림
            // IDLE에선 모든 신호 꺼주기, dout <= mem reg 같은 값으로 갱신해도 전력소모가 되는지?
            else next_state = DONE; 
        end
        default : next_state = next_state;
    endcase
end

always @(posedge clk, negedge rst_n) begin
    if(!rst_n) state <= IDLE;
    else state <= next_state;
end


//////////////// enable signals ////////////////

assign en_A = (state == A_LOAD) ? 1'b1 : 1'b0; // A_lOAD에서만 A를 읽어옴, 이후 astop에서 신호를 꺼도 input mem의 dout 레지스터에 저장되어 있음
assign en_B = (state == A_LOAD || state == A_STOP) ? 1'b1 : 1'b0; // B는 앞의 두가지 상태에서 항상 읽어야 함
assign we_A = 1'b0; // 쓰기 동작 없음
assign we_B = 1'b0; // 쓰기 동작 없음

assign en_out = (state == A_LOAD || state == A_STOP || state == DONE) ? ((counter_a_stop == 4'd8) ? 1'b1 : 1'b0) : 1'b0;
// A의 두번째 행 부터는 A_LOAD 상태에서도 연산과 결과 저장이 계속해서 이루어짐, 뒤의 조건은 초기 A_STOP에서의 8 clk 기다려주기
assign we_out = (state == A_LOAD || state == A_STOP || state == DONE) ? ((counter_a_stop == 4'd8) ? 1'b1 : 1'b0) : 1'b0;
// 마찬가지지
assign done = (counter_done == 4'd9) ? 1'b1 : 1'b0;
// done 상태 진입후 마지막 데이터가 저장되는 1clk 까지 포함함, 다시 돌아온 IDLE에서도 유지

//////////////// address change ////////////////

always @(posedge clk, negedge rst_n) begin
    if(!rst_n) addr_a_reg <= 7'd0; // for IDLE
    else if(state == A_LOAD) addr_a_reg <= addr_a_reg + 7'd1; // A_LOAD가 끝날때 1씩 증가, max64
    else addr_a_reg <= addr_a_reg; // for A_STOP, DONE, 주소는 따로 초기화 안함
end

always @(posedge clk, negedge rst_n) begin
    if(!rst_n) addr_b_reg <= 7'd0; // for IDLE
    else if(state == A_LOAD) addr_b_reg <= addr_b_reg + 7'd1; // addr_b_reg = 0
    else if(state == A_STOP) begin
        if(addr_a_reg != 7'd64 && addr_b_reg == 7'd63) addr_b_reg <= 7'd0; // A_LOAD로 돌아가기전, max63
        else if(addr_a_reg == 7'd64 && addr_b_reg == 7'd63) addr_b_reg <= addr_b_reg; // DONE으로 가기전
        else addr_b_reg <= addr_b_reg + 7'd1;
    end
    else addr_b_reg <= addr_b_reg; // for DONE
end

always @(posedge clk, negedge rst_n) begin
    if(!rst_n) addr_out <= 12'd0;
    else if(state == A_STOP || state == A_LOAD || state == DONE) begin
        if(counter_a_stop == 4'd8 && addr_out != 12'd4095) addr_out <= addr_out + 12'd1; 
        // wait first 8 clks, max 4095, DONE -> IDLE 갈때 증가안함
        else addr_out <= addr_out; // before first 8 clks
    end
    else addr_out <= addr_out; // for DONE
end

//////////////// required counters ////////////////

always @(posedge clk, negedge rst_n) begin
    if(!rst_n) counter_a_stop <= 4'd0; // IDLE
    else if(state == A_STOP && counter_a_stop != 4'd8) counter_a_stop <= counter_a_stop + 4'd1; // activate only at first A_STOP
    else counter_a_stop <= counter_a_stop; // remain as 8
end

always @(posedge clk, negedge rst_n) begin
    if(!rst_n) counter_done <= 4'd0;
    else if(state == DONE && counter_done != 4'd9) counter_done <= counter_done + 4'd1;
    else counter_done <= counter_done;
end

endmodule