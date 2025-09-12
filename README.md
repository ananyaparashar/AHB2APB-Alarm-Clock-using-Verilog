# AHB2APB-Alarm-Clock-using-Verilog

This project implements a Real-Time Clock (RTC) with Alarm functionality connected via an APB (Advanced Peripheral Bus) interface. It is written in SystemVerilog, complete with a testbench for simulation using Icarus Verilog. 
## Features
- Real-Time Clock (RTC) with hours, minutes, seconds.
- Alarm register (hour + minute) programmable via APB bus.
- Interrupt (alarm_irq) asserted when the RTC matches the programmed alarm time.
- Memory-mapped register interface for easy integration.
- Testbench with APB read/write tasks and simulation using $value$plusargs.

## Working procedure
1. The RTC increments seconds, minutes, and hours on each clock cycle.
2. The APB interface allows writing alarm hour and minute registers.
3. When RTC == ALARM, alarm_irq is asserted, and the status register is set.
4. Testbench uses $value$plusargs for user-defined alarm time.

### Note
- The input for the alarm clock is taken through the testbench. For simulation purposes it is set to 1 minute. This can be changed later.
- This project was simulated on edaplayground.com with Icarus Verilog
