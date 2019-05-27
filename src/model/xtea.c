//======================================================================
//
// xtea.c
// ------
// Reference model for the xtea core.
// Code from:
// https://en.wikipedia.org/wiki/XTEA
//
// Test vectors from:
// https://www.nco.ncep.noaa.gov/pmb/codes/nwprod/decoders/decod_shared/lib/polarssl/library/xtea.c
//
// Compiled with:
// clang -Wextra -O2 -o xtea xtea.c
//
//
// Author: Joachim Strombergson
// Copyright (c) 2019, Assured AB
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or
// without modification, are permitted provided that the following
// conditions are met:
//
// 1. Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
//
// 2. Redistributions in binary form must reproduce the above copyright
//    notice, this list of conditions and the following disclaimer in
//    the documentation and/or other materials provided with the
//    distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
// FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
// COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
// BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
// STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
// ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//======================================================================

#include <stdint.h>
#include <stdio.h>

//------------------------------------------------------------------
// enc()
//------------------------------------------------------------------
void enc(unsigned int num_rounds, uint32_t v[2], uint32_t const key[4]) {
    unsigned int i;
    uint32_t v0=v[0], v1=v[1], sum=0, delta=0x9E3779B9;
    for (i=0; i < num_rounds; i++) {
        v0 += (((v1 << 4) ^ (v1 >> 5)) + v1) ^ (sum + key[sum & 3]);
        sum += delta;
        v1 += (((v0 << 4) ^ (v0 >> 5)) + v0) ^ (sum + key[(sum>>11) & 3]);
    }
    v[0]=v0; v[1]=v1;
}


//------------------------------------------------------------------
// dec()
//------------------------------------------------------------------
void dec(unsigned int num_rounds, uint32_t v[2], uint32_t const key[4]) {
    unsigned int i;
    uint32_t v0=v[0], v1=v[1], delta=0x9E3779B9, sum=delta*num_rounds;
    for (i=0; i < num_rounds; i++) {
        v1 -= (((v0 << 4) ^ (v0 >> 5)) + v0) ^ (sum + key[(sum>>11) & 3]);
        sum -= delta;
        v0 -= (((v1 << 4) ^ (v1 >> 5)) + v1) ^ (sum + key[sum & 3]);
    }
    v[0]=v0; v[1]=v1;
}


//------------------------------------------------------------------
// main()
//------------------------------------------------------------------
int main(void) {
  const uint32_t my_key [4] = {0x00010203, 0x04050607, 0x08090a0b, 0x0c0d0e0f};
  uint32_t my_block[2] = {0x41424344, 0x45464748};

  printf("Block before encipher: 0x%04x 0x%04x\n", my_block[0], my_block[1]);

  enc(32, &my_block[0], &my_key[0]);

  printf("Block after encipher:  0x%04x 0x%04x\n", my_block[0], my_block[1]);

  dec(32, &my_block[0], &my_key[0]);

  printf("Block after decipher:  0x%04x 0x%04x\n", my_block[0], my_block[1]);

  return 0;
}

//======================================================================
// EOF xtea.c
//======================================================================
