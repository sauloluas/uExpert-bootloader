module tb_bootloader #(
  parameter int unsigned TCM_BYTES = 64 * 1024,
  parameter int unsigned BAUD_DIV  = 434
);
  timeunit 1ns;
  timeprecision 1ps;

  localparam int unsigned TOHOST_WORD = (TCM_BYTES - 4) / 4;

  logic clk;
  logic rst;
  logic uart_rx;   // TB drives (serial into DUT)
  logic uart_tx;   // DUT drives (serial out of DUT)

  always #5 clk = ~clk;

  // Full SoC: core + TCM + demux + UART + mtimer + gpio.
  // RESET_VECTOR=0 so the core begins at the bootloader's _start in TCM.
  soc_tcm_top #(
    .RESET_VECTOR (32'h0000_0000),
    .TCM_BYTES    (TCM_BYTES)
  ) dut (
    .clk_i      (clk),
    .rst_i      (rst),
    .uart_rx_i  (uart_rx),
    .uart_tx_o  (uart_tx)
    // Add remaining ports as required by soc_tcm_top's actual port list.
  );

  // -------------------------------------------------------------------------
  // Load images
  // -------------------------------------------------------------------------
  logic [31:0] app_words [0:1023];
  int unsigned num_words;

initial begin
  string bootloader_mem;
  string app_code_mem;

  if (!$value$plusargs("BOOTLOADER_MEM=%s", bootloader_mem))
    $fatal(1, "missing +BOOTLOADER_MEM=<path>");
  if (!$value$plusargs("APP_CODE_MEM=%s", app_code_mem))
    $fatal(1, "missing +APP_CODE_MEM=<path>");

  $display("tb_bootloader: bootloader=%s", bootloader_mem);
  $display("tb_bootloader: app=%s", app_code_mem);

  for (int i = 0; i < TCM_BYTES/4; i++) dut.u_tcm.mem[i] = 32'b0;
  $readmemh(bootloader_mem, dut.u_tcm.mem);

  for (int i = 0; i < 1024; i++) app_words[i] = 32'hxxxx_xxxx;
  $readmemh(app_code_mem, app_words);

  num_words = 0;
  for (int i = 0; i < 1024; i++)
    if (app_words[i] !== 32'hxxxx_xxxx) num_words = i + 1;
  if (num_words == 0) $fatal(1, "empty app image");
  $display("tb_bootloader: app code = %0d words", num_words);
end

  // -------------------------------------------------------------------------
  // UART bit-banging (8N1, LSB first)
  // -------------------------------------------------------------------------
  task automatic uart_send_byte(input logic [7:0] b);
    uart_rx = 1'b0;                          // start
    repeat (BAUD_DIV) @(posedge clk);
    for (int i = 0; i < 8; i++) begin        // 8 data bits
      uart_rx = b[i];
      repeat (BAUD_DIV) @(posedge clk);
    end
    uart_rx = 1'b1;                          // stop
    repeat (BAUD_DIV) @(posedge clk);
  endtask

  task automatic uart_send_word(input logic [31:0] w);
    uart_send_byte(w[7:0]);
    uart_send_byte(w[15:8]);
    uart_send_byte(w[23:16]);
    uart_send_byte(w[31:24]);
  endtask

  // -------------------------------------------------------------------------
  // Driver: reset, wait for bootloader to reach the polling loop, then send
  // the protocol: [data_words=0][code_words][code words...]
  // -------------------------------------------------------------------------
  initial begin
    clk     = 1'b0;
    rst     = 1'b1;
    uart_rx = 1'b1;   // idle high

    repeat (4) @(posedge clk);
    rst = 1'b0;
    repeat (500) @(posedge clk);   // let crt0 + bootloader reach while(1)

    $display("tb_bootloader: sending protocol (data=0, code=%0d words)", num_words);
    uart_send_word(32'd0);            // data_words = 0
    uart_send_word(32'(num_words));   // code_words
    for (int i = 0; i < num_words; i++) uart_send_word(app_words[i]);

    // Allow the last word to commit + the jump + the app to run.
    repeat (1000) @(posedge clk);
    $fatal(1, "timeout: app never wrote PASS to tohost");
  end

  // -------------------------------------------------------------------------
  // Monitor tohost
  // -------------------------------------------------------------------------
  always @(posedge clk) begin
    if (!rst) begin
      logic [31:0] th;
      th = dut.u_tcm.mem[TOHOST_WORD];
      if (th == 32'h0000_0001) begin
        $display("tb_bootloader: PASS (app signaled tohost after %0d cycles)", $time/10);
        $finish;
      end
      if (th !== 32'h0 && th !== 32'hxxxx_xxxx) begin
        $fatal(1, "FAIL: tohost = %08x (code = %0d)", th, th >> 1);
      end
    end
  end
endmodule
