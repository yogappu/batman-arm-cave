@
@ The eXtended Keccak Code Package (XKCP)
@ https://github.com/XKCP/XKCP
@
@ The Xoodoo permutation, designed by Joan Daemen, Seth Hoffert, Gilles Van Assche and Ronny Van Keer.
@
@ Implementation by Ronny Van Keer, hereby denoted as "the implementer".
@
@ For more information, feedback or questions, please refer to the Keccak Team website:
@ https://keccak.team/
@
@ To the extent possible under law, the implementer has waived all copyright
@ and related or neighboring rights to the source code in this file.
@ http://creativecommons.org/publicdomain/zero/1.0/
@

@ WARNING: These functions work only on little endian CPU with@ ARMv7m architecture (Cortex-M3, ...).


        .thumb
    .syntax unified
.text

@ ----------------------------------------------------------------------------
@
@  void Xoodoo_Initialize(Xoodoo_plain32_state *state)
@
    .align  4
.global Xoodoo_Initialize
.type	Xoodoo_Initialize, %function;
Xoodoo_Initialize:
    movs    r1, #0
    movs    r2, #0
    movs    r3, #0
    movs    r12, #0
    stmia   r0!, { r1 - r3, r12 }
    stmia   r0!, { r1 - r3, r12 }
    stmia   r0!, { r1 - r3, r12 }
    bx      lr
    .align  4


@ ----------------------------------------------------------------------------
@
@  void Xoodoo_AddBytes(Xoodoo_plain32_state *state, const unsigned char *data, unsigned int offset, unsigned int length)
@
.global Xoodoo_AddBytes
.type	Xoodoo_AddBytes, %function;
Xoodoo_AddBytes:
    push    {r4,lr}
    adds    r0, r0, r2                              @ state += offset
    subs    r3, r3, #4                              @ .if length >= 4
    bcc     Xoodoo_AddBytes_Bytes
Xoodoo_AddBytes_LanesLoop:                           @ then, perform on lanes
    ldr     r2, [r0]
    ldr     r4, [r1], #4
    eors    r2, r2, r4
    str     r2, [r0], #4
    subs    r3, r3, #4
    bcs     Xoodoo_AddBytes_LanesLoop
Xoodoo_AddBytes_Bytes:
    adds    r3, r3, #3
    bcc     Xoodoo_AddBytes_Exit
Xoodoo_AddBytes_BytesLoop:
    ldrb    r2, [r0]
    ldrb    r4, [r1], #1
    eors    r2, r2, r4
    strb    r2, [r0], #1
    subs    r3, r3, #1
    bcs     Xoodoo_AddBytes_BytesLoop
Xoodoo_AddBytes_Exit:
    pop     {r4,pc}
    .align  4


@ ----------------------------------------------------------------------------
@
@  void Xoodoo_OverwriteBytes(Xoodoo_plain32_state *state, const unsigned char *data, unsigned int offset, unsigned int length)
@
.global Xoodoo_OverwriteBytes
.type	Xoodoo_OverwriteBytes, %function;
Xoodoo_OverwriteBytes:
    adds    r0, r0, r2                              @ state += offset
    subs    r3, r3, #4                              @ .if length >= 4
    bcc     Xoodoo_OverwriteBytes_Bytes
Xoodoo_OverwriteBytes_LanesLoop:                     @ then, perform on words
    ldr     r2, [r1], #4
    str     r2, [r0], #4
    subs    r3, r3, #4
    bcs     Xoodoo_OverwriteBytes_LanesLoop
Xoodoo_OverwriteBytes_Bytes:
    adds    r3, r3, #3
    bcc     Xoodoo_OverwriteBytes_Exit
Xoodoo_OverwriteBytes_BytesLoop:
    ldrb    r2, [r1], #1
    strb    r2, [r0], #1
    subs    r3, r3, #1
    bcs     Xoodoo_OverwriteBytes_BytesLoop
Xoodoo_OverwriteBytes_Exit:
    bx      lr
    .align  4


