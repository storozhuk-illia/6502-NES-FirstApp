# 6502 NES First Application

### Tools:

- Assembler: [cc65](https://cc65.github.io/)
- Emulator: [Nintaco](https://nintaco.com/)

### Build:
ca65 src\main.6502.asm

ca65 src\reset.6502.asm

ld65 src\reset.6502.o src\main.6502.o -C nes.cfg -o main.6502.nes