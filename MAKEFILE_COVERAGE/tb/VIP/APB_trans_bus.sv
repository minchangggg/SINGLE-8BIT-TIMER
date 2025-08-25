`ifndef __APB_TRANS_BUS_V__
`define __APB_TRANS_BUS_V__

`include "rtl/reg_def.sv"    

module APB_trans_bus #(
  parameter ADDR_WIDTH = 8
)(
  input wire                   PCLK, PRESETn,
  input wire 	               PREADY, PSLVERR,
  input wire [`DATA_WIDTH-1:0] PRDATA,
  
  output reg 		       PSEL, PENABLE, PWRITE,
  output reg [ADDR_WIDTH-1:0]  PADDR,
  output reg [`DATA_WIDTH-1:0] PWDATA
);

  // Always block for reset handling
  task initialization; 
    begin
      PSEL    <= 1'b0;
      PENABLE <= 1'b0;
      PWRITE  <= 1'b0;
      PADDR   <= {`DATA_WIDTH{1'b1}};
      PWDATA  <= {`DATA_WIDTH{1'b0}};
    end
  endtask

  // APB write task
  task apb_write (
    input [ADDR_WIDTH-1:0]  addr, 
    input [`DATA_WIDTH-1:0] data
  );
    begin
      // reset
      PSEL    = 1'b0;
      PENABLE = 1'b0;
      PWRITE  = 1'b0;
      PWDATA  = 8'h00;

      @(posedge PCLK);
      PADDR   = addr;
      PWDATA  = data;
      PWRITE  = 1'b1;
      PSEL    = 1'b1;
      PENABLE = 1'b0;

      @(posedge PCLK);
      PENABLE = 1'b1;

      // Wait for PREADY to be high to end the transaction
      // wait (PREADY);
      @(posedge PCLK); 
      // After the transaction is complete, end the cycle
      PSEL    = 1'b0;
      PENABLE = 1'b0;
      PWDATA  = {`DATA_WIDTH{1'b0}};
    end
  endtask

  // APB read task
  task apb_read (
    input      [ADDR_WIDTH-1:0]  addr,
    output reg [`DATA_WIDTH-1:0] data_out
  );
    begin
      @(posedge PCLK);
      // Setup phase
      PADDR <= addr;
      PWRITE <= 1'b0;
      PSEL <= 1'b1;
      PENABLE <= 1'b0;

      @(posedge PCLK);
      // Access phase
      PENABLE <= 1'b1;

      // Wait for PREADY to be high to end the transaction
      // wait (PREADY);
      @(posedge PCLK);
      // After the transaction is complete, end the cycle
      data_out = PRDATA;
      PSEL <= 1'b0;
      PENABLE <= 1'b0;     
    end
  endtask

  // clear TSR 
  task clear_tsr;
    begin
      apb_write(`TSR_ADDR, {`DATA_WIDTH{1'b1}}); 
    end
  endtask

  // set up TCR value
  function automatic [`DATA_WIDTH-1:0] config_TCR (
    input load,
    input updown,
    input en,
    input [1:0] cks
  );
    reg [`DATA_WIDTH-1:0] TCR;
    begin
      TCR = {`DATA_WIDTH{1'b0}};
      TCR[`TCR_LOAD_BIT]             = load;
      TCR[`TCR_UPDOWN_BIT]           = updown;
      TCR[`TCR_EN_BIT]               = en;
      TCR[`TCR_CKS_MSB:`TCR_CKS_LSB] = cks;
      config_TCR = TCR;
    end
  endfunction

// program and start: write TDR, cause load, enable counting
task automatic program_and_start (
    input [`DATA_WIDTH-1:0] start_val,
    input                   updown, // 0: up, 1: down
    input [1:0]             cks
);
    reg [`DATA_WIDTH-1:0] tcr_config;

    begin
        // Clear all flags via TSR before starting
        clear_tsr();
        
        // Load TDR with start_val
        apb_write(`TDR_ADDR, start_val);

        // Configure TCR with load bit = 1
        tcr_config = config_TCR(1'b1, updown, 1'b1, cks);
        apb_write(`TCR_ADDR, tcr_config);
        
        // Delay 1 cycle for register update
        // @(posedge `PCLK);

        // Disable load bit of TCR and start counting
        tcr_config = config_TCR(1'b0, updown, 1'b1, cks);
        apb_write(`TCR_ADDR, tcr_config);
        
        // Delay 1 cycle for register update
        // @(posedge `PCLK);
    end
endtask

task pause_counter (
    input       updown, // 0: up, 1: down
    input [1:0] cks
);
   reg [`DATA_WIDTH-1:0] tcr_config;
   begin
      // Disable load bit and enable bit of TCR 
      tcr_config = config_TCR(1'b0, updown, 1'b0, cks);
      apb_write(`TCR_ADDR, tcr_config);
   end 
endtask

task resume_counter (
    input       updown, // 0: up, 1: down
    input [1:0] cks
);
   reg [`DATA_WIDTH-1:0] tcr_config;
   begin
      // Disable load bit and enable bit of TCR 
      tcr_config = config_TCR(1'b0, updown, 1'b1, cks);
      apb_write(`TCR_ADDR, tcr_config);
   end 
endtask

//   // -------------------
//   // Check TCNT value
//   // -------------------
//   task check_tcnt_value(
//     input [`DATA_WIDTH-1:0] expected_value
//   );
//     reg [`DATA_WIDTH-1:0] actual_value;
//     begin
//       // Truyền biến 'actual_value' vào task và đọc giá trị trả về
//       apb_read(`TCNT_ADDR, actual_value);
//       if (actual_value == expected_value)
//         $display("CHECK TCNT PASSED: 0x%0h", actual_value);
//       else
//         $display("CHECK TCNT FAILED: got=0x%0h, expected=0x%0h",
//           actual_value, expected_value);
//     end
//   endtask

//   // -------------------
//   // Check OVF/UDF flags
//   // -------------------
//   task check_ovf_udf_flags(
//     input ovf_expected,
//     input udf_expected
//   );
//     reg [`DATA_WIDTH-1:0] tsr_value;
//     reg ovf_actual, udf_actual;
//     begin
//       // Truyền biến 'tsr_value' vào task và đọc giá trị trả về
//       apb_read(`TSR_ADDR, tsr_value);
//       ovf_actual = tsr_value[`TMR_OVF_BIT];
//       udf_actual = tsr_value[`TMR_UDF_BIT];
//       if ((ovf_actual == ovf_expected) && (udf_actual == udf_expected))
//         $display("CHECK FLAGS PASSED: OVF=%b, UDF=%b", ovf_actual, udf_actual);
//       else
//         $display("CHECK FLAGS FAILED: got OVF=%b, UDF=%b, expected OVF=%b, UDF=%b",
//           ovf_actual, udf_actual, ovf_expected, udf_expected);
//     end
//   endtask

endmodule

`endif // __APB_TRANS_BUS_V__

