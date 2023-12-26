import std/[strutils]

const
    HEADER_SIZE = 0x014f
    BANK_SIZE = 16000

let
    rom = cast[seq[uint8]](readfile("tetris.gb"))
    header = rom[0..HEADER_SIZE]
    rom_size = header[0x0148]

var
    A, B, C, D, E, H, L: uint8 = 0
    PC: uint16 = 0x0100

proc exec(): void =
    case rom[PC]:
        of 0xc3:
            PC = (cast[uint16](rom[PC+2]) shl 8) + rom[PC+1]
            echo "jp ", toHex(PC)
        of 0xaf:
            A = A xor A
            PC += 1
            echo "xor A"
        of 0x21:
            H = rom[PC+2]
            L = rom[PC+1]
            PC += 3
            echo "ld hl, ", toHex(H), toHex(L)
        of 0x0e:
            C = rom[PC+1]
            PC += 2
            echo "ld c, ", toHex(C)
        else:
            PC += 1
            echo toHex(rom[PC])

for i in 1..10:
    exec()