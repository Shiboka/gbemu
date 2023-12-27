import std/[strutils, bitops]

type
    Flags = object
        Z, N, H, C: bool

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
    flags = Flags(Z: false, N: false, H: false, C: false)
    memory: array[0xffff, uint8]

memory[0..0x3fff] = rom[0..0x3fff]

proc exec(): void =
    case memory[PC]:
        of 0xc3:
            PC = (cast[uint16](memory[PC+2]) shl 8) + memory[PC+1]
            echo "jp ", toHex(PC)
        of 0xaf:
            A = A xor A
            flags.Z = true
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
            flags.N = true

            if bitand(bitand(B, 0xf) - 1, 0x10) == 0x10:
                flags.H = true
            else:
                flags.H = false

            B -= 1
            flags.Z = B == 0
            PC += 1
            echo "dec b: ", toHex(B)
        of 0x20:
            if not flags.Z:
                echo "jr nz, ", toHex(memory[PC+1]), " TRUE"
                PC += memory[PC+1]
            else:
                echo "jr nz, ", toHex(memory[PC+1]), " FALSE"
                PC += 2
        else:
            echo toHex(memory[PC])
            PC += 1

for i in 0..20:
    exec()