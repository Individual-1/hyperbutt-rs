use super::PAGE_SIZE;

/*
* We are targeting x64 and thus use a 4 level paging structure
* PML4 -> PDP -> PD -> PT

*/

// With 4k pages, we can fit 512 8 byte entries per page
pub const ENTRY_COUNT: usize = 512;

// Since pml4 is recursively mapped, here is the constant addr to access it
pub const PML4: *mut PageTable = 0xffffffff_fffff000 as  *mut _;

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

// TODO: Come up with some way to specify page table level (pml4, pdp, pd, pt)
pub struct PageTable {
    entries: [Entry; ENTRY_COUNT],
}

impl Index<usize> for PageTable {
    type Output = Entry;

    fn index(&self, index: usize) -> &Entry {
        &self.entries[index]
    }
}

impl IndexMut<usize> for PageTable {
    fn index_mut(&mut self, index: usize) -> &mut Entry {
        &mut self.entries[index]
    }
}

impl PageTable {
    fn get_entry_address(&self, index: usize) -> Option<usize> {
        let entry: Entry = self[index];
        if entry.get_present() && !entry.get_hugepage() {
            let pt_addr = self as *const _ as usize;
            Some((pt_addr << 9) | (index << 12))
        } else {
            None
        }
    }

    // If you call these on pt, bad things will happen. They also require recursively mapped tables
    pub fn get_entry<'a>(&'a self, index: usize) -> Option<&'a PageTable> {
        // Do some weird stuff (address -> raw pointer -> dereference raw pointer and make it a reference)
        self.get_entry_address(index).map(|addr| unsafe { & *(addr as *const _) })
    }

    pub fn get_entry_mut<'a>(&'a self, index: usize) -> Option<&'a mut PageTable> {
        // Do some weird stuff (address -> raw pointer -> dereference raw pointer and make it a reference)
        self.get_entry_address(index).map(|addr| unsafe { &mut *(addr as *mut _) })
    }

}