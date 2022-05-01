.include "constants.inc"
.include "header.inc"

.segment "CODE"
.proc irq_handler
  RTI
.endproc

.proc nmi_handler
  LDA #$00
  STA OAMADDR
  LDA #$02
  STA OAMDMA
  RTI
.endproc

.import reset_handler

.export main
.proc main
  ; write a pallete
  LDX PPUSTATUS
  LDX #$3f
  STX PPUADDR
  LDX #$00
  STX PPUADDR
load_palettes:
  LDA palletes, X
  STA PPUDATA
  INX
  CPX #$20
  BNE load_palettes
  ; write sprite data
  LDX #$00
load_sprites:
  LDA sprites, X
  STA $0200, X
  INX
  CPX #$10
  BNE load_sprites
vblankvait:       ; wait for another vblank before continuing
  BIT PPUSTATUS
  BPL vblankvait
  LDA #%10010000  ; turn on NMIs, prites use first pattern table
  STA PPUCTRL
  LDA #%00011110  ; turn on screen
  STA PPUMASK
forever:
  JMP forever
.endproc

.segment "VECTORS"
.addr nmi_handler, reset_handler, irq_handler

.segment "CHR"
.incbin "content/graphics.chr"

.segment "RODATA"
palletes:
.byte $29, $19, $09, $0f
.byte $29, $19, $09, $0f
.byte $29, $19, $09, $0f
.byte $29, $19, $09, $0f
.byte $29, $19, $09, $0f
.byte $29, $11, $01, $0f
.byte $29, $10, $00, $0f
.byte $29, $16, $06, $0f
sprites:
.byte $70, $05, $00, $80
.byte $70, $06, $00, $88
.byte $78, $07, $00, $80
.byte $78, $08, $00, $88