section .multiboot

hdr_start:
    dd 0xe85250d6           ; Multiboot2 header magic
    dd 0                    ; Arch number (0 = i386)
    dd hdr_end - hdr_start  ; Length of this header file
    dd 0x100000000 - (0xe85250d6 + 0 + (hdr_end - hdr_start))   ; Checksum

    ; End tag
    dw 0    ; Type
    dw 0    ; Flags
    dd 8    ; Size
hdr_end: