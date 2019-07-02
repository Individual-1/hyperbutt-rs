use volatile::Volatile;

// VGA text buffer address
const VGA_ADDRESS: usize = 0xb8000;

// Text buffer width and height
const VGA_BUF_WIDTH: usize = 80;
const VGA_BUF_HEIGHT: usize = 25;

// Struct that represents a single character, each is 2 bytes
// See https://en.wikipedia.org/wiki/VGA-compatible_text_mode#Text_buffer for desc
#[repr(C)]
pub struct VGAChar {
    vga_char: u8,
    vga_attr: u8,
}

// Struct that just represents a VGA text buffer of size VGA_BUF_WIDTH x VGA_BUF_HEIGHT
#[repr(transparent)]
struct VGABuffer {
    buf: [ [Volatile<VGAChar>; VGA_BUF_WIDTH]; VGA_BUF_HEIGHT ],
}

// VGA Buffer writer
pub struct VGAWriter {
    col: u8,
    vga_buffer: &'static mut VGABuffer,
}

impl VGAWriter {
    pub fn write_char(&mut self, vga_char: VGAChar) {
        // TODO: row/col tracking logic
        self.vga_buffer.buf[0][0].write(vga_char);
    }
}

// https://stackoverflow.com/questions/45534149/how-can-i-initialize-fields-of-a-struct-in-static-context
lazy_static! {
    pub static ref VGA_WRITER: VGAWriter = VGAWriter {
        col: 0,
        vga_buffer: unsafe { &mut *(VGA_ADDRESS as *mut VGABuffer) },
    };
}