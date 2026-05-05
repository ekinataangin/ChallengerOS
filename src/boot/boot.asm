section .multiboot_header
header_start:
    dd 0xe85250d6                ; Sihirli sayi (Multiboot 2)
    dd 0                         ; Mimari (0 = i386 / 32-bit protected mode)
    dd header_end - header_start ; Header uzunlugu
    ; Checksum
    dd 0x100000000 - (0xe85250d6 + 0 + (header_end - header_start))

    ; Ek etiketler buraya eklenebilir (gerekli değil şimdilik)
    dw 0    ; tip (0 = etiket sonu)
    dw 0    ; bayraklar
    dd 8    ; boyut
header_end:

section .bss
align 4096
p4_table:
    resb 4096
p3_table:
    resb 4096
p2_table:
    resb 4096
stack_bottom:
    resb 4096 * 4
stack_top:

section .rodata
gdt64:
    dq 0 ; Sifir girdisi
.code: equ $ - gdt64
    dq (1<<43) | (1<<44) | (1<<47) | (1<<53) ; Kod segmenti
.pointer:
    dw $ - gdt64 - 1
    dq gdt64

section .text
global start
extern kernel_main

bits 32
start:
    ; Stack point'i ayarla
    mov esp, stack_top

    ; Sayfa tablolarini kur
    call set_up_page_tables
    call enable_paging

    ; 64-bit GDT yukle
    lgdt [gdt64.pointer]

    ; 64-bit kod segmentine atla (Long Mode'a giris)
    jmp gdt64.code:long_mode_start

set_up_page_tables:
    ; P4'un ilk girdisini P3'e bagla
    mov eax, p3_table
    or eax, 0b11 ; present + writable
    mov [p4_table], eax

    ; P3'un ilk girdisini P2'ye bagla
    mov eax, p2_table
    or eax, 0b11 ; present + writable
    mov [p3_table], eax

    ; P2 tablosunu 2MB'lik sayfalarla doldur (İlk 1GB bellegi map ediyoruz)
    mov ecx, 0 ; Dongu sayaci
.map_p2_table:
    mov eax, 0x200000  ; 2MB
    mul ecx            ; eax = 2MB * ecx
    or eax, 0b10000011 ; present + writable + huge (2MB sayfa)
    mov [p2_table + ecx * 8], eax

    inc ecx
    cmp ecx, 512
    jne .map_p2_table

    ret

enable_paging:
    ; P4 tablosunun adresini CR3'e yukle
    mov eax, p4_table
    mov cr3, eax

    ; PAE'yi (Physical Address Extension) aktif et
    mov eax, cr4
    or eax, 1 << 5
    mov cr4, eax

    ; Long Mode'u MSR'den (Model Specific Register) aktif et
    mov ecx, 0xC0000080
    rdmsr
    or eax, 1 << 8
    wrmsr

    ; Paging'i (Sayfalamayi) aktif et
    mov eax, cr0
    or eax, 1 << 31
    mov cr0, eax

    ret

bits 64
long_mode_start:
    ; Diger segment registerlarini (Veri segmentleri) temizle
    mov ax, 0
    mov ss, ax
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    ; C koduna atla
    call kernel_main
    hlt
