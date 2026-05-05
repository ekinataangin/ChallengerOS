# ChallengerOS Makefile

# Derleyiciler
CC = gcc
LD = ld
AS = nasm

# Flagler
CFLAGS = -ffreestanding -O2 -Wall -Wextra -mno-red-zone -fno-pic -no-pie
LDFLAGS = -n -T linker.ld
ASFLAGS = -f elf64

# Dosyalar
KERNEL_OBJ = build/main.o build/boot.o
KERNEL_BIN = dist/kernel.bin
ISO = dist/ChallengerOS.iso

# Rotalar
.PHONY: all clean iso run

all: clean $(KERNEL_BIN) iso

# Klasörleri oluştur
dirs:
	mkdir -p build dist dist/iso/boot/grub

# C Dosyalarını Derle
build/main.o: src/kernel/main.c dirs
	$(CC) $(CFLAGS) -c $< -o $@

# Assembly Dosyalarını Derle
build/boot.o: src/boot/boot.asm dirs
	$(AS) $(ASFLAGS) $< -o $@

# Kernel'i Linkle
$(KERNEL_BIN): $(KERNEL_OBJ)
	$(LD) $(LDFLAGS) -o $@ $(KERNEL_OBJ)

# GRUB ile boot edilebilir ISO oluştur
iso: $(KERNEL_BIN) dirs
	cp $(KERNEL_BIN) dist/iso/boot/kernel.bin
	echo 'set timeout=0' > dist/iso/boot/grub/grub.cfg
	echo 'set default=0' >> dist/iso/boot/grub/grub.cfg
	echo 'menuentry "ChallengerOS" {' >> dist/iso/boot/grub/grub.cfg
	echo '  multiboot2 /boot/kernel.bin' >> dist/iso/boot/grub/grub.cfg
	echo '  boot' >> dist/iso/boot/grub/grub.cfg
	echo '}' >> dist/iso/boot/grub/grub.cfg
	grub-mkrescue -o $(ISO) dist/iso

# QEMU ile çalıştır
run: iso
	qemu-system-x86_64 -cdrom $(ISO)

clean:
	rm -rf build dist
