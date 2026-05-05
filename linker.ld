ENTRY(start)

SECTIONS
{
    /* Kernel'ı 1 MB adresinden itibaren yüklüyoruz. Bootloader'lar genelde burayı kullanır. */
    . = 1M;

    /* İlk olarak Multiboot başlığımız olmalı ki bootloader onu bulabilsin. */
    .boot :
    {
        KEEP(*(.multiboot_header))
    }

    /* Kod bölümü (.text) */
    .text :
    {
        *(.text)
    }

    /* Salt okunur veri (.rodata) */
    .rodata :
    {
        *(.rodata)
    }

    /* Başlangıç değerine sahip veri (.data) */
    .data :
    {
        *(.data)
    }

    /* Başlangıç değeri olmayan veri (.bss) */
    .bss :
    {
        *(.bss)
    }
}
