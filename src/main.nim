import std/[strutils, bitops]

const
    HEADER_SIZE = 0x014f
    BANK_SIZE = 16000

let
    rom = cast[seq[uint8]](readfile("tetris.gb"))
    header = rom[0..HEADER_SIZE]
    rom_size = header[0x0148]

var
    A, B, C, D, E, H, L, F: uint8 = 0
    PC: uint16 = 0x0100
    memory: array[0xffff, uint8]

memory[0..0x3fff] = rom[0..0x3fff]

proc exec(): void =
    case memory[PC]:
        of 0xc3:
            PC = (cast[uint16](memory[PC+2]) shl 8) + memory[PC+1]
            echo "jp ", toHex(PC)
        of 0xaf:
            A = A xor A
            F = 0b1000_0000
            PC += 1
            echo "xor A"
        of 0x21:
            H = memory[PC+2]
            L = memory[PC+1]
            PC += 3
            echo "ld hl, ", toHex(H), toHex(L)
        of 0x0e:
            C = memory[PC+1]
            PC += 2
            echo "ld c, ", toHex(C)
        of 0x32:
            var HL = (cast[uint16](H) shl 8) + L
            memory[HL] = A
            HL -= 1;
            H = cast[uint8](HL shr 8)
            L = cast[uint8](HL)
            PC += 1
            echo "ldd (hl), a: ", toHex(HL)
        of 0x06:
            B = memory[PC+1]
            PC += 2
            echo "ld b, ", toHex(B)
        of 0x05:
            B -= 1
            if B == 0:
                F = bitor(F, 0b1000_0000)
            else:
                F = bitand(F, 0b0111_0000)
                F = bitor(F, 0b0100_0000)
            # do something with H flag
            PC += 1
            echo "dec b: ", toHex(B)
        of 0x20:
            if bitand(F, 0b1000_0000) == 0b0000_0000:
                PC += memory[PC+1]
                echo "jr nz, ", toHex(memory[PC+1]), " TRUE"
            else:
                echo "jr nz, ", toHex(memory[PC+1]), " FALSE"
                PC += 2
        else:
            echo toHex(memory[PC])
            PC += 1

for i in 0..20:
    exec()