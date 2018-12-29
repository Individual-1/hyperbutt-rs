# Output info
ARCH ?= x86_64
KERNEL := build/kernel-$(ARCH).bin
ISO := build/os-$(ARCH).iso

# Pointers to existing/intermediate files
KERNEL_RS := target/debug/libhyperbutt-rs.a
LINK_SCRIPT := src/boot/multiboot/linker.ld
GRUB_CFG := src/boot/multiboot/grub.cfg
ASM_SRC_FILES := $(wildcard src/boot/multiboot/*.asm)
ASM_OBJ_FILES := $(patsubst src/boot/multiboot/%.asm, src/boot/multiboot/%.o, $(ASM_SRC_FILES))

all: 
	$(KERNEL)

run:
	$(ISO)
	@qemu-system-x86_64 -s -hda $(ISO)

iso: 
	$(ISO)

$(ISO): 
	$(KERNEL)
	@mkdir -p build/tmp/iso/boot/grub
	@cp $(KERNEL) build/tmp/iso/boot/
	@cp $(GRUB_CFG) build/tmp/iso/boot/grub
	@grub-mkrescue -o $(ISO) build/tmp/iso
	@rm -rf build/tmp/iso

$(KERNEL):
	cargo $(KERNEL_RS) $(ASM_OBJ_FILES) $(LINK_SCRIPT)
	@ld -n --gc-sections -T $(LINKER_SCRIPT) -o $(KERNEL) $()

cargo:
	@cargo xbuild --target x86_64-hyperbutt-rs.json --cfg multiboot="true"

build/boot/multiboot/%.o:
	src/boot/multiboot/%.asm
	@mkdir -p $(shell dirname $@)
	@nasm -felf64 $< -o $@

clean:
	@rm -rf build