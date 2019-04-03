// VGA text buffer address
const VGA_ADDRESS: usize = 0xb8000;

// Text buffer width and height
const VGA_BUF_WIDTH: usize = 80;
const VGA_BUF_HEIGHT: usize = 25;

// Struct that represents a single character, each is 2 bytes
// See https://en.wikipedia.org/wiki/VGA-compatible_text_mode#Text_buffer for desc
#[repr(C)]
struct VGAChar {
    vga_char: u8,
    vga_attr: u8,
}

// Struct that just represents a VGA text buffer of size VGA_BUF_WIDTH x VGA_BUF_HEIGHT
struct VGABuffer {
    buffer: [ [VGAChar; VGA_BUF_WIDTH]; VGA_BUF_HEIGHT ],
}

// VGA Buffer writer
pub struct VGAWriter {
    vga_buffer: *mut VGABuffer,
}

impl VGAWriter {

}