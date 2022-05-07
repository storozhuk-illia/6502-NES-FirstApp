.include "constants.inc"
.include "header.inc"

.segment "ZEROPAGE"
player_ship_x: .res 1
player_ship_y: .res 1
player_ship_dir: .res 1
.exportzp player_ship_x, player_ship_y

.segment "CODE"
.proc draw_player
  ; save registers
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

  ; store tile numbers
  LDA #$04
  STA $0201
  STA $0205
  LDA #$05
  STA $0209
  STA $020D

  ; store attributes
  LDA #%00000000
  STA $0202
  STA $020A
  LDA #%01000000
  STA $0206
  STA $020E

  ; store tile locations
  ; top left tile:
  LDA player_ship_y
  STA $0200
  LDA player_ship_x
  STA $0203

  ; top right tile (x + 8):
  LDA player_ship_y
  STA $0204
  LDA player_ship_x
  CLC
  ADC #8
  STA $0207

  ; bottom left tile (y + 8):
  LDA player_ship_y
  CLC
  ADC #8
  STA $0208
  LDA player_ship_x
  STA $020B

  ; bottom right tile (x + 8, y + 8):
  LDA player_ship_y
  CLC
  ADC #8
  STA $020C
  LDA player_ship_x
  CLC
  ADC #8
  STA $020F

  ; restore registers and return
  PLA
  TYA
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc update_player
  ; save registers
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

  LDA player_ship_x
  CMP #240
  BCC not_at_right_edge
  ; if BCC is not taken we are greater than $E0
  LDA #$00
  STA player_ship_dir    ; start moving left
  JMP direction_set ; we already chose a direction,
                    ; so we can skip the left side check
not_at_right_edge:
  LDA player_ship_x
  CMP #1
  BCS direction_set
  ; if BCS not taken, we are less than $10
  LDA #$01
  STA player_ship_dir    ; start moving right
direction_set:
  ; now, actually update player_ship_x
  LDA player_ship_dir
  CMP #$01
  BEQ move_right
  ; if player_ship_dir minus $01 is not zero,
  ; than means player_ship_dir was $00 and
  ; we need to move left
  DEC player_ship_x
  JMP exit_subroutine
move_right:
  INC player_ship_x
exit_subroutine:
  ; restore registers and return
  PLA
  TYA
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc irq_handler
  RTI
.endproc

.proc nmi_handler
  LDA #$00
  STA OAMADDR
  LDA #$02
  STA OAMDMA

  ; update tiles *after* DMA transfer
  JSR update_player
  JSR draw_player

  LDA #$00
  STA $2005
  STA $2005
  RTI
.endproc

.import reset_handler

.export main
.proc main
  ; write a pallete
  LDX PPUSTATUS
  LDX #$3F
  STX PPUADDR
  LDX #$00
  STX PPUADDR
load_palettes:
  LDA palletes, X
  STA PPUDATA
  INX
  CPX #$20
  BNE load_palettes

  ; write nametables
  ; big star
  LDX #$2F

  LDA PPUSTATUS
  LDA #$20
  STA PPUADDR
  LDA #$6B
  STA PPUADDR
  STX PPUDATA

  LDA PPUSTATUS
  LDA #$21
  STA PPUADDR
  LDA #$57
  STA PPUADDR
  STX PPUDATA

  LDA PPUSTATUS
  LDA #$22
  STA PPUADDR
  LDA #$23
  STA PPUADDR
  STX PPUDATA

  LDA PPUSTATUS
  LDA #$23
  STA PPUADDR
  LDA #$52
  STA PPUADDR
  STX PPUDATA

  ; small star 1
  LDX #$2D

  LDA PPUSTATUS
  LDA #$20
  STA PPUADDR
  LDA #$74
  STA PPUADDR
  STX PPUDATA

  LDA PPUSTATUS
  LDA #$21
  STA PPUADDR
  LDA #$43
  STA PPUADDR
  STX PPUDATA

  LDA PPUSTATUS
  LDA #$21
  STA PPUADDR
  LDA #$5D
  STA PPUADDR
  STX PPUDATA

  LDA PPUSTATUS
  LDA #$21
  STA PPUADDR
  LDA #$73
  STA PPUADDR
  STX PPUDATA

  LDA PPUSTATUS
  LDA #$22
  STA PPUADDR
  LDA #$2F
  STA PPUADDR
  STX PPUDATA

  LDA PPUSTATUS
  LDA #$22
  STA PPUADDR
  LDA #$F7
  STA PPUADDR
  STX PPUDATA

  ; small star 2
  LDX #$2E

  LDA PPUSTATUS
  LDA #$20
  STA PPUADDR
  LDA #$F1
  STA PPUADDR
  STX PPUDATA

  LDA PPUSTATUS
  LDA #$21
  STA PPUADDR
  LDA #$A8
  STA PPUADDR
  STX PPUDATA

  LDA PPUSTATUS
  LDA #$22
  STA PPUADDR
  LDA #$7A
  STA PPUADDR
  STX PPUDATA

  LDA PPUSTATUS
  LDA #$23
  STA PPUADDR
  LDA #$44
  STA PPUADDR
  STX PPUDATA

  LDA PPUSTATUS
  LDA #$23
  STA PPUADDR
  LDA #$7C
  STA PPUADDR
  STX PPUDATA

  ; attribute table
  LDA PPUSTATUS
  LDA #$23
  STA PPUADDR
  LDA #$C2
  STA PPUADDR
  LDA #%01000000
  STA PPUDATA

  LDA PPUSTATUS
  LDA #$23
  STA PPUADDR
  LDA #$E0
  STA PPUADDR
  LDA #%00001100
  STA PPUDATA

vblankvait:       ; wait for another vblank before continuing
  BIT PPUSTATUS
  BPL vblankvait

  LDA #%10010000  ; turn on NMIs, sprites use first pattern table
  STA PPUCTRL
  LDA #%00011110  ; turn on screen
  STA PPUMASK

forever:
  JMP forever
.endproc

.segment "VECTORS"
.addr nmi_handler, reset_handler, irq_handler

.segment "RODATA"
palletes:
.byte $0F, $12, $23, $27
.byte $0F, $2B, $3C, $39
.byte $0F, $0C, $07, $13
.byte $0F, $19, $09, $29

.byte $0F, $2D, $10, $15
.byte $0F, $19, $09, $29
.byte $0F, $19, $09, $29
.byte $0F, $19, $09, $29

.segment "CHR"
.incbin "content/starfield.chr"