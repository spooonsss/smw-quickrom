header
lorom


!Freespace = $1FFFF7;If you're using Asar <http://www.smwcentral.net/?p=viewthread&t=51349>, set the below define to !True and ignore this one.
!Asar = !False



!False = xkas
!True = asar

macro JML_asar(addr)
autoclean JML <addr>
endmacro
macro JML_xkas(addr)
JML <addr>
endmacro
macro JML(addr)
%JML_!Asar(<addr>)
endmacro

macro free_asar(x)
freecode
endmacro
macro free_xkas(x)
org !Freespace|$800000
db "STAR"
dw Ratlabel1-Ratlabel2-$01
dw Ratlabel1-Ratlabel2-$01^$FFFF
Ratlabel2:
endmacro
macro free()
%free_!Asar(x)
endmacro



;Wiggler INIT: Replace pointless repeated LDAs with XBAs (I'd prefer 16bit mode, but that'd use one byte more than I have).
org $02EFF8
LDY #$00
LDA $E4,x
XBA
LDA $D8,x
-
STA [$D5],y
XBA
INY
BPL -
print pc
warnpc $02F008+1-1
padbyte $EA : pad $02F008



;Wiggler can be made even quicker by removing some MVPs and using a cyclical buffer instead, but I'm lazy.



;Various RAM clearing routines: Replace loops with DMA
macro ClearRAMInit()
LDA.w #$8008
STA $4300
LDA.w #AZero
STA $4302
LDY.b #AZero/65536
STY $4304
LDY.b #$7E
STY $2183
endmacro
macro ClearRAM(start, count)
LDA.w #<start>
STA $2181
LDA.w #<count>
STA $4305
LDY #$01
STY $420B
endmacro

org $808A4E
	assert read1($808A4E) == $22,"You need to initialize ex animation in LM first"
	db $22 ; JSL
	dl read3($808A4E+1)
ClearStack:
REP #$20
SEP #$10
%ClearRAMInit()
LDA #$1100;#$0D80 seems to be enough in SlowROM mode, but I need a bit more in FastROM.
.WasteTime
DEC A
BNE .WasteTime
;I have NO idea why this fixes anything, but I do know that it negates part of the effect of this patch.
;Without this patch, the time taken is 62752 cycles.
;With it, the time taken is 8049 cycles.
;However, this loop eats 20482 cycles, meaning the total is 28531.
%JML(ClearStackFree)
ClearStack_Return:
RTS
warnpc $808A79+1

org $80A1A6
Clear_1A_13D3:
REP #$20
%JML(Clear_1A_13D3_Free)
.Return
SEP #$20
RTS
warnpc $80A1BE+1

org $82AC48
CODE_02AC48:
REP #$20
%JML(CODE_02AC48_Free)
.Return
STZ $143E
SEP #$20
RTS
warnpc $82AC5C+1

org $80A674
CODE_00A674:
REP #$20
%JML(CODE_00A674_Free)
warnpc $80A681+1
org $80A681
.End
SEP #$20

macro originalcodes()
//reset and titlescreen load
//ClearStack:         C2 30         REP #$30                  ; Index (16 bit) Accum (16 bit) 
//CODE_008A50:        A2 FE 1F      LDX.W #$1FFE              
//CODE_008A53:        74 00         STZ $00,X                 
//CODE_008A55:        CA            DEX                       
//CODE_008A56:        CA            DEX                       
//CODE_008A57:        E0 FF 01      CPX.W #$01FF              
//CODE_008A5A:        10 05         BPL CODE_008A61           
//CODE_008A5C:        E0 00 01      CPX.W #$0100              
//CODE_008A5F:        10 F4         BPL CODE_008A55           
//CODE_008A61:        E0 FE FF      CPX.W #$FFFE              
//CODE_008A64:        D0 ED         BNE CODE_008A53           
//CODE_008A66:        A9 00 00      LDA.W #$0000              
//CODE_008A69:        8F 7B 83 7F   STA.L $7F837B             
//CODE_008A6D:        9C 81 06      STZ.W $0681               
//CODE_008A70:        E2 30         SEP #$30                  ; Index (8 bit) Accum (8 bit) 
//CODE_008A72:        A9 FF         LDA.B #$FF                
//CODE_008A74:        8F 7D 83 7F   STA.L $7F837D             
//Return008A78:       60            RTS                       

//ow and cutscene load
//Clear_1A_13D3:      C2 10         REP #$10                  ; 16 bit X,Y ; Index (16 bit) 
//CODE_00A1A8:        E2 20         SEP #$20                  ; 8 bit A ; Accum (8 bit) 
//CODE_00A1AA:        A2 BD 00      LDX.W #$00BD              ; \  
//CODE_00A1AD:        74 1A         STZ RAM_ScreenBndryXLo,X  ;  |Clear RAM addresses $1A-$D7 
//CODE_00A1AF:        CA            DEX                       ;  | 
//CODE_00A1B0:        10 FB         BPL CODE_00A1AD           ; /  
//CODE_00A1B2:        A2 CE 07      LDX.W #$07CE              ; \  
//CODE_00A1B5:        9E D3 13      STZ.W $13D3,X             ;  |Clear RAM addresses $13D3-$1BA1 
//CODE_00A1B8:        CA            DEX                       ;  | 
//CODE_00A1B9:        10 FA         BPL CODE_00A1B5           ; /  
//CODE_00A1BB:        E2 10         SEP #$10                  ; 16 bit X,Y ; Index (8 bit) 
//Return00A1BD:       60            RTS                       ; Return 

