global start

section.text
bits 32
start:
    ; Set up stack
    mov esp, stack_top

    ; Check if we are executing in a multiboot environment
    call check_multiboot

    ; Check if cpuid is available
    call check_cpuid

    ; Check if long mode is available
    call check_longmode


; Check if we are booting via multiboot
check_multiboot:
    cmp eax, 0x36d76289
    jne .no_multiboot
    ret
.no_multiboot
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
.no_a20
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
.no_cpuid
    mv al, "2"
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
    mv al, "3"
    call err

; Error function that prints out Er: then the value of al
err:
    mov dword [0xb8000], 0x4f724f45
    mov dword [0xb8004], 0x4f204f3a
    mov byte  [0xb8008], al
    hlt

section .bss
align 4096
; Set up space for 
p4_pt:
    resb 4096
; Reserve 128 bytes for our tiny stack
stack_bottom:
    resb 128
stack_top: