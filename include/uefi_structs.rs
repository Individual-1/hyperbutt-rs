// UEFI info structures

/* From uefibutt

#define EFI_MAXIMUM_VARIABLE_SIZE   1024

typedef struct {
    EFI_MEMORY_DESCRIPTOR   *memory_map;
    UINT32                  desc_version;
    UINTN                   desc_size;
    UINTN                   map_key;
    UINTN                   num_entries; 
} mem_map_t;

typedef struct {
    UINT16                                  fb_hres; // Horizontal Resolution
    UINT16                                  fb_vres; // Vertical Resolution
    EFI_GRAPHICS_PIXEL_FORMAT               fb_pixfmt;
    EFI_PIXEL_BITMASK                       fb_pixmask; // Currently unused since we don't accept pixelpixelbitmask format
    UINT32                                  fb_pixline;
    EFI_PHYSICAL_ADDRESS                    fb_base;
    UINTN                                   fb_size;
} gfx_info_t;

typedef struct {
    EFI_GRAPHICS_OUTPUT_PROTOCOL_MODE   *gfx_protos;
    UINT64                               num_protos;
} gfx_config_t;

typedef struct {
    EFI_RUNTIME_SERVICES    *rtservice;
    gfx_config_t            *gpu_config;
    mem_map_t               *mem_map;
    void                    *rsdp;
} kernel_args_t;

*/

#[repr(C)]
struct efi_memory_descriptor {
    type:           u32,
    physical_start: u64,
    virtual_start:  u64,
    num_pages:      u64,
    attribute:      u64,
}

#[repr(C)]
struct mem_map_t {
    memory_map:     *efi_memory_descriptor,
    desc_version:   u32,
    desc_size:      u64,
    map_key:        u64,
    num_entries:    u64,
}

#[repr(C)]
enum efi_graphics_pixel_format {
    PixelRedGreenBlueReserved8BitPerColor,
    PixelBlueGreenRedReserved8BitPerColor,
    PixelBitMask,
    PixelBltOnly,
    PixelFormatMax,
}

#[repr(C)]
struct efi_pixel_bitmask {
    red_mask:       u32,
    green_mask:     u32,
    blue_mask:      u32,
    reserved_mask:  u32,
}

#[repr(C)]
struct gfx_info_t {
    fb_hres:    u16,
    fb_vres:    u16,
    fb_pixfmt:  efi_graphics_pixel_format,
    fb_pixmask: efi_pixel_bitmask,
    fb_pixline: u32,
    fb_base:    u64,
    fb_size:    u64,
}
