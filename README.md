# xtea
Verilog implementation of the xtea block cipher.

## Status
The core is done and is functionally correct.
(As far as I know.)


## Introduction
[Xtea](https://en.wikipedia.org/wiki/XTEA) is a compact, Feistel based
block cipher designed by Wheeler and Needham in 1997. It has a 64 bit
block and 128 bit key. It has a very simple key scheme but many rounds.


## Implementation
The core is implemented with two cycles for each round (which is two
Feistel rounds.)


### Implementation Results
#### Xilinx Artix-7
Device: xc7a200t
Package: fbg484
Speed: -3

Slice registers: 298
Slice LUTs: 552
Occupied Slices: 181
Clock frequency: 177 MHz
