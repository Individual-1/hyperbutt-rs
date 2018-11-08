#![no_std]
#![no_main]

use core::panic::PanicInfo;

// Panic Handler, we will never return from it, so may as well loop forever
#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
    loop {}
}

// Since we don't have a stdlib, we need to provide the _start symbol
#[no_mangle]
pub extern "C" fn _start() -> ! {
    loop {}
}
