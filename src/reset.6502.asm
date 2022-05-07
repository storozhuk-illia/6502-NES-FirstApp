.include "constants.inc"

.segment "ZEROPAGE"
.importzp player_ship_x, player_ship_y

.segment "CODE"
.import main

.export reset_handler
.proc reset_handler
  SEI
  CLD
  LDX #$00
  STX PPUCTRL
  STX PPUMASK
vblankwait:
  BIT PPUSTATUS
  BPL vblankwait

  ; initialize zero-page values
  LDA #190
  STA player_ship_y
  LDA #120
  STA player_ship_x

  JMP main
.endproc