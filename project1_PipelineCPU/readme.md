# Pipeline CPU

Platform : Windows iVerilog.

## details

1. Implemented features:
```
jump
beq
lw
sw
HazardDetection
ForwardingUnit
Pipeline 4 Latches
```
2. Compile: (Using testbench.v & instruction.txt)
```
iverilog -o project1.o *.v
```
3. Output: output.txt & pipeline.vcd

Register information will be dumped to file "output.txt"

Wire information will be dumped to file "pipeline.vcd" (GTKWave)