@ ----------------------------------------------------------------------------
@
@  void Xoodoo_OverwriteWithZeroes(Xoodoo_plain32_state *state, unsigned int byteCount)
@
.global Xoodoo_OverwriteWithZeroes
.type	Xoodoo_OverwriteWithZeroes, %function;
Xoodoo_OverwriteWithZeroes:
    movs    r3, #0
    lsrs    r2, r1, #2
    beq     Xoodoo_OverwriteWithZeroes_Bytes
Xoodoo_OverwriteWithZeroes_LoopLanes:
    str     r3, [r0], #4
    subs    r2, r2, #1
    bne     Xoodoo_OverwriteWithZeroes_LoopLanes
Xoodoo_OverwriteWithZeroes_Bytes:
    ands    r1, #3
    beq     Xoodoo_OverwriteWithZeroes_Exit
Xoodoo_OverwriteWithZeroes_LoopBytes:
    strb    r3, [r0], #1
    subs    r1, r1, #1
    bne     Xoodoo_OverwriteWithZeroes_LoopBytes
Xoodoo_OverwriteWithZeroes_Exit:
    bx      lr
    .align  4


@ ----------------------------------------------------------------------------
@
@  void Xoodoo_ExtractBytes(Xoodoo_plain32_state *state, const unsigned char *data, unsigned int offset, unsigned int length)
@
.global Xoodoo_ExtractBytes
.type	Xoodoo_ExtractBytes, %function;
Xoodoo_ExtractBytes:
    adds    r0, r0, r2                              @ state += offset
    subs    r3, r3, #4                              @ .if length >= 4
    bcc     Xoodoo_ExtractBytes_Bytes
Xoodoo_ExtractBytes_LanesLoop:                       @ then, handle words
    ldr     r2, [r0], #4
    str     r2, [r1], #4
    subs    r3, r3, #4
    bcs     Xoodoo_ExtractBytes_LanesLoop
Xoodoo_ExtractBytes_Bytes:
    adds    r3, r3, #3
    bcc     Xoodoo_ExtractBytes_Exit
Xoodoo_ExtractBytes_BytesLoop:
    ldrb    r2, [r0], #1
    strb    r2, [r1], #1
    subs    r3, r3, #1
    bcs     Xoodoo_ExtractBytes_BytesLoop
Xoodoo_ExtractBytes_Exit:
    bx      lr
    .align  4