//level load
//CODE_02AC48:        C2 10         REP #$10                  ; Index (16 bit) 
//CODE_02AC4A:        A2 7A 02      LDX.W #$027A              
//CODE_02AC4D:        9E 93 16      STZ.W $1693,X             ; clear ram before entering new stage/area 
//CODE_02AC50:        CA            DEX                       
//CODE_02AC51:        10 FA         BPL CODE_02AC4D           
//CODE_02AC53:        E2 10         SEP #$10                  ; Index (8 bit) 
CODE_02AC55:        9C 3E 14      STZ.W RAM_ScrollSprNum    
CODE_02AC58:        9C 3F 14      STZ.W $143F               
Return02AC5B:       60            RTS                       ; Return 

//level load
//CODE_00A674:        A2 23         LDX.B #$23                
//CODE_00A676:        74 70         STZ $70,X                 
//CODE_00A678:        CA            DEX                       
//CODE_00A679:        D0 FB         BNE CODE_00A676           
CODE_00A67B:        A2 37         LDX.B #$37                
CODE_00A67D:        9E D9 13      STZ.W $13D9,X             
CODE_00A680:        CA            DEX                       
CODE_00A681:        D0 FA         BNE CODE_00A67D           
endmacro



;Stripe image uploader: Replace DMA with LDA STA loops since they have shorter setup time
org $80871E
StripeUploader:
;actually I'm too lazy. Setting up a DMA transfer is only 56 cycles anyways.
warnpc $8087AD



;Sprite bouyancy: Replace crappy loop with a lookup table
org $80F04D
PHX
TAX
LDA.l BouyancyTable-$6E,x;this routine only gets called for 6E and higher, no point keeping them around when they're never used
LSR
PLX
RTL



;Level data clearing: Replace slow semi-unrolled STA loop with DMA
org $858074
JMP.w ClearLevelData

warnpc $858089
org $858089
ClearLevelData_Return:

org $8582C8
ClearLevelData:
;This is freespace. Originally it's a long, ugly list of STAs, but replacing it with a nice little DMA makes it both smaller and faster.
;No, you're not supposed to move it. Don't even try.

SEP #$10
REP #$20
LDY #$7E

.Loop
LDA #$C800
STA $2181
STY $2183
LDA #$8008
STA $4300
TYA
CLC
ADC.w #.SourceData-$7E
STA $4302
LDX.b #.SourceData/65536
STX $4304
LDA.w #$3800
STA $4305
LDX #$01
STX $420B
INY
BPL .Loop

JMP.w .Return
.SourceData
dw $0025;This is the tile the entire level is filled with. Do NOT change it to $012F.



BouyancyTable:;The sprite bouyancy boost needs a chunk of freespace, and the above routine frees up a bit, so why not?
AZero:;Yay, data reuse. This one is for the RAM clearing routines.
;   x0  x1  x2  x3  x4  x5  x6  x7  x8  x9  xA  xB  xC  xD  xE  xF
db                                                         $00,$00;6x
db $00,$01,$01,$00,$00,$00,$01,$01,$00,$00,$00,$01,$01,$00,$00,$00;7x
db $00,$01,$00,$00,$00,$00,$01,$00,$00,$00,$01,$01,$00,$00,$00,$01;8x
db $01,$00,$00,$00,$01,$01,$00,$00,$00,$01,$01,$00,$00,$00,$01,$01;9x
db $00,$00,$00,$01,$01,$00,$00,$00,$01,$01,$00,$00,$00,$01,$01,$00;Ax
db $00,$00,$01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00;Bx
db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00;Cx
db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00;Dx
db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00;Ex
db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00;Fx



warnpc $8583AB
%free();Because not everything fits in the above freehole.



ClearStackFree:
%ClearRAM($7E0000, $0100)
%ClearRAM($7E0200, $1E00)
LDA #$0000
STA $7F837B
SEP #$20
DEC A
STA $7F837D
JML ClearStack_Return

CODE_00A674_Free:
%ClearRAMInit()
%ClearRAM($7E0070, $0023+1)
%ClearRAM($7E13D9, $0037+1)
JML CODE_00A674_End

Clear_1A_13D3_Free:
%ClearRAMInit()
%ClearRAM($7E001A, $00BD+1)
%ClearRAM($7E13D3, $07CE+1)
JML Clear_1A_13D3_Return


CODE_02AC48_Free:
%ClearRAMInit()
%ClearRAM($7E1693, $027A+1)
JML CODE_02AC48_Return


Ratlabel1:;unused for !Asar = !True, but it does no harm