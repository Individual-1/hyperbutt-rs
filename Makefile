# Output info
ARCH ?= x86_64
BUILD := debug
KERNEL := build/kernel-$(ARCH).bin
ISO := build/os-$(ARCH).iso

# Pointers to existing/intermediate files
ifeq ($(BUILD),debug)
	RUST_KERNEL := kernel/target/$(ARCH)-hyperbutt-rs/debug/hyperbutt-rs
else
	RUST_KERNEL := kernel/target/$(ARCH)-hyperbutt-rs/release/hyperbutt-rs
endif
LINK_SCRIPT := boot/src/multiboot/linker.ld
GRUB_CFG := boot/src/multiboot/grub.cfg
ASM_SRC_FILES := $(wildcard boot/src/multiboot/*.asm)
ASM_OBJ_FILES := $(patsubst boot/src/multiboot/%.asm, build/boot/multiboot/%.o, $(ASM_SRC_FILES))

all: $(KERNEL)

run: $(ISO)
	@qemu-system-x86_64 -s -hda $(ISO)

iso: $(ISO)

$(ISO): $(KERNEL)
	@mkdir -p build/tmp/iso/boot/grub
	@cp $(KERNEL) build/tmp/iso/boot/
	@cp $(GRUB_CFG) build/tmp/iso/boot/grub
	@grub-mkrescue -o $(ISO) build/tmp/iso
	@rm -rf build/tmp/iso

$(KERNEL): cargo $(ASM_OBJ_FILES) $(LINK_SCRIPT)
	@ld -n --gc-sections -T $(LINK_SCRIPT) -o $(KERNEL) $(ASM_OBJ_FILES) $(RUST_KERNEL)

cargo:
ifeq ($(BUILD),debug)
	@cargo xbuild --manifest-path ./kernel/Cargo.toml --target $(ARCH)-hyperbutt-rs.json --features "boot-multiboot"
else
	@cargo xbuild --manifest-path ./kernel/Cargo.toml --target $(ARCH)-hyperbutt-rs.json --features "boot-multiboot" --release
endif

build/boot/multiboot/%.o: boot/src/multiboot/%.asm
	@mkdir -p $(shell dirname $@)
	@nasm -felf64 $< -o $@

clean:
	@rm -rf build
	@find . -name "target" -type d -exec rm -r {} +