@ ----------------------------------------------------------------------------
@
@  void Xoodoo_ExtractAndAddBytes(Xoodoo_plain32_state *state, const unsigned char *input, unsigned char *output, unsigned int offset, unsigned int length)
@
.global Xoodoo_ExtractAndAddBytes
.type	Xoodoo_ExtractAndAddBytes, %function;
Xoodoo_ExtractAndAddBytes:
    push    {r4,r5}
    adds    r0, r0, r3                                  @ state += offset (offset register no longer needed, reuse for length)
    ldr     r3, [sp, #8]                                @ get length argument from stack
    subs    r3, r3, #4                                  @ .if length >= 4
    bcc     Xoodoo_ExtractAndAddBytes_Bytes
Xoodoo_ExtractAndAddBytes_LanesLoop:                     @ then, handle words
    ldr     r5, [r0], #4
    ldr     r4, [r1], #4
    eors    r5, r5, r4
    str     r5, [r2], #4
    subs    r3, r3, #4
    bcs     Xoodoo_ExtractAndAddBytes_LanesLoop
Xoodoo_ExtractAndAddBytes_Bytes:
    adds    r3, r3, #3
    bcc     Xoodoo_ExtractAndAddBytes_Exit
Xoodoo_ExtractAndAddBytes_BytesLoop:
    ldrb    r5, [r0], #1
    ldrb    r4, [r1], #1
    eors    r5, r5, r4
    strb    r5, [r2], #1
    subs    r3, r3, #1
    bcs     Xoodoo_ExtractAndAddBytes_BytesLoop
Xoodoo_ExtractAndAddBytes_Exit:
    pop     {r4,r5}
    bx      lr
    .align  4


@ ----------------------------------------------------------------------------

.equ _r0   , 5
.equ _r1   , 14
.equ _t3   , 1

.equ _w1   , 11

.equ _e0   , 2
.equ _e1   , 8

.equ _rc12 , 0x00000058
.equ _rc11 , 0x00000038
.equ _rc10 , 0x000003C0
.equ _rc9  , 0x000000D0
.equ _rc8  , 0x00000120
.equ _rc7  , 0x00000014
.equ _rc6  , 0x00000060
.equ _rc5  , 0x0000002C
.equ _rc4  , 0x00000380
.equ _rc3  , 0x000000F0
.equ _rc2  , 0x000001A0
.equ _rc1  , 0x00000012

.equ _rc6x1, 0x00000003
.equ _rc5x2, 0x0b000000
.equ _rc4x3, 0x07000000
.equ _rc3x4, 0x000f0000
.equ _rc2x5, 0x0000d000
.equ _rc1x6, 0x00000048

.equ _rc12x1, 0xc0000002
.equ _rc11x2, 0x0e000000
.equ _rc10x3, 0x07800000
.equ _rc9x4 , 0x000d0000
.equ _rc8x5 , 0x00009000
.equ _rc7x6 , 0x00000050
.equ _rc6x7 , 0x0000000c
.equ _rc5x8 , 0x2c000000
.equ _rc4x9 , 0x1c000000
.equ _rc3x10, 0x003c0000
.equ _rc2x11, 0x00034000
.equ _rc1x12, 0x00000120

@ ----------------------------------------------------------------------------

.macro    mXor3   ro, a0, a1, a2, rho_e1, rho_e2
    .if ((\rho_e1)%32) == 0
    eors    \ro, \a0, \a1
    .else
    eor     \ro, \a0, \a1, ROR #(32-(\rho_e1))%32
    .endif
    .if ((\rho_e2)%32) == 0
    eors    \ro, \ro, \a2
    .else
    eor     \ro, \ro, \a2, ROR #(32-(\rho_e2))%32
    .endif
    .endm

.macro    mRliXor ro, ri, rot
    .if ((\rot)%32) == 0
    eors    \ro, \ro, \ri
    .else
    eor     \ro, \ro, \ri, ROR #(32-(\rot))%32
    .endif
    .endm

.macro    mRloXor ro, ri, rot
    .if ((\rot)%32) == 0
    eors    \ro, \ro, \ri
    .else
    eor     \ro, \ri, \ro, ROR #(32-(\rot))%32
    .endif
    .endm

.macro    mChi3   a0,a1,a2,r0,r1
    bic     \r0, \a2, \a1, ROR #_w1
    eors    \a0, \a0, \r0, ROR #32-_w1
    bic     \r1, \a0, \a2, ROR #32-_w1
    eors    \a1, \a1, \r1
    bic     \r1, \a1, \a0
    eors    \a2, \a2, \r1, ROR #_w1
    .endm

.macro    mRound  r6i, r7i, r8i, r9i, r6w, r7w, r8w, r9w, r10i, r11i, r12i, lri, rho_e1, rho_we2, rc

    @ Theta: Column Parity Mixer (with late Rho-west, Rho-east bit rotations)
    mXor3   r0, r5, \r9i, \lri, \rho_e1, \rho_we2
    mXor3   r1, r2, \r6i, \r10i, \rho_e1, \rho_we2
    mRliXor r0, r0, _r1-_r0
    mRloXor r2, r0, 32-_r0
    mRloXor \r6i, r0, \rho_e1-_r0
    mRloXor \r10i, r0, \rho_we2-_r0

    mXor3   r0, r3, \r7i, \r11i, \rho_e1, \rho_we2
    mRliXor r1, r1, _r1-_r0
    mRloXor r3, r1, 32-_r0
    mRloXor \r7i, r1, \rho_e1-_r0
    mRloXor \r11i, r1, \rho_we2-_r0

    mXor3   r1, r4, \r8i, \r12i, \rho_e1, \rho_we2
    mRliXor r0, r0, _r1-_r0
    mRloXor r4, r0, 32-_r0
    mRloXor \r8i, r0, \rho_e1-_r0
    mRloXor \r12i, r0, \rho_we2-_r0

    mRliXor r1, r1, _r1-_r0
    mRloXor r5, r1, 32-_r0
    mRloXor \r9i, r1, \rho_e1-_r0
    mRloXor \lri, r1, \rho_we2-_r0
    @ After Theta the whole state is rotated -r0
    @ from here we must use a1.w instead of a1.i

    @ Iota: round constant
    .if      \rc == 0xc0000002
    eor     r2, r2, #0x00000002
    eor     r2, r2, #0xc0000000
    .else
    eor     r2, r2, #\rc
    .endif

    @ Chi: non linear step, on colums
    mChi3   r2, \r6w, \r10i, r0, r1
    mChi3   r3, \r7w, \r11i, r0, r1
    mChi3   r4, \r8w, \r12i, r0, r1
    mChi3   r5, \r9w, \lri, r0, r1
    .endm

@ ----------------------------------------------------------------------------
@
@  void Xoodoo_Permute_6rounds( Xoodoo_plain32_state *state )
@
.global Xoodoo_Permute_6rounds
.type	Xoodoo_Permute_6rounds, %function;
Xoodoo_Permute_6rounds:
    push    {r0,r4-r11,lr}
    ldmia   r0!, {r2-r5}
    ldmia   r0!, {r8-r9}
    ldmia   r0!, {r6-r7}
    ldmia   r0, {r10-r12,lr}
    mRound  r8, r9, r6, r7,    r7, r8, r9, r6,    r10, r11, r12, lr,   32,      32, _rc6x1
    mRound  r7, r8, r9, r6,    r6, r7, r8, r9,    r12, lr, r10, r11,    1, _e1+_w1, _rc5x2
    mRound  r6, r7, r8, r9,    r9, r6, r7, r8,    r10, r11, r12, lr,    1, _e1+_w1, _rc4x3
    mRound  r9, r6, r7, r8,    r8, r9, r6, r7,    r12, lr, r10, r11,    1, _e1+_w1, _rc3x4
    mRound  r8, r9, r6, r7,    r7, r8, r9, r6,    r10, r11, r12, lr,    1, _e1+_w1, _rc2x5
    mRound  r7, r8, r9, r6,    r6, r7, r8, r9,    r12, lr, r10, r11,    1, _e1+_w1, _rc1x6
    pop     {r0,r1}
    ror     r2, r2, #32-(6*_r0)%32
    ror     r3, r3, #32-(6*_r0)%32
    ror     r4, r4, #32-(6*_r0)%32
    ror     r5, r5, #32-(6*_r0)%32
    ror     r6, r6, #32-(6*_r0+1)%32
    ror     r7, r7, #32-(6*_r0+1)%32
    ror     r8, r8, #32-(6*_r0+1)%32
    ror     r9, r9, #32-(6*_r0+1)%32
    ror     r10, r10, #32-(6*_r0+_e1+_w1)%32
    ror     r11, r11, #32-(6*_r0+_e1+_w1)%32
    ror     r12, r12, #32-(6*_r0+_e1+_w1)%32
    ror     lr, lr, #32-(6*_r0+_e1+_w1)%32
    stmia   r0, {r2-r12,lr}
    mov     r4, r1
    pop     {r5-r11,pc}
    .align  4


@ ----------------------------------------------------------------------------
@
@  void Xoodoo_Permute_12rounds( Xoodoo_plain32_state *state )
@
.global Xoodoo_Permute_12rounds
.type	Xoodoo_Permute_12rounds, %function;
Xoodoo_Permute_12rounds:
    push    {r0,r4-r11,lr}
    ldmia   r0, {r2-r12,lr}
    mRound  r6, r7, r8, r9,    r9, r6, r7, r8,    r10, r11, r12, lr,   32,      32, _rc12x1
    mRound  r9, r6, r7, r8,    r8, r9, r6, r7,    r12, lr, r10, r11,    1, _e1+_w1, _rc11x2
    mRound  r8, r9, r6, r7,    r7, r8, r9, r6,    r10, r11, r12, lr,    1, _e1+_w1, _rc10x3
    mRound  r7, r8, r9, r6,    r6, r7, r8, r9,    r12, lr, r10, r11,    1, _e1+_w1, _rc9x4
    mRound  r6, r7, r8, r9,    r9, r6, r7, r8,    r10, r11, r12, lr,    1, _e1+_w1, _rc8x5
    mRound  r9, r6, r7, r8,    r8, r9, r6, r7,    r12, lr, r10, r11,    1, _e1+_w1, _rc7x6
    mRound  r8, r9, r6, r7,    r7, r8, r9, r6,    r10, r11, r12, lr,    1, _e1+_w1, _rc6x7
    mRound  r7, r8, r9, r6,    r6, r7, r8, r9,    r12, lr, r10, r11,    1, _e1+_w1, _rc5x8
    mRound  r6, r7, r8, r9,    r9, r6, r7, r8,    r10, r11, r12, lr,    1, _e1+_w1, _rc4x9
    mRound  r9, r6, r7, r8,    r8, r9, r6, r7,    r12, lr, r10, r11,    1, _e1+_w1, _rc3x10
    mRound  r8, r9, r6, r7,    r7, r8, r9, r6,    r10, r11, r12, lr,    1, _e1+_w1, _rc2x11
    mRound  r7, r8, r9, r6,    r6, r7, r8, r9,    r12, lr, r10, r11,    1, _e1+_w1, _rc1x12
    ror     r2, r2, #32-(12*_r0)%32
    ror     r3, r3, #32-(12*_r0)%32
    ror     r4, r4, #32-(12*_r0)%32
    ror     r5, r5, #32-(12*_r0)%32
    ror     r6, r6, #32-(12*_r0+1)%32
    ror     r7, r7, #32-(12*_r0+1)%32
    ror     r8, r8, #32-(12*_r0+1)%32
    ror     r9, r9, #32-(12*_r0+1)%32
    ror     r10, r10, #32-(12*_r0+_e1+_w1)%32
    ror     r11, r11, #32-(12*_r0+_e1+_w1)%32
    ror     r12, r12, #32-(12*_r0+_e1+_w1)%32
    ror     lr, lr, #32-(12*_r0+_e1+_w1)%32
    pop     {r0,r1}
    stmia   r0, {r2-r12,lr}
    mov     r4, r1
    pop     {r5-r11,pc}
    .align  4


.equ Xoofff_BlockSize   , 3*4*4

@ ----------------------------------------------------------------------------
@
@ void Xoofff_AddIs(BitSequence *output, const BitSequence *input, BitLength bitLen)
.global Xoofff_AddIs
.type	Xoofff_AddIs, %function;
Xoofff_AddIs:
    push    {r4-r10,lr}

    subs    r2, r2, #Xoofff_BlockSize*8
    bcc     Xoofff_AddIs_LessThanBlock
Xoofff_AddIs_BlockLoop:
    ldr     r3, [r0, #0]
    ldr     r4, [r0, #4]
    ldr     r5, [r0, #8]
    ldr     r6, [r0, #12]
    ldr     r7, [r1], #4
    ldr     r8, [r1], #4
    ldr     r9, [r1], #4
    ldr     r10, [r1], #4
    eor     r3, r3, r7
    eor     r4, r4, r8
    eor     r5, r5, r9
    eor     r6, r6, r10
    str     r3, [r0], #4
    str     r4, [r0], #4
    str     r5, [r0], #4
    str     r6, [r0], #4

    ldr     r3, [r0, #0]
    ldr     r4, [r0, #4]
    ldr     r5, [r0, #8]
    ldr     r6, [r0, #12]
    ldr     r7, [r1], #4
    ldr     r8, [r1], #4
    ldr     r9, [r1], #4
    ldr     r10, [r1], #4
    eor     r3, r3, r7
    eor     r4, r4, r8
    eor     r5, r5, r9
    eor     r6, r6, r10
    str     r3, [r0], #4
    str     r4, [r0], #4
    str     r5, [r0], #4
    str     r6, [r0], #4

    ldr     r3, [r0, #0]
    ldr     r4, [r0, #4]
    ldr     r5, [r0, #8]
    ldr     r6, [r0, #12]
    ldr     r7, [r1], #4
    ldr     r8, [r1], #4
    ldr     r9, [r1], #4
    ldr     r10, [r1], #4
    eor     r3, r3, r7
    eor     r4, r4, r8
    eor     r5, r5, r9
    eor     r6, r6, r10
    str     r3, [r0], #4
    str     r4, [r0], #4
    str     r5, [r0], #4
    str     r6, [r0], #4

    subs    r2, r2, #Xoofff_BlockSize*8
    bcs     Xoofff_AddIs_BlockLoop
Xoofff_AddIs_LessThanBlock:
    adds    r2, r2, #Xoofff_BlockSize*8
    beq     Xoofff_AddIs_Return
    subs    r2, r2, #16*8
    bcc     Xoofff_AddIs_LessThan16
Xoofff_AddIs_16Loop:
    ldr     r3, [r0, #0]
    ldr     r4, [r0, #4]
    ldr     r5, [r0, #8]
    ldr     r6, [r0, #12]
    ldr     r7, [r1], #4
    ldr     r8, [r1], #4
    ldr     r9, [r1], #4
    ldr     r10, [r1], #4
    eor     r3, r3, r7
    eor     r4, r4, r8
    eor     r5, r5, r9
    eor     r6, r6, r10
    str     r3, [r0], #4
    str     r4, [r0], #4
    str     r5, [r0], #4
    str     r6, [r0], #4
    subs    r2, r2, #16*8
    bcs     Xoofff_AddIs_16Loop
Xoofff_AddIs_LessThan16:
    adds    r2, r2, #16*8
    beq     Xoofff_AddIs_Return
    subs    r2, r2, #4*8
    bcc     Xoofff_AddIs_LessThan4
Xoofff_AddIs_4Loop:
    ldr     r3, [r0]
    ldr     r7, [r1], #4
    eors    r3, r3, r7
    str     r3, [r0], #4
    subs    r2, r2, #4*8
    bcs     Xoofff_AddIs_4Loop
Xoofff_AddIs_LessThan4:
    adds    r2, r2, #4*8
    beq     Xoofff_AddIs_Return
    subs    r2, r2, #8
    bcc     Xoofff_AddIs_LessThan1
Xoofff_AddIs_1Loop:
    ldrb    r3, [r0]
    ldrb    r7, [r1], #1
    eors    r3, r3, r7
    strb    r3, [r0], #1
    subs    r2, r2, #8
    bcs     Xoofff_AddIs_1Loop
Xoofff_AddIs_LessThan1:
    adds    r2, r2, #8
    beq     Xoofff_AddIs_Return
    ldrb    r3, [r0]
    ldrb    r7, [r1]
    movs    r1, #1
    eors    r3, r3, r7
    lsls    r1, r1, r2
    subs    r1, r1, #1
    ands    r3, r3, r1
    strb    r3, [r0]
Xoofff_AddIs_Return:
    pop     {r4-r10,pc}
    .align  4


@ ----------------------------------------------------------------------------
@
@ size_t Xoofff_CompressFastLoop(unsigned char *kRoll, unsigned char *xAccu, const unsigned char *input, size_t length)
@
.equ Xoofff_Compress_kRoll  , 0
.equ Xoofff_Compress_input  , 4
.equ Xoofff_Compress_xAccu  , 8
.equ Xoofff_Compress_iInput , 12
.equ Xoofff_Compress_length , 16

.global Xoofff_CompressFastLoop
.type	Xoofff_CompressFastLoop, %function;
Xoofff_CompressFastLoop:
    subs    r3, #Xoofff_BlockSize       @ length must be greater than block size
    push    {r1-r12,lr}
    push    {r0,r2}
    ldmia   r0, {r2-r12,lr}           @ get initial kRoll
Xoofff_CompressFastLoop_Loop:
    ldr     r0, [sp, #Xoofff_Compress_input]    @ add input
    ldr     r1, [r0], #4
    eors    r2, r2, r1
    ldr     r1, [r0], #4
    eors    r3, r3, r1
    ldr     r1, [r0], #4
    eors    r4, r4, r1
    ldr     r1, [r0], #4
    eors    r5, r5, r1

    ldr     r1, [r0], #4
    eors    r6, r6, r1
    ldr     r1, [r0], #4
    eors    r7, r7, r1
    ldr     r1, [r0], #4
    eors    r8, r8, r1
    ldr     r1, [r0], #4
    eors    r9, r9, r1

    ldr     r1, [r0], #4
    eors    r10, r10, r1
    ldr     r1, [r0], #4
    eors    r11, r11, r1
    ldr     r1, [r0], #4
    eors    r12, r12, r1
    ldr     r1, [r0], #4
    eors    lr, lr, r1
    str     r0, [sp, #Xoofff_Compress_input]

    @ permutation
    mRound  r6, r7, r8, r9,    r9, r6, r7, r8,    r10, r11, r12, lr,   32,      32, _rc6x1
    mRound  r9, r6, r7, r8,    r8, r9, r6, r7,    r12, lr, r10, r11,    1, _e1+_w1, _rc5x2
    mRound  r8, r9, r6, r7,    r7, r8, r9, r6,    r10, r11, r12, lr,    1, _e1+_w1, _rc4x3
    mRound  r7, r8, r9, r6,    r6, r7, r8, r9,    r12, lr, r10, r11,    1, _e1+_w1, _rc3x4
    mRound  r6, r7, r8, r9,    r9, r6, r7, r8,    r10, r11, r12, lr,    1, _e1+_w1, _rc2x5
    mRound  r9, r6, r7, r8,    r8, r9, r6, r7,    r12, lr, r10, r11,    1, _e1+_w1, _rc1x6

    @ Extract and add into xAccu
    ldr     r0, [sp, #Xoofff_Compress_xAccu]
    ldr     r1, [r0]
    mRloXor r2, r1, (6*_r0)%32
    ldr     r1, [r0, #4]

    str     r2, [r0], #4
    mRloXor r3, r1, (6*_r0)%32
    ldr     r1, [r0, #4]

    str     r3, [r0], #4
    mRloXor r4, r1, (6*_r0)%32
    ldr     r1, [r0, #4]

    str     r4, [r0], #4
    mRloXor r5, r1, (6*_r0)%32
    str     r5, [r0], #4

    ldm     r0, {r2-r5}    @ note that r6-r8 and r7-r9 are swapped
    mRliXor r2, r8, (6*_r0+1)%32
    mRliXor r3, r9, (6*_r0+1)%32
    mRliXor r4, r6, (6*_r0+1)%32
    mRliXor r5, r7, (6*_r0+1)%32
    stm     r0!, {r2-r5}

    ldm     r0, {r2-r5}
    mRliXor r2, r10, (6*_r0+_e1+_w1)%32
    mRliXor r3, r11, (6*_r0+_e1+_w1)%32
    mRliXor r4, r12, (6*_r0+_e1+_w1)%32
    mRliXor r5, lr, (6*_r0+_e1+_w1)%32
    stm     r0!, {r2-r5}

    @roll kRoll
    ldr     r0, [sp, #Xoofff_Compress_kRoll]
    ldr     lr, [r0], #4
    ldmia   r0!, {r10-r12}
    ldmia   r0!, {r2-r9}
    eors    lr, lr, lr, LSL #13
    eors    lr, lr, r2, ROR #32-3
    sub     r0, #Xoofff_BlockSize
    stmia   r0, {r2-r12,lr}
    @ loop management
    ldr     r0, [sp, #Xoofff_Compress_length]
    subs    r0, #Xoofff_BlockSize
    str     r0, [sp, #Xoofff_Compress_length]
    bcs     Xoofff_CompressFastLoop_Loop
    @ return number of bytes processed
    ldr     r0, [sp, #Xoofff_Compress_input]
    ldr     r1, [sp, #Xoofff_Compress_iInput]
    sub     r0, r0, r1
    pop     {r1,r2}
    pop     {r1-r12,pc}
    .align  4


@ ----------------------------------------------------------------------------
@
@ size_t Xoofff_ExpandFastLoop(unsigned char *yAccu, const unsigned char *kRoll, unsigned char *output, size_t length)
@
.equ Xoofff_Expand_yAccu    , 0
.equ Xoofff_Expand_output   , 4
.equ Xoofff_Expand_kRoll    , 8
.equ Xoofff_Expand_iOutput  , 12
.equ Xoofff_Expand_length   , 16

.global Xoofff_ExpandFastLoop
.type	Xoofff_ExpandFastLoop, %function;
Xoofff_ExpandFastLoop:
    subs    r3, #Xoofff_BlockSize    @ length must be greater than block size
    push    {r1-r12,lr}
    push    {r0,r2}
    ldmia   r0, {r2-r12,lr}       @ get initial yAccu
Xoofff_ExpandFastLoop_Loop:
    @ permutation
    mRound  r6, r7, r8, r9,    r9, r6, r7, r8,    r10, r11, r12, lr,   32,      32, _rc6x1
    mRound  r9, r6, r7, r8,    r8, r9, r6, r7,    r12, lr, r10, r11,    1, _e1+_w1, _rc5x2
    mRound  r8, r9, r6, r7,    r7, r8, r9, r6,    r10, r11, r12, lr,    1, _e1+_w1, _rc4x3
    mRound  r7, r8, r9, r6,    r6, r7, r8, r9,    r12, lr, r10, r11,    1, _e1+_w1, _rc3x4
    mRound  r6, r7, r8, r9,    r9, r6, r7, r8,    r10, r11, r12, lr,    1, _e1+_w1, _rc2x5
    mRound  r9, r6, r7, r8,    r8, r9, r6, r7,    r12, lr, r10, r11,    1, _e1+_w1, _rc1x6

    @ Add k and extract
    ldr     r0, [sp, #Xoofff_Expand_kRoll]
    ldr     r1, [r0], #4
    mRloXor r2, r1, (6*_r0)%32

    ldr     r1, [sp, #Xoofff_Expand_output]
    str     r2, [r1], #4

    ldr     r2, [r0], #4
    mRloXor r3, r2, (6*_r0)%32
    ldr     r2, [r0], #4

    str     r3, [r1], #4
    mRloXor r4, r2, (6*_r0)%32
    ldr     r2, [r0], #4

    str     r4, [r1], #4
    mRloXor r5, r2, (6*_r0)%32
    str     r5, [r1], #4

    ldm     r0!, {r2-r5}       @ Note that r6-r8 and r7-r9 are swapped
    mRliXor r2, r8, (6*_r0+1)%32
    str     r2, [r1], #4
    mRliXor r3, r9, (6*_r0+1)%32
    str     r3, [r1], #4
    mRliXor r4, r6, (6*_r0+1)%32
    str     r4, [r1], #4
    mRliXor r5, r7, (6*_r0+1)%32
    str     r5, [r1], #4

    ldm     r0!, {r2-r5}
    mRliXor r2, r10, (6*_r0+_e1+_w1)%32
    str     r2, [r1], #4
    mRliXor r3, r11, (6*_r0+_e1+_w1)%32
    str     r3, [r1], #4
    mRliXor r4, r12, (6*_r0+_e1+_w1)%32
    str     r4, [r1], #4
    mRliXor r5, lr, (6*_r0+_e1+_w1)%32
    str     r5, [r1], #4

    @ roll-e yAccu
    ldr     r0, [sp, #Xoofff_Expand_yAccu]
    str     r1, [sp, #Xoofff_Expand_output]
    ldr     lr, [r0], #4
    ldmia   r0!, {r10-r12}
    ldmia   r0!, {r2-r9}
    and     r1, r6, r2
    eor     lr, r1, lr, ROR #32-5
    eor     lr, lr, r2, ROR #32-13
    eor     lr, lr, #7
    sub     r0, #Xoofff_BlockSize
    stmia   r0, {r2-r12,lr}
    @ loop management
    ldr     r0, [sp, #Xoofff_Expand_length]
    subs    r0, #Xoofff_BlockSize
    str     r0, [sp, #Xoofff_Expand_length]
    bcs     Xoofff_ExpandFastLoop_Loop
    @ return number of bytes processed
    ldr     r0, [sp, #Xoofff_Expand_output]
    ldr     r1, [sp, #Xoofff_Expand_iOutput]
    sub     r0, r0, r1
    pop     {r1,r2}
    pop     {r1-r12,pc}
    .align  4


