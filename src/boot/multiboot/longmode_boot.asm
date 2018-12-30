global longmode_boot
extern multiboot_main

section .text
bits 64

; Upon entering this we have basic identity page mapping and gdt
; Set up SSE extensions for our rust lib
longmode_boot:
    ; Check if SSE is available
    call check_sse

    ; Enable SSE
    call enable_sse

    ; Call our rust entry point
    call multiboot_main

; Check if SSE is available
check_sse:
    mov rax, 1
    cpuid
    test edx, 1<<25
    jz .no_sse
.no_sse:
    mov al "s"
    call err

; Enable SSE
enable_sse:
    mov rax, cr0
    and ax, 0xFFFB
    or ax, 0x2
    mov cr0, rax
    mov rax, cr4
    or ax, 3 << 9
    mov cr4, rax
    ret

; Error function that prints out Er: then the value of al
err:
    mov rbx, 0x4f204f3a4f724f45
    mov [0xb8000], rbx
    mov byte  [0xb8008], al
    hlt