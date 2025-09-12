module ahb2apb_alarm (
    input  logic        PCLK,
    input  logic        PRESETn,
    input  logic [7:0]  PADDR,
    input  logic        PWRITE,
    input  logic        PSEL,
    input  logic        PENABLE,
    input  logic [31:0] PWDATA,
    output logic [31:0] PRDATA,
    output logic        alarm_irq
);

    // Registers
    logic [5:0] rtc_sec;
    logic [5:0] rtc_min;
    logic [4:0] rtc_hour;

    logic [4:0] alarm_hour;
    logic [5:0] alarm_min;
    logic       alarm_status;

    // Address map
    localparam ADDR_RTC_SEC   = 8'h00;
    localparam ADDR_RTC_MIN   = 8'h04;
    localparam ADDR_RTC_HOUR  = 8'h08;
    localparam ADDR_ALARM_H   = 8'h0C;
    localparam ADDR_ALARM_M   = 8'h10;
    localparam ADDR_STATUS    = 8'h1C;

    // RTC: increment every tick
    always_ff @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            rtc_sec  <= 0;
            rtc_min  <= 0;
            rtc_hour <= 0;
        end else begin
            rtc_sec <= rtc_sec + 1;
            if (rtc_sec == 59) begin
                rtc_sec <= 0;
                rtc_min <= rtc_min + 1;
                if (rtc_min == 59) begin
                    rtc_min  <= 0;
                    rtc_hour <= rtc_hour + 1;
                    if (rtc_hour == 23) rtc_hour <= 0;
                end
            end
        end
    end

    // Alarm trigger
    always_ff @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn)
            alarm_status <= 0;
        else if ((rtc_hour == alarm_hour) && (rtc_min == alarm_min) && (rtc_sec == 0))
            alarm_status <= 1;
    end

    assign alarm_irq = alarm_status;

    // APB Write
    always_ff @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            alarm_hour <= 0;
            alarm_min  <= 0;
        end else if (PSEL && PENABLE && PWRITE) begin
            case (PADDR)
                ADDR_ALARM_H: alarm_hour <= PWDATA[4:0];
                ADDR_ALARM_M: alarm_min  <= PWDATA[5:0];
            endcase
        end
    end

    // APB Read
    always_comb begin
        PRDATA = 0;
        if (PSEL && !PWRITE) begin
            case (PADDR)
                ADDR_RTC_SEC:   PRDATA = rtc_sec;
                ADDR_RTC_MIN:   PRDATA = rtc_min;
                ADDR_RTC_HOUR:  PRDATA = rtc_hour;
                ADDR_ALARM_H:   PRDATA = alarm_hour;
                ADDR_ALARM_M:   PRDATA = alarm_min;
                ADDR_STATUS:    PRDATA = alarm_status;
            endcase
        end
    end

endmodule
