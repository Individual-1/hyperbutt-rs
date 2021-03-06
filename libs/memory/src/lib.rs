#![feature(lang_items, asm)]
#![no_std]

// Bring in our bitflags macro
#[macro_use]
extern crate bitfield;

pub mod paging;

// 4k pages
pub const PAGE_SIZE: usize = 4096;