
module cpu
  #(
      parameter CPU_NAME   = "Global\\cpu_8",
                ADDR_WIDTH = 256,
                DATA_WIDTH = 256,
                TRN_WAIT   = 64'h10,
                WR_WAIT    = 64'h1,
                RD_WAIT    = 64'h1
  )
(
  input  wire iclk,
  input  wire irst,
  output reg  [ADDR_WIDTH - 1: 0] oaddr,
  output reg  [DATA_WIDTH - 1: 0] odata,
  output wire owr,

  input  wire [DATA_WIDTH - 1: 0] idata,
  output wire ord
);

reg  wr,rd;
wire rd_end;
reg  [63: 0] wait_cnt, end_cnt;

assign owr = wr;
assign ord = rd;

wire trn_end   = ((end_cnt  == WR_WAIT)&wr) | ((end_cnt  == RD_WAIT)&rd) ? 1'h1 : 1'h0;
wire trn_start = (wait_cnt == TRN_WAIT) ? 1'h1 : 1'h0;

always @(posedge iclk)
  if (~irst)
    if (trn_start | trn_end)
      $cpu_reg (oaddr, odata, wr, rd, trn_start,trn_end, idata, CPU_NAME);

always @(posedge iclk)
  if (irst)
    wait_cnt <= 64'h0;
  else
    if (wr | rd)
      wait_cnt <= 64'h0;
    else
      if (wait_cnt < TRN_WAIT)
        wait_cnt <= wait_cnt + 1;

always @(posedge iclk)
  if (irst)
    end_cnt <= 0;
  else
    if (rd | wr)
      end_cnt <= end_cnt + 1;
    else
      end_cnt <= 0;

endmodule