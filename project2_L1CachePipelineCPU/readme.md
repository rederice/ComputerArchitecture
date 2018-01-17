# L1 Cache Pipeline CPU

Platform : Windows iVerilog.

## details

1. Implemented features:
```
dcache_top.v
dcache_tag_sram.v
dcache_data_sram.v
```
2. Compile: (Using testbench.v & instruction.txt)
```
iverilog -o project2.o *.v
```
3. Output: output.txt & cache.txt & test.vcd

Register information will be dumped to file "output.txt"

Cache information will be dumped to file "cache.txt"

Wire information will be dumped to file "test.vcd" (GTKWave)
