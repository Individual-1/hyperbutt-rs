#![feature(no_std, lang_items, asm)]
#![no_std]
#![no_main]

extern crate compiler_builtins;

use core::panic::PanicInfo;

/*
Use this for UEFI-only boot functions
#[cfg(bootloader = "uefi")]

Use this for multiboot-only boot functions
#[cfg(bootloader = "multiboot")]
*/

// Panic Handler, we will never return from it, so may as well loop forever
#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
    loop {}
}

// Since we don't have a stdlib, we need to provide the _start symbol
#[no_mangle]
#[cfg(bootloader = "uefi")]
pub extern "C" fn _start() -> ! {
    loop {}
}

#[no_mangle]
#[cfg(bootloader = "multiboot")]
pub extern fn multiboot_main(multiboot_address: usize) {
    
}