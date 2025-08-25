`timescale 1ns / 1ps
// =============================================================================
// File: tb_ip_TIMER.sv 77.11
// Description: This testbench verifies the functionality of the ip_TIMER module
//              by simulating an APB bus interface and executing a series of
//              read/write test cases for its registers.
// =============================================================================

// Include necessary files
`include "reg_def.sv"    
`include "VIP/cnt_sys_signal.sv"
`include "VIP/APB_trans_bus.sv"   

`define repeat_count 20

// Testbench: tb_ip_TIMER
module tb_ip_TIMER;
  integer err_cnt;  // Global error count

  // Parameters
  parameter ADDR_WIDTH  = 8;    // Defines the width of the APB address bus

  // DUT input signals
  reg                    PCLK;    // APB clock signal
  reg                    PRESETn; // APB active-low reset signal
  wire [3:0]             CLK_IN;  // 4 different clock sources for the timer
  wire                   PSEL, PENABLE, PWRITE; // APB control signals
  wire [ADDR_WIDTH-1:0]  PADDR;   // APB address bus
  wire [`DATA_WIDTH-1:0] PWDATA;  // APB write data bus

  // DUT output signals
  wire [`DATA_WIDTH-1:0] PRDATA;  // APB read data bus
  wire                   PREADY;  // APB ready signal from the slave
  wire                   PSLVERR; // APB slave error signal
  wire                   TMR_OVF; // Timer overflow output
  wire                   TMR_UDF; // Timer underflow output

  // Local variables for stimulus and checking register
  reg [`DATA_WIDTH-1:0] w_rand_data;
  reg [`DATA_WIDTH-1:0] data_write;
  reg [`DATA_WIDTH-1:0] data_read;
  reg [`DATA_WIDTH-1:0] cnt_before_write;
  reg [`DATA_WIDTH-1:0] cnt_after_write;
  reg [ADDR_WIDTH-1:0]  null_addr;
  reg [ADDR_WIDTH-1:0]  mixed_addr;

  // ---------------------------------------------------------------------------
  // Instantiate counter system signal (Clock + Reset + CLK_IN[4 sources] Generation)
  // ---------------------------------------------------------------------------
  cnt_sys_signal #(
    .sys_clk_period (10)
  ) u_cnt_sys_signal (
    .sys_clk_w   (PCLK),
    .sys_rst_n_w (PRESETn),
    .clk_in_w    (CLK_IN)
  );

  // ---------------------------------------------------------------------------
  // Instantiate APB transaction bus driver
  // ---------------------------------------------------------------------------
  APB_trans_bus #(
    .ADDR_WIDTH(ADDR_WIDTH)
  ) u_APB_trans_bus (
    .PCLK    (PCLK),
    .PRESETn (PRESETn),
    .PSEL    (PSEL),
    .PENABLE (PENABLE),
    .PWRITE  (PWRITE),
    .PADDR   (PADDR),
    .PWDATA  (PWDATA),
    .PRDATA  (PRDATA),
    .PREADY  (PREADY),
    .PSLVERR (PSLVERR)
  );

  // ---------------------------------------------------------------------------
  // Instantiate DUT (ip_TIMER) 
  // ---------------------------------------------------------------------------
  ip_TIMER #(
    .ADDR_WIDTH(ADDR_WIDTH)
  ) u_ip_timer (
    .CLK_IN  (CLK_IN),
    .PCLK    (PCLK),
    .PRESETn (PRESETn),
    .PSEL    (PSEL),
    .PENABLE (PENABLE),
    .PWRITE  (PWRITE),
    .PADDR   (PADDR),
    .PWDATA  (PWDATA),
    .PRDATA  (PRDATA),
    .PREADY  (PREADY),
    .PSLVERR (PSLVERR),
    .TMR_OVF (TMR_OVF),
    .TMR_UDF (TMR_UDF)
  );

  // -----------------------------------------------------------------------------------------------------------
  // ------------------------------ [TMR_TESTCASE_01] - [Register] Tests ---------------------------------------

  // ========================================================================
  // Test Case 1.1: TDR (Timer Data Register) Read/Write
  // Objective: Verify that the TDR can be written to and read back correctly.
  // ========================================================================
  task automatic tc_tdr_rw;
    begin
      $display("\n[--- TC1: TDR read/write ---]");
      // 1. Read the default value of TDR and verify it matches the reset value
      u_APB_trans_bus.apb_read(`TDR_ADDR, data_read);
      if (data_read == `TDR_RST)
        $display("TC1.1-1 PASS: Default TDR value = 0x%h", data_read);
      else
        $display("TC1.1-1 FAIL: Default TDR value incorrect, expected 0x%h but got 0x%h", `TDR_RST, data_read);

      // 2. Perform two write/readback cycles with random data
      repeat (`repeat_count) begin
        w_rand_data = $urandom_range(255, 0);
        u_APB_trans_bus.apb_write(`TDR_ADDR, w_rand_data);
        u_APB_trans_bus.apb_read(`TDR_ADDR, data_read);
        if (data_read == w_rand_data)
          $display("TC1.1-2 PASS: Wrote and read 0x%h correctly", w_rand_data);
        else
          $display("TC1.1-2 FAIL: Mismatch readback from TDR, expected 0x%h, got 0x%h", w_rand_data, data_read);
      end
    end
  endtask

  // =======================================================================
  // Test Case 1.2: TCR (Timer Control Register) Read/Write with Mask
  // Objective: Verify that only the writable bits of the TCR can be changed.
  // =======================================================================
  task automatic tc_tcr_rw;
    begin
      $display("\n[--- TC2: TCR read/write mask ---]");
      // 1. Read the default value of TCR and verify it matches the reset value
      u_APB_trans_bus.apb_read(`TCR_ADDR, data_read);
      if (data_read == `TCR_RST)
        $display("TC1.2-1 PASS: Default TCR value = 0x%h", data_read);
      else
        $display("TC1.2-1 FAIL: Default TCR value incorrect, expected 0x%h but got 0x%h", `TCR_RST, data_read);

      // 2. Perform two write/readback cycles with a random value and verify the mask
      repeat (`repeat_count) begin
        w_rand_data = $urandom_range(255, 0);
        u_APB_trans_bus.apb_write(`TCR_ADDR, w_rand_data);
        u_APB_trans_bus.apb_read(`TCR_ADDR, data_read);
        if (data_read == (w_rand_data & `TCR_WRITE_MASK))
          $display("TC1.2-2 PASS: Wrote 0x%h, read back masked value 0x%h as expected.", w_rand_data, data_read);
        else
          $display("TC1.2-2 FAIL: Readback value mismatch for TCR. Expected 0x%h, got 0x%h.", (w_rand_data & `TCR_WRITE_MASK), data_read);
      end
    end
  endtask

  // =======================================================================
  // Test Case 1.3: TSR (Timer Status Register) Read/Write
  // Objective: Verify that only the writable bits of the TSR can be changed.
  // =======================================================================
  task automatic tc_tsr_rw;
    begin
      $display("\n[--- TC3: TSR read/write ---]");
      // 1. Read the default value of TSR and verify it matches the reset value
      u_APB_trans_bus.apb_read(`TSR_ADDR, data_read);
      if (data_read == `TSR_RST) 
        $display("TC1.3-1 PASS: Default TSR value = 0x%h", data_read);
      else                       
        $display("TC1.3-1 FAIL: Default TSR value incorrect, expected 0x%h but got 0x%h", `TSR_RST, data_read);

      // 2. Perform two write/readback cycles with a random value and verify the mask
      repeat (`repeat_count) begin
        w_rand_data = $urandom_range(255, 0);
        u_APB_trans_bus.apb_write(`TSR_ADDR, w_rand_data);
        u_APB_trans_bus.apb_read(`TSR_ADDR, data_read);
        if (data_read == 8'h00)  
          $display("TC1.3-2 PASS: TSR ignores SW write (readback = 0)");
        else                     
          $display("TC1.3-2 FAIL: TSR readback not 0 (got 0x%h)", data_read);
      end
    end
  endtask

  // =============================================================================
  // Test Case 1.4: TCNT (Timer Count Register) Read-Only Test
  // Objective: Verify that the TCNT register can be read from but not written to.
  // =============================================================================
  task automatic tc_tcnt_ro;
    begin
      $display("\n[--- TC4: Testing the TCNT read-only register ---]");

      // 1. Test read functionality.
      // Read the current value of TCNT to save it for later comparison.
      u_APB_trans_bus.apb_read(`TCNT_ADDR, cnt_before_write);
      // Check PSLVERR. After a successful read, PSLVERR must be 0.
      if (PSLVERR == 1'b0) 
        $display("TC1.4-1 PASS: Successfully read from TCNT address (0x%h).", `TCNT_ADDR);
      else 
        $display("TC1.4-1 FAIL: Failed to read from TCNT (PSLVERR = 1).", `TCNT_ADDR);

      // 2. Test write functionality.
      // Generate a random value to write.
      w_rand_data = $urandom_range(255, 0); 
      $display("=> Attempting to write value 0x%h to TCNT (0x%h)...", w_rand_data, `TCNT_ADDR);
      // Execute the write transaction.
      u_APB_trans_bus.apb_write(`TCNT_ADDR, w_rand_data);
      // Check PSLVERR. Since TCNT is a read-only register, the write must fail and PSLVERR must be asserted.
      if (PSLVERR)
        $display("TC1.4-2 PASS: Write to TCNT failed as expected (PSLVERR = 1).");
      else
        $display("TC1.4-2 FAIL: Write to TCNT succeeded unexpectedly (PSLVERR = 0).");

      // 3. Verify that the value of TCNT was not changed.
      // Read the value of TCNT again.
      u_APB_trans_bus.apb_read(`TCNT_ADDR, cnt_after_write);
      // Compare the value read with the initial value. They must be the same.
      if (cnt_after_write == cnt_before_write)
        $display("TC1.4-3 PASS: TCNT value is still 0x%h after attempted write.", cnt_after_write);
      else
        $display("TC1.4-3 FAIL: TCNT value was changed from 0x%h to 0x%h.", cnt_before_write, cnt_after_write); 
    end
  endtask

  // =======================================================================
  // Test Case 1.5: Null Address
  // Objective: Verify that an access to an invalid address asserts PSLVERR.
  // =======================================================================
  task automatic tc_null_addr;
    begin
      $display("\n[--- TC5: Null Address ---]");
      repeat (`repeat_count) begin
        // Generate an address that is not one of the defined register addresses TDR, TCR, TSR
        null_addr = $urandom_range(255, 4);
        w_rand_data = $urandom_range(255, 0);

        // Perform a write transaction to the invalid address
        u_APB_trans_bus.apb_write(null_addr, w_rand_data);
        // Read from the invalid address to check PSLVERR
        u_APB_trans_bus.apb_read(null_addr, data_read);
        // PSLVERR should be asserted for an invalid address
        if (PSLVERR)
          $display("TC1.5 PASS: PSLVERR asserted for invalid addr = 0x%h (PSLVERR = 1)", null_addr);
        else
          $display("TC1.5 FAIL: PSLVERR not asserted for invalid addr = 0x%h (PSLVERR = 0)", null_addr);
      end
    end
  endtask

  // ================================================================================================
  // Test Case 1.6: Mixed Valid/Invalid Address
  // Objective: Verify that the testbench handles both valid and invalid addresses within a sequence. 
  //            The behavior of this test case is dependent on the IP's specific address decoding.
  // ================================================================================================
  task automatic tc_mixed_addr;
    begin
      $display("\n[--- TC6: Mixed Address ---]");
      repeat (`repeat_count) begin
        mixed_addr = $urandom_range(255, 0);
        w_rand_data = $urandom_range(255, 0);

        u_APB_trans_bus.apb_write(mixed_addr, w_rand_data);

        // Check if the random address is a valid register address
        if ((mixed_addr == `TDR_ADDR) || (mixed_addr == `TCR_ADDR) || (mixed_addr == `TSR_ADDR)) begin
          $display("=> Writing random data 0x%h to valid address 0x%h...", w_rand_data, mixed_addr);
          // After a valid access, PSLVERR should NOT be asserted
          if (!PSLVERR)
            $display("TC1.6 PASS: Write to valid addr 0x%h worked as expected (PSLVERR = 0).", mixed_addr);
          else
            $display("TC1.6 FAIL: Write to valid addr 0x%h failed unexpectedly (PSLVERR = 1).", mixed_addr);
        end else begin
          $display("=> Writing random data 0x%h to invalid address 0x%h...", w_rand_data, mixed_addr);
          // After an invalid access, PSLVERR should be asserted
          if (PSLVERR)
            $display("TC1.6 PASS: Write to invalid addr 0x%h failed as expected (PSLVERR = 1).", mixed_addr);
          else
            $display("TC1.6 FAIL: Write to invalid addr 0x%h worked unexpectedly (PSLVERR = 0).", mixed_addr);
        end
      end
    end
  endtask

  // -----------------------------------------------------------------------------------------------------------
  // --------------------------- [TMR_TESTCASE_02] - [Functionality] Tests -------------------------------------

  // =========================================================================================================
  // Test Case 2.1: Single Up-Counting, wait for OVF flag; Then clear OVF flag | with CLK_IN[0], ... CLK_IN[3]
  // Objective: Verify up-counting from a loaded value and overflow detection, then clear flag
  // =========================================================================================================
  task automatic upcount_check_clr_ovf(input [1:0] cks);
    begin
      $display("\n[--- Up-Counting and Check Overflow with CLK_IN[%0d] ---]", cks);
      u_APB_trans_bus.program_and_start(8'hFD, 1'b0, cks);

      // Poll TCNT until it reaches 0x02
      do begin
        u_APB_trans_bus.apb_read(`TCNT_ADDR, data_read);
        #10; // Small delay to avoid excessive reads
      end while (data_read != 8'h02);

      $display("Start count = 8'hFD | Current count = 0x%h", data_read);

      // 1. Check if the TMR_OVF flag is set 
      if (TMR_OVF) $display("TC2.1-1 PASS: TMR_OVF flag is set exactly");
      else         $display("TC2.1-1 FAIL: TMR_OVF flag is NOT set exactly.");

      // 2. Check if TSR[0] = 1 
      u_APB_trans_bus.apb_read(`TSR_ADDR, data_read);
      if (data_read[`TMR_OVF_BIT]) $display("TC2.1-2 PASS: OVF flag set by HW");
      else                         $display("TC2.1-2 FAIL: OVF flag not set");

      // 3. Clear OVF flag via OVF bit of TSR 
      u_APB_trans_bus.clear_tsr();
      u_APB_trans_bus.apb_read(`TSR_ADDR, data_read);
      if (!data_read[`TMR_OVF_BIT]) $display("TC2.1-3 PASS: OVF cleared by SW");
      else                          $display("TC2.1-3 FAIL: OVF not cleared");
      @(posedge PCLK);
      if (!u_ip_timer.TMR_OVF) $display("TC2.1-3 PASS: OVF flag is cleared exactly");
      else                     $display("TC2.1-3 FAIL: OVF flag is not cleared exactly");

    end
  endtask

  // ==========================================================================================================
  // Test Case 2.2: Single Down-Counting, wait for UDF flag; Then clear UDF flag | with CLK_IN[0], ... CLK_IN[3]
  // Objective: Verify down-counting from a loaded value and underflow detection, then clear flag
  // ==========================================================================================================
  task automatic dwcount_check_clr_udf(input [1:0] cks);
    begin
      $display("\n[--- Down-Counting and Underflow with CLK_IN[%0d] ---]", cks);
      u_APB_trans_bus.program_and_start(8'h02, 1'b1, cks);

      // Poll TCNT until it reaches 0xFD
      do begin
        u_APB_trans_bus.apb_read(`TCNT_ADDR, data_read);
        #10; // Small delay to avoid excessive reads
      end while (data_read != 8'hFD);

      $display("Start count = 8'h02 | Current count = 0x%h", data_read);

      // 1. Check if the TMR_UDF flag is set 
      if (TMR_UDF) $display("TC2.2-1 PASS: TMR_UDF flag is set exactly");
      else         $display("TC2.2-1 FAIL: TMR_UDF flag is NOT set exactly.");

      // 2. Check if TSR[1] = 1 
      u_APB_trans_bus.apb_read(`TSR_ADDR, data_read);
      if (data_read[`TMR_UDF_BIT]) $display("TC2.2-2 PASS: OVF flag set by HW");
      else                         $display("TC2.2-2 FAIL: OVF flag not set");

      // 3. Clear UDF flag via UDF bit of TSR 
      u_APB_trans_bus.clear_tsr();
      u_APB_trans_bus.apb_read(`TSR_ADDR, data_read);
      if (!data_read[`TMR_UDF_BIT]) $display("TC2.2-3 PASS: UDF cleared by SW");
      else                          $display("TC2.2-3 FAIL: UDF not cleared");
      @(posedge PCLK);
      if (!u_ip_timer.TMR_UDF) $display("TC2.2-3 PASS: UDF flag is cleared exactly");
      else                     $display("TC2.2-3 FAIL: UDF flag is not cleared exactly");

    end
  endtask

  // ===================================================================================
  // Test Case 2.3: upcount_forkjoin (thread 1 & thread 2) with CLK_IN[0], ... CLK_IN[3]
  // ===================================================================================
  task automatic upcount_forkjoin(input [1:0] cks, input int latency_margin = 100);
    int div_factor;
    reg [`DATA_WIDTH-1:0] start_val;
    int inc_needed;
    int pclk_cycles_to_ovf;
    int th1_wait, th2_wait;
    reg loop_th1_pass, loop_th2_pass;
    reg [`DATA_WIDTH-1:0] tsr_val;
    reg [`DATA_WIDTH-1:0] dbg_tcnt;
    reg [`DATA_WIDTH-1:0] dbg_tcr;
    integer t;
    integer local_err_cnt;
    reg clk_in_initial, clk_in_toggled;

    local_err_cnt = 0;

    // Map CKS to division factor
    case (cks)
      2'b00: div_factor = 2;
      2'b01: div_factor = 4;
      2'b10: div_factor = 8;
      2'b11: div_factor = 16;
      default: begin
        div_factor = 2;
        $error("Invalid CKS value %0b, defaulting to div_factor=2", cks);
        local_err_cnt = local_err_cnt + 1;
      end
    endcase

    start_val = $urandom_range(0, 255);
    $display("\n=== TEST for CKS=%0d, start=0x%0h (upcount) ===", cks, start_val);

    u_APB_trans_bus.program_and_start(start_val, 1'b0, cks);
    u_APB_trans_bus.apb_read(`TCR_ADDR, dbg_tcr);
    $display("TCR after program_and_start: 0x%0h", dbg_tcr);
    if (!dbg_tcr[4]) begin // Assuming TCR.EN is bit 4
      $display("ERROR: Timer not enabled (TCR.EN=0)!");
      local_err_cnt = local_err_cnt + 1;
    end

    inc_needed = $unsigned((1 << `DATA_WIDTH) - start_val);
    pclk_cycles_to_ovf = inc_needed * div_factor;
    th1_wait = pclk_cycles_to_ovf + latency_margin;
    th2_wait = (th1_wait * 2) / 3;

    loop_th1_pass = 0;
    loop_th2_pass = 0;

    $display("  inc_needed=%0d, pclk_cycles_to_ovf=%0d, margin=%0d, th2_wait=%0d",
             inc_needed, pclk_cycles_to_ovf, latency_margin, th2_wait);

    // Check CLK_IN[cks] activity
    clk_in_initial = CLK_IN[cks];
    #10;
    clk_in_toggled = (CLK_IN[cks] !== clk_in_initial);
    if (!clk_in_toggled) begin
      $display("ERROR: CLK_IN[%0d] not toggling!", cks);
      local_err_cnt = local_err_cnt + 1;
    end

    fork
      // Thread1: wait for OVF with timeout protection
      begin : mon1_up
        fork
          begin
            for (t = 0; t < th1_wait; t = t + 1) begin
              @(posedge PCLK);
              if (TMR_OVF) begin
                loop_th1_pass = 1;
                @(posedge PCLK); // Wait one cycle for TCNT to settle
                u_APB_trans_bus.apb_read(`TCNT_ADDR, dbg_tcnt);
                if (dbg_tcnt != 0) begin
                  $display("CKS=%0d Thread1: ERROR - OVF observed but TCNT=0x%0h (expected 0x0)", cks, dbg_tcnt);
                  local_err_cnt = local_err_cnt + 1;
                end
                $display("CKS=%0d Thread1: PASS - OVF observed at time %0t (after %0d cycles), TCNT=0x%0h",
                         cks, $time, t, dbg_tcnt);
                disable mon1_up;
              end
            end
            if (!loop_th1_pass) begin
              u_APB_trans_bus.apb_read(`TCNT_ADDR, dbg_tcnt);
              u_APB_trans_bus.apb_read(`TCR_ADDR, dbg_tcr);
              $display("CKS=%0b Thread1 TIMEOUT: TCNT=0x%0h, TCR=0x%0h, steps=%0d factor=%0d",
                       cks, dbg_tcnt, dbg_tcr, inc_needed, div_factor);
              $display("Hint: check TCR.EN and CKS bits; if EN=0 timer won't count.");
              local_err_cnt = local_err_cnt + 1;
            end
          end
          begin
            #100000; // Timeout after 100us
            if (!loop_th1_pass) begin
              $error("Timeout waiting for TMR_OVF in thread1!");
              local_err_cnt = local_err_cnt + 1;
            end
            disable mon1_up;
          end
        join_any
      end

      // Thread2: early check
      begin : mon2_up
        if (th2_wait > 0) begin
          repeat (th2_wait) @(posedge PCLK);
          u_APB_trans_bus.apb_read(`TSR_ADDR, tsr_val);
          u_APB_trans_bus.apb_read(`TCNT_ADDR, dbg_tcnt);
          if (tsr_val[`TMR_OVF_BIT]) begin
            $display("CKS=%0d Thread2: FAULT - OVF too early TSR=0x%0h, TCNT=0x%0h",
                     cks, tsr_val, dbg_tcnt);
            local_err_cnt = local_err_cnt + 1;
          end else begin
            loop_th2_pass = 1;
            $display("CKS=%0d Thread2: PASS - no OVF yet TSR=0x%0h, TCNT=0x%0h",
                     cks, tsr_val, dbg_tcnt);
          end
        end else begin
          $display("CKS=%0d Thread2: SKIPPED - th2_wait=%0d is invalid", cks, th2_wait);
          loop_th2_pass = 1; // Pass by default to avoid false failure
        end
      end
    join

    if (loop_th1_pass && loop_th2_pass) begin
      $display("CKS=%0d: PASS (th1+th2 ok)", cks);
    end else begin
      $display("CKS=%0d: FAIL (th1=%0d th2=%0d) err_cnt=%0d", cks, loop_th1_pass, loop_th2_pass, local_err_cnt);
    end

    err_cnt += local_err_cnt;
    repeat (4) @(posedge PCLK);
  endtask

  // ===================================================================================
  // Test Case 2.4: downcount_forkjoin (thread 1 & thread 2) with CLK_IN[0], ... CLK_IN[3]
  // ===================================================================================
  task automatic dwcount_forkjoin(input [1:0] cks, input int latency_margin = 100);
    int div_factor;
    reg [`DATA_WIDTH-1:0] start_val;
    int dec_needed;
    int pclk_cycles_to_udf;
    int th1_wait, th2_wait;
    reg loop_th1_pass, loop_th2_pass;
    reg [`DATA_WIDTH-1:0] tsr_val;
    reg [`DATA_WIDTH-1:0] dbg_tcnt;
    reg [`DATA_WIDTH-1:0] dbg_tcr;
    integer t;
    integer local_err_cnt;
    reg clk_in_initial, clk_in_toggled;

    local_err_cnt = 0;

    // Map CKS to division factor
    case (cks)
      2'b00: div_factor = 2;
      2'b01: div_factor = 4;
      2'b10: div_factor = 8;
      2'b11: div_factor = 16;
      default: begin
        div_factor = 2;
        $error("Invalid CKS value %0b, defaulting to div_factor=2", cks);
        local_err_cnt = local_err_cnt + 1;
      end
    endcase

    start_val = $urandom_range(0, 255);
    $display("\n=== TEST for CKS=%0d, start=0x%0h (downcount) ===", cks, start_val);

    u_APB_trans_bus.program_and_start(start_val, 1'b1, cks);
    u_APB_trans_bus.apb_read(`TCR_ADDR, dbg_tcr);
    $display("TCR after program_and_start: 0x%0h", dbg_tcr);
    if (!dbg_tcr[4]) begin // Assuming TCR.EN is bit 4
      $display("ERROR: Timer not enabled (TCR.EN=0)!");
      local_err_cnt = local_err_cnt + 1;
    end

    dec_needed = (start_val == 0) ? 1 : $unsigned(start_val); // Handle edge case and signed issue
    pclk_cycles_to_udf = dec_needed * div_factor;
    th1_wait = pclk_cycles_to_udf + latency_margin;
    th2_wait = (th1_wait * 2) / 3;

    loop_th1_pass = 0;
    loop_th2_pass = 0;

    $display("  dec_needed=%0d, pclk_cycles_to_udf=%0d, margin=%0d, th2_wait=%0d",
             dec_needed, pclk_cycles_to_udf, latency_margin, th2_wait);

    // Check CLK_IN[cks] activity
    clk_in_initial = CLK_IN[cks];
    #10;
    clk_in_toggled = (CLK_IN[cks] !== clk_in_initial);
    if (!clk_in_toggled) begin
      $display("ERROR: CLK_IN[%0d] not toggling!", cks);
      local_err_cnt = local_err_cnt + 1;
    end

    fork
      // Thread1: wait for UDF with timeout protection
      begin : mon1
        fork
          begin
            for (t = 0; t < th1_wait; t = t + 1) begin
              @(posedge PCLK);
              if (TMR_UDF) begin
                loop_th1_pass = 1;
                @(posedge PCLK); // Wait one cycle for TCNT to settle
                u_APB_trans_bus.apb_read(`TCNT_ADDR, dbg_tcnt);
                if (dbg_tcnt != 0) begin
                  $display("CKS=%0d Thread1: ERROR - UDF observed but TCNT=0x%0h (expected 0x0)", cks, dbg_tcnt);
                  local_err_cnt = local_err_cnt + 1;
                end
                $display("CKS=%0d Thread1: PASS - UDF observed at time %0t (after %0d cycles), TCNT=0x%0h",
                         cks, $time, t, dbg_tcnt);
                disable mon1;
              end
            end
            if (!loop_th1_pass) begin
              u_APB_trans_bus.apb_read(`TCNT_ADDR, dbg_tcnt);
              u_APB_trans_bus.apb_read(`TCR_ADDR, dbg_tcr);
              $display("CKS=%0b Thread1 TIMEOUT: TCNT=0x%0h, TCR=0x%0h, steps=%0d factor=%0d",
                       cks, dbg_tcnt, dbg_tcr, dec_needed, div_factor);
              $display("Hint: check TCR.EN and CKS bits; if EN=0 timer won't count.");
              local_err_cnt = local_err_cnt + 1;
            end
          end
          begin
            #100000; // Timeout after 100us
            if (!loop_th1_pass) begin
              $error("Timeout waiting for TMR_UDF in thread1!");
              local_err_cnt = local_err_cnt + 1;
            end
            disable mon1;
          end
        join_any
      end

      // Thread2: early check
      begin : mon2
        if (th2_wait > 0) begin
          repeat (th2_wait) @(posedge PCLK);
          u_APB_trans_bus.apb_read(`TSR_ADDR, tsr_val);
          u_APB_trans_bus.apb_read(`TCNT_ADDR, dbg_tcnt);
          if (tsr_val[`TMR_UDF_BIT]) begin
            $display("CKS=%0d Thread2: FAULT - UDF too early TSR=0x%0h, TCNT=0x%0h",
                     cks, tsr_val, dbg_tcnt);
            local_err_cnt = local_err_cnt + 1;
          end else begin
            loop_th2_pass = 1;
            $display("CKS=%0d Thread2: PASS - no UDF yet TSR=0x%0h, TCNT=0x%0h",
                     cks, tsr_val, dbg_tcnt);
          end
        end else begin
          $display("CKS=%0d Thread2: SKIPPED - th2_wait=%0d is invalid", cks, th2_wait);
          loop_th2_pass = 1; // Pass by default to avoid false failure
        end
      end
    join

    if (loop_th1_pass && loop_th2_pass) begin
      $display("CKS=%0d: PASS (th1+th2 ok)", cks);
    end else begin
      $display("CKS=%0d: FAIL (th1=%0d th2=%0d) err_cnt=%0d", cks, loop_th1_pass, loop_th2_pass, local_err_cnt);
    end

    err_cnt += local_err_cnt;
    repeat (4) @(posedge PCLK);
  endtask

  // ============================================================================
  // TC2.5: Enable/Disable Timer Mid-Count
  // ============================================================================
task automatic updwcount_timer_pause_resume (
  input       updown, // 0: up, 1: down
  input [1:0] cks
);
  reg [`DATA_WIDTH-1:0] start_val;
  reg [`DATA_WIDTH-1:0] tcnt_before_pause;
  reg [`DATA_WIDTH-1:0] tcnt_after_pause;
  // reg [`DATA_WIDTH-1:0] tcr_val;
  integer local_err_cnt;

  local_err_cnt = 0;
  if (updown == 1'b0) begin
      $display("\n[--- TC2.5: UP-Count Timer Pause/Resume Test with CLK_IN[%0d] ---]", cks);
  end else begin
      $display("\n[--- TC2.5: DOWN-Count Timer Pause/Resume Test with CLK_IN[%0d] ---]", cks);
  end

  // 1. Program and start timer with random value
  start_val = $urandom_range(1, 254);
  u_APB_trans_bus.program_and_start(start_val, 1'b0, cks);
  repeat (10) @(posedge u_ip_timer.u_pos_cnt_edge_detect.TMR_Edge); // Wait a few cycles
  u_APB_trans_bus.apb_read(`TCNT_ADDR, tcnt_before_pause);
  $display("counter before pause = 0x%h", tcnt_before_pause);

  // 2. Pause timer by disabling TCR.EN
  u_APB_trans_bus.pause_counter(updown, cks);
  repeat (10) @(posedge u_ip_timer.u_pos_cnt_edge_detect.TMR_Edge); // Wait a few cycles
  u_APB_trans_bus.apb_read(`TCNT_ADDR, tcnt_after_pause);
  if (tcnt_after_pause == tcnt_before_pause) begin
    $display("TC2.5-1 PASS: TCNT unchanged during pause, value = 0x%h", tcnt_after_pause);
  end else begin
    $display("TC2.5-1 FAIL: TCNT changed during pause, expected 0x%h, got 0x%h", tcnt_before_pause, tcnt_after_pause);
    local_err_cnt = local_err_cnt + 1;
  end

  // 3. Resume timer and check continuation
  @(posedge PCLK); // Wait a cycle
  u_APB_trans_bus.resume_counter(updown, cks); // Re-enable EN
  repeat (10) @(posedge u_ip_timer.u_pos_cnt_edge_detect.TMR_Edge); // Wait a few cycles
  u_APB_trans_bus.apb_read(`TCNT_ADDR, data_read);
  if (data_read != tcnt_after_pause) begin
    $display("TC2.5-2 PASS: TCNT resumed");
  end else begin
    $display("TC2.5-2 FAIL: TCNT did not UP-count. Expected > 0x%h, got 0x%h", tcnt_after_pause, data_read);
    local_err_cnt = local_err_cnt + 1;
  end

  if (local_err_cnt == 0) $display("TC2.5: PASS");
  else $display("TC2.5: FAIL with %0d errors", local_err_cnt);

  err_cnt += local_err_cnt;
  repeat (4) @(posedge PCLK);
endtask


  // Main Test Sequence
  initial begin
    // Initialize err_cnt
    err_cnt = 0;

    // Dump simulation waveforms to a VCD file for visualization
    $dumpfile("tb_ip_TIMER.vcd");
    $dumpvars(0, tb_ip_TIMER);

    // Init APB signal
    u_APB_trans_bus.initialization;

    // Initialize local variables
    w_rand_data      = {`DATA_WIDTH{1'b0}};
    data_write       = {`DATA_WIDTH{1'b0}};
    data_read        = {`DATA_WIDTH{1'b0}};
    cnt_before_write = {`DATA_WIDTH{1'b0}};
    cnt_after_write  = {`DATA_WIDTH{1'b0}};
    null_addr        = {ADDR_WIDTH{1'b1}};
    mixed_addr       = {ADDR_WIDTH{1'b1}};

    // Wait for the reset to be released
    wait (PRESETn === 1'b1);
    $display("=== Reset completed at %0t ===", $time);

    // ------------------------------------
    tc_tdr_rw();
    tc_tcr_rw();
    tc_tsr_rw();
    tc_tcnt_ro();
    tc_null_addr();
    tc_mixed_addr();

    upcount_check_clr_ovf(2'b00);
    upcount_check_clr_ovf(2'b01);
    upcount_check_clr_ovf(2'b10);
    upcount_check_clr_ovf(2'b11);

    dwcount_check_clr_udf(2'b00);
    dwcount_check_clr_udf(2'b01);
    dwcount_check_clr_udf(2'b10);
    dwcount_check_clr_udf(2'b11);

    upcount_forkjoin(2'b00);
    upcount_forkjoin(2'b01);
    upcount_forkjoin(2'b10);
    upcount_forkjoin(2'b11);

    dwcount_forkjoin(2'b00);
    dwcount_forkjoin(2'b01);
    dwcount_forkjoin(2'b10);
    dwcount_forkjoin(2'b11);

    updwcount_timer_pause_resume(1'b0, 2'b00);
    updwcount_timer_pause_resume(1'b0, 2'b01);
    updwcount_timer_pause_resume(1'b0, 2'b10);
    updwcount_timer_pause_resume(1'b0, 2'b11);

    updwcount_timer_pause_resume(1'b1, 2'b00);
    updwcount_timer_pause_resume(1'b1, 2'b01);
    updwcount_timer_pause_resume(1'b1, 2'b10);
    updwcount_timer_pause_resume(1'b1, 2'b11);

    // ------------------------------------
    // End of Simulation
    $display("\n=== Test finished at %0t, Total errors: %0d ===", $time, err_cnt);
    $finish;
  end
endmodule