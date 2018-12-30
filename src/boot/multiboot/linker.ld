ENTRY(start)

SECTIONS {
    . = 1M;

    .text BLOCK(4k) : {
        KEEP(*(.multiboot_hdr))
        *(.text .text.*)
    }

    .rodata BLOCK(4k) : {
        *(.rodata .rodata.*)
    }

    .data BLOCK(4k) : {
        *(.data .data.*)
    }

    .data.rel.ro BLOCK(4k) : {
        *(.data.rel.ro.local*) *(.data.rel.ro .data.rel.ro.*)
    }

    .gcc_except_table BLOCK(4k) : {
        *(.gcc_except_table .gcc_except_table.*)
    }
}