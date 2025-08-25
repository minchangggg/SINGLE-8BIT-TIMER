// Xử lý REPORT CHƯA ổn

// =========================================================
// Test Case 2.1: Up-Counting and Check Overflow with CLK_IN[0]
// Objective: Verify up-counting from a loaded value and overflow detection.
// =========================================================
$display("\n[--- TC2.1: Up-Counting and Overflow with CLK_IN[0] ---]");
// Clear all flags via TSR before starting
u_APB_trans_bus.apb_write(`TSR_ADDR, {`DATA_WIDTH{1'b1}}); 
// Load TDR with a value near max (FD)
data_write = 8'hFD;
u_APB_trans_bus.apb_write(`TDR_ADDR, data_write);
// Configure TCR for load bit, up-counting, enable, and clock source (CLK_IN[0] = pclk/2)
data_write = 8'b1001_0000;
u_APB_trans_bus.apb_write(`TCR_ADDR, data_write);
// Disable load bit via TCR, start up-counting
data_write = data_write & ~(1 << `TCR_LOAD_BIT);
u_APB_trans_bus.apb_write(`TCR_ADDR, data_write);
#200;

u_APB_trans_bus.apb_read(`TCNT_ADDR, data_read);
$display("Start count = 8'hFD | Curent count = 0x%h", data_read);
// Check if the TCNT value is 0 and the TMR_OVF flag is set 
if ((data_read >= 8'h00) && (data_read <= 8'hFD) && (TMR_OVF == 1'b1)) begin
  $display("PASS: TMR_OVF flag is set exactly");
end else begin
  $display("FAIL: TMR_OVF flag is NOT set exactly.");
end

// =========================================================
// Test Case 2.2: Up-Counting and Check Overflow with CLK_IN[1] 
// Objective: Verify up-counting from a loaded value and overflow detection.
// =========================================================
$display("\n[--- TC2.2: Up-Counting and Overflow with CLK_IN[1] ---]");
// Clear all flags via TSR before starting
u_APB_trans_bus.apb_write(`TSR_ADDR, {`DATA_WIDTH{1'b1}}); 
// Load TDR with a value near max (FD)
data_write = 8'hFD;
u_APB_trans_bus.apb_write(`TDR_ADDR, data_write);
// Configure TCR for load bit, up-counting, enable, and clock source (CLK_IN[0] = pclk/2)
data_write = 8'b1001_0001;
u_APB_trans_bus.apb_write(`TCR_ADDR, data_write);
// Disable load bit via TCR, start up-counting
data_write = data_write & ~(1 << `TCR_LOAD_BIT);
u_APB_trans_bus.apb_write(`TCR_ADDR, data_write);
#200;

u_APB_trans_bus.apb_read(`TCNT_ADDR, data_read);
$display("Start count = 8'hFD | Curent count = 0x%h", data_read);
// Check if the TCNT value is 0 and the TMR_OVF flag is set 
if ((data_read >= 8'h00) && (data_read <= 8'hFD) && (TMR_OVF == 1'b1)) begin
  $display("PASS: TMR_OVF flag is set exactly");
end else begin
  $display("FAIL: TMR_OVF flag is NOT set exactly.");
end

// =========================================================
// Test Case 2.3: Up-Counting and Check Overflow with CLK_IN[2]
// Objective: Verify up-counting from a loaded value and overflow detection.
// =========================================================
$display("\n[--- TC2.3: Up-Counting and Overflow with CLK_IN[2] ---]");
// Clear all flags via TSR before starting
u_APB_trans_bus.apb_write(`TSR_ADDR, {`DATA_WIDTH{1'b1}});
// Load TDR with a value near max (FD)
data_write = 8'hFD;
u_APB_trans_bus.apb_write(`TDR_ADDR, data_write);
// Configure TCR for load bit, up-counting, enable, and clock source (CLK_IN[0] = pclk/2)
data_write = 8'b1001_0010;
u_APB_trans_bus.apb_write(`TCR_ADDR, data_write);
// Disable load bit via TCR, start up-counting
data_write = data_write & ~(1 << `TCR_LOAD_BIT);
u_APB_trans_bus.apb_write(`TCR_ADDR, data_write);
#200;

u_APB_trans_bus.apb_read(`TCNT_ADDR, data_read);
$display("Start count = 8'hFD | Curent count = 0x%h", data_read);
// Check if the TCNT value is 0 and the TMR_OVF flag is set 
if ((data_read >= 8'h00) && (data_read <= 8'hFD) && (TMR_OVF == 1'b1)) begin
  $display("PASS: TMR_OVF flag is set exactly");
end else begin
  $display("FAIL: TMR_OVF flag is NOT set exactly.");
end

// =========================================================
// Test Case 2.4: Up-Counting with and Check Overflow CLK_IN[3]
// Objective: Verify up-counting from a loaded value and overflow detection.
// =========================================================
$display("\n[--- TC2.4: Up-Counting and Overflow with CLK_IN[3] ---]");
// Clear all flags via TSR before starting
u_APB_trans_bus.apb_write(`TSR_ADDR, {`DATA_WIDTH{1'b1}}); 
// Load TDR with a value near max (FD)
data_write = 8'hFD;
u_APB_trans_bus.apb_write(`TDR_ADDR, data_write);
// Configure TCR for load bit, up-counting, enable, and clock source (CLK_IN[0] = pclk/2)
data_write = 8'b1001_0011;
u_APB_trans_bus.apb_write(`TCR_ADDR, data_write);
// Disable load bit via TCR, start up-counting
data_write = data_write & ~(1 << `TCR_LOAD_BIT);
u_APB_trans_bus.apb_write(`TCR_ADDR, data_write);
#200;

u_APB_trans_bus.apb_read(`TCNT_ADDR, data_read);
$display("Start count = 8'hFD | Curent count = 0x%h", data_read);
// Check if the TCNT value is 0 and the TMR_OVF flag is set 
if ((data_read >= 8'h00) && (data_read <= 8'hFD) && (TMR_OVF == 1'b1)) begin
  $display("PASS: TMR_OVF flag is set exactly");
end else begin
  $display("FAIL: TMR_OVF flag is NOT set exactly.");
end

// =========================================================
// Test Case 2.5: Down-Counting and Underflow with CLK_IN[0]
// Objective: Verify down-counting from a loaded value and underflow detection.
// =========================================================
$display("\n[--- TC2.5: Down-Counting and Underflow with CLK_IN[0] ---]");
// Clear all flags via TSR before starting
u_APB_trans_bus.apb_write(`TSR_ADDR, {`DATA_WIDTH{1'b1}});
// Load TDR with a low value (03)
data_write = 8'h03;
u_APB_trans_bus.apb_write(`TDR_ADDR, data_write);
// Configure TCR for load bit, down-counting, enable, and clock source (CLK_IN[0] = pclk/2)
data_write = 8'b1011_0000;
u_APB_trans_bus.apb_write(`TCR_ADDR, data_write);
// Disable load bit via TCR, start down-counting
data_write = data_write & ~(1 << `TCR_LOAD_BIT);
u_APB_trans_bus.apb_write(`TCR_ADDR, data_write);
#200;

u_APB_trans_bus.apb_read(`TCNT_ADDR, data_read);
$display("Start count = 8'h03 | Curent count = 0x%h", data_read);
// Check if the TCNT value is 0 and the TMR_UDF flag is set 
if ((data_read <= 8'hFF) && (data_read >= 8'h03) && (TMR_OVF == 1'b1)) begin
  $display("PASS: TMR_UDF flag is set after underflow.");
end else begin
  $display("FAIL: TMR_UDF flag is NOT set after underflow.");
end

// =========================================================
// Test Case 2.6: Down-Counting and Underflow with CLK_IN[1]
// Objective: Verify down-counting from a loaded value and underflow detection.
// =========================================================
$display("\n[--- TC2.6: Down-Counting and Underflow with CLK_IN[1] ---]");
// Clear all flags via TSR before starting
u_APB_trans_bus.apb_write(`TSR_ADDR, {`DATA_WIDTH{1'b1}}); 
// Load TDR with a low value (03)
data_write = 8'h03;
u_APB_trans_bus.apb_write(`TDR_ADDR, data_write);
// Configure TCR for load bit, down-counting, enable, and clock source (CLK_IN[0] = pclk/2)
data_write = 8'b1011_0001;
u_APB_trans_bus.apb_write(`TCR_ADDR, data_write);
// Disable load bit via TCR, start down-counting
data_write = data_write & ~(1 << `TCR_LOAD_BIT);
u_APB_trans_bus.apb_write(`TCR_ADDR, data_write);
#200;

u_APB_trans_bus.apb_read(`TCNT_ADDR, data_read);
$display("Start count = 8'h03 | Curent count = 0x%h", data_read);
// Check if the TCNT value is 0 and the TMR_UDF flag is set 
if ((data_read <= 8'hFF) && (data_read >= 8'h03) && (TMR_OVF == 1'b1)) begin
  $display("PASS: TMR_UDF flag is set after underflow.");
end else begin
  $display("FAIL: TMR_UDF flag is NOT set after underflow.");
end

// =========================================================
// Test Case 2.7: Down-Counting and Underflow with CLK_IN[2]
// Objective: Verify down-counting from a loaded value and underflow detection.
// =========================================================
$display("\n[--- TC2.7: Down-Counting and Underflow with CLK_IN[2] ---]");
// Clear all flags via TSR before starting
u_APB_trans_bus.apb_write(`TSR_ADDR, {`DATA_WIDTH{1'b1}}); 
// Load TDR with a low value (03)
data_write = 8'h03;
u_APB_trans_bus.apb_write(`TDR_ADDR, data_write);
// Configure TCR for load bit, down-counting, enable, and clock source (CLK_IN[0] = pclk/2)
data_write = 8'b1011_0010;
u_APB_trans_bus.apb_write(`TCR_ADDR, data_write);
// Disable load bit via TCR, start down-counting
data_write = data_write & ~(1 << `TCR_LOAD_BIT);
u_APB_trans_bus.apb_write(`TCR_ADDR, data_write);
#200;

u_APB_trans_bus.apb_read(`TCNT_ADDR, data_read);
$display("Start count = 8'h03 | Curent count = 0x%h", data_read);
// Check if the TCNT value is 0 and the TMR_UDF flag is set 
if ((data_read <= 8'hFF) && (data_read >= 8'h03) && (TMR_OVF == 1'b1)) begin
  $display("PASS: TMR_UDF flag is set after underflow.");
end else begin
  $display("FAIL: TMR_UDF flag is NOT set after underflow.");
end

// =========================================================
// Test Case 2.8: Down-Counting and Underflow with CLK_IN[3]
// Objective: Verify down-counting from a loaded value and underflow detection.
// =========================================================
$display("\n[--- TC2.8: Down-Counting and Underflow with CLK_IN[3] ---]");
// Clear all flags via TSR before starting
u_APB_trans_bus.apb_write(`TSR_ADDR, {`DATA_WIDTH{1'b1}}); 
// Load TDR with a low value (03)
data_write = 8'h03;
u_APB_trans_bus.apb_write(`TDR_ADDR, data_write);
// Configure TCR for load bit, down-counting, enable, and clock source (CLK_IN[0] = pclk/2)
data_write = 8'b1011_0011;
u_APB_trans_bus.apb_write(`TCR_ADDR, data_write);
// Disable load bit via TCR, start down-counting
data_write = data_write & ~(1 << `TCR_LOAD_BIT);
u_APB_trans_bus.apb_write(`TCR_ADDR, data_write);
#200;

u_APB_trans_bus.apb_read(`TCNT_ADDR, data_read);
$display("Start count = 8'h03 | Curent count = 0x%h", data_read);
// Check if the TCNT value is 0 and the TMR_UDF flag is set 
if ((data_read <= 8'hFF) && (data_read >= 8'h03) && (TMR_OVF == 1'b1)) begin
  $display("PASS: TMR_UDF flag is set after underflow.");
end else begin
  $display("FAIL: TMR_UDF flag is NOT set after underflow.");
end
