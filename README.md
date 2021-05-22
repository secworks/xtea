# xtea
Verilog implementation of the xtea block cipher.

## Status
The core is done and is functionally correct.
(As far as I know.)


## Introduction
[Xtea](https://en.wikipedia.org/wiki/XTEA) is a compact, Feistel based
block cipher designed by Wheeler and Needham in 1997. It has a 64 bit
block and 128 bit key. It has a very simple key scheme but many rounds.


## Implementation details
The core is implemented with two cycles for each round (which is two
Feistel rounds.)



## FuseSoC
This core is supported by the
[FuseSoC](https://github.com/olofk/fusesoc) core package manager and
build system. Some quick  FuseSoC instructions:

install FuseSoC
~~~
pip install fusesoc
~~~

Create and enter a new workspace
~~~
mkdir workspace && cd workspace
~~~

Register xtea as a library in the workspace
~~~
fusesoc library add xtea /path/to/xtea
~~~

...if repo is available locally or...
...to get the upstream repo
~~~
fusesoc library add xtea https://github.com/secworks/xtea
~~~

To run lint
~~~
fusesoc run --target=lint secworks:crypto:xtea
~~~

Run tb_xtea testbench
~~~
fusesoc run --target=tb_xtea secworks:crypto:xtea
~~~

Run with modelsim instead of default tool (icarus)
~~~
fusesoc run --target=tb_xtea --tool=modelsim secworks:crypto:xtea
~~~

List all targets
~~~
fusesoc core show secworks:crypto:xtea
~~~


### Implementation Results
#### Xilinx Artix-7
Device: xc7a200t

Package: fbg484

Speed: -3


Slice registers: 298

Slice LUTs: 552

Occupied Slices: 181

Clock frequency: 177 MHz
