use memory::PAGE_SIZE;

// With 4k pages, we can fit 512 8 byte entries per page
pub const ENTRY_COUNT: usize = 512;

// Useful aliases
pub type PhysAddress = usize;
pub type VirtAddress = usize;

bitfield! {
    pub struct Entry(u64);
    impl Debug;
    u8;
    get_present, set_present: 1, 0;
    get_writable, set_writable: 2, 1;
    get_useraccess, set_useraccess: 3, 2;
    get_writethru, set_writethru: 4, 3;
    get_disablecache, set_disablecache: 5, 4;
    get_accessed, set_accessed: 6, 5;
    get_dirty, set_dirty: 7, 6;
    get_hugepage, set_hugepage: 8, 7;
    get_global, set_global: 9, 8;
    get_unused1, set_unused1: 12, 9;
    u64, get_physaddr, set_physaddr: 52, 12;
    u8;
    get_unused2, set_unused2: 63, 52;
    get_nx, set_nx: 64, 63;
}

impl<'r> Entry<'r> {
    fn check_unused(&self) -> bool {
        return self.0 as u64 == 0;
    }
}