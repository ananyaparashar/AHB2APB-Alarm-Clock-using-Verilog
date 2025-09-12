module tb;
    logic        PCLK;
    logic        PRESETn;
    logic [7:0]  PADDR;
    logic        PWRITE;
    logic        PSEL;
    logic        PENABLE;
    logic [31:0] PWDATA;
    logic [31:0] PRDATA;
    logic        alarm_irq;

    // DUT
    ahb2apb_alarm dut (
        .PCLK(PCLK), .PRESETn(PRESETn),
        .PADDR(PADDR), .PWRITE(PWRITE), .PSEL(PSEL), .PENABLE(PENABLE),
        .PWDATA(PWDATA), .PRDATA(PRDATA), .alarm_irq(alarm_irq)
    );

    // Clock
    always #5 PCLK = ~PCLK;

    // Simple APB tasks
    task apb_write(input [7:0] addr, input [31:0] data);
        @(posedge PCLK);
        PADDR = addr; PWDATA = data; PWRITE = 1; PSEL = 1; PENABLE = 1;
        @(posedge PCLK);
        PSEL = 0; PENABLE = 0; PWRITE = 0;
    endtask

    task apb_read(input [7:0] addr, output [31:0] data);
        @(posedge PCLK);
        PADDR = addr; PWRITE = 0; PSEL = 1; PENABLE = 1;
        @(posedge PCLK);
        data = PRDATA;
        PSEL = 0; PENABLE = 0;
    endtask

    // Test
    int alarm_hour, alarm_min;
    initial begin
        // init
        PCLK = 0; PRESETn = 0;
        PADDR = 0; PWRITE = 0; PSEL = 0; PENABLE = 0; PWDATA = 0;
        #20 PRESETn = 1;

        // Get user input
        if (!$value$plusargs("ALARM_HOUR=%d", alarm_hour)) alarm_hour = 0;
        if (!$value$plusargs("ALARM_MIN=%d", alarm_min))   alarm_min  = 1;
        $display("User set alarm to %0d:%0d", alarm_hour, alarm_min);

        // Program alarm
        apb_write(8'h0C, alarm_hour);
        apb_write(8'h10, alarm_min);

        // Wait until alarm triggers
        wait (alarm_irq == 1);
        $display("[%0t] Alarm Triggered at RTC time!", $time);

        #50 $finish;
    end
endmodule
