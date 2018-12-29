ENTRY(start)

SECTIONS {
    . = 1M;

    .boot :
    {
        *(.multiboot_hdr)
    }

    .text :
    {
        *(.text)
    }
}