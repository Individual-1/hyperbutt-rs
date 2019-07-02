global start
extern longmode_boot

section .text
bits 32
start:
    ; Set up stack
    mov esp, stack_top

    ; Check if we are executing in a multiboot environment
    call check_multiboot

    ; Make sure a20 line is enabled (should be if we booted with multiboot+grub)
    call check_a20

    ; Check if cpuid is available
    call check_cpuid

    ; Check if long mode is available
    call check_longmode

    ; Set up a very basic identity mapping
    call setup_paging

    ; Enable paging
    call enable_paging

    ; Load the gdt64
    lgdt [gdt64.pointer]

    ; Update selectors, doing it here for access to gdt
    mov ax, gdt64.data
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    ; Jump to the long mode setup
    jmp gdt64.code:longmode_boot

; Check if we are booting via multiboot
check_multiboot:
    cmp eax, 0x36d76289
    jne .no_multiboot
    ret
.no_multiboot:
    mov al, "0"
    call err

; Check if the a20 line is enabled, (should be if we are multiboot)
; Taken from osdev.org
check_a20:
    pushad
    mov edi, 0x112345
    mov esi, 0x012345
    mov [esi], esi
    mov [edi], edi
    cmpsd
    popad
    je .no_a20
    ret
; In theory we could just try to enable the a20, but just die for now
.no_a20:
    mov al, "1"
    call err

; Check if our CPU has cpuid enabled, pulled from osdev.org
check_cpuid:
    pushfd
    pop eax
    mov ecx, eax
    xor eax, 1 << 21
    push eax
    popfd
    pushfd
    pop eax
    push ecx
    popfd
    xor eax, ecx
    jz .no_cpuid
    ret
.no_cpuid:
    mov al, "2"
    call err

; Check if long mode is available, pulled from osdev.org
check_longmode:
    mov eax, 0x80000000
    cpuid
    cmp eax, 0x80000001
    jb .no_longmode
    mov eax, 0x80000001
    cpuid
    test edx, 1 << 29
    jz .no_longmode
    ret
.no_longmode:
    mov al, "3"
    call err

; Do fairly minimal identity mapping
setup_paging:
    ; Map pdp into pml4
    mov eax, pdp
    or eax, 0b11 ; Present + Writeable
    mov [pml4], eax

    ; Map first pdp entry to a huge page, ignore the rest of it
    mov dword [pdp], 0b10000011

    ; Map the last entry of pml4 to itself
    mov eax, pml4
    or eax, 0b11
    mov [pml4 + 511 * 8], eax

    ret

; Enable paging
enable_paging:
    ; Put address of pml4 into cr3
    mov eax, pml4
    mov cr3, eax

    ; Enable PAE
    mov eax, cr4
    bts eax, 5
    mov cr4, eax

    ; Set long mode bit in EFER MSR
    mov ecx, 0xC0000080
    rdmsr
    or eax, 1 << 8
    wrmsr

    ; Enable paging
    mov eax, cr0
    or eax, 1 << 31
    mov cr0, eax

    ret

; Error function that prints out Er: then the value of al
err:
    mov dword [0xb8000], 0x4f724f45
    mov dword [0xb8004], 0x4f204f3a
    mov byte  [0xb8008], al
    hlt

section .bss
align 4096
; Set up space for pml4
pml4:
    resb 4096
; Set up space for pdp
pdp:
    resb 4096
; Reserve 128 bytes for our tiny stack
stack_bottom:
    resb 128
stack_top:

section .rodata
; Set up a gdt64 for long mode, from osdev.org/AMD64 arch programmers manual vol 2
gdt64:
.null: equ $ - gdt64
    dw 0xFFFF
    dw 0
    db 0
    db 0
    db 1
    db 0
.code: equ $ - gdt64
    dw 0
    dw 0
    db 0
    db 10011010b
    db 10101111b
    db 0
.data: equ $ - gdt64
    dw 0
    dw 0
    db 0
    db 10010010b
    db 00000000b
    db 0
.pointer:
    dw $ - gdt64 - 1
    dq gdt64
