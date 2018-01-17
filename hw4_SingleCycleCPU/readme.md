# Single Cycle CPU

Platform : Windows iVerilog.

## details

1. Implemented modules:
```
Control.v
Adder.v
PC.v
Instruction_Memory.v
Registers.v
MUX5.v
MUX32.v
Sign_Extend.v
ALU.v
ALU_Control.v
```
2. Compile: (Using testbench.v & instruction.txt)
```
iverilog -o hw4.o *.v
```
3. Output: output.txt & test.vcd
Register information will be dumped to file "output.txt"
Wire information will be dumped to file "test.vcd" (GTKWave)
