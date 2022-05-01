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
  LDA #$29
  STA PPUDATA
  LDA #$19
  STA PPUDATA
  LDA #$09
  STA PPUDATA
  LDA #$0f
  STA PPUDATA
  ; write sprite data
  LDA #$70
  STA $0200       ; Y-coord of first sprite
  LDA #$05
  STA $0201       ; tile number of first sprite
  LDA #$00
  STA $0202       ; attributes of first sprite
  LDA #$80
  STA $0203       ; X-coord of first sprite
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