#![feature(lang_items, asm)]
#![no_std]

use core::panic::PanicInfo;

/*
Use this for UEFI-only boot functions
#[cfg(feature = "boot-uefi")]

Use this for multiboot-only boot functions
#[cfg(feature = "boot-multiboot")]
*/

// Bring in our bitflags macro
#[macro_use]
extern crate bitfield;

// Panic Handler, we will never return from it, so may as well loop forever
#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
    loop {}
}

// Since we don't have a stdlib, we need to provide the _start symbol
#[no_mangle]
#[cfg(feature = "boot-uefi")]
pub extern "C" fn _start() -> ! {
    loop {}
}

#[no_mangle]
#[cfg(feature = "boot-multiboot")]
pub extern fn multiboot_main(multiboot_address: usize) {
    loop {}
}