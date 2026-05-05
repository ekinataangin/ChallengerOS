#include <stdint.h>
#include <stddef.h>

// VGA text buffer pointer (0xB8000)
volatile uint16_t* vga_buffer = (uint16_t*)0xB8000;
const int VGA_COLS = 80;
const int VGA_ROWS = 25;

int term_col = 0;
int term_row = 0;
uint8_t term_color = 0x0F; // Beyaz yazı, siyah arka plan

void term_clear() {
    for (int col = 0; col < VGA_COLS; col++) {
        for (int row = 0; row < VGA_ROWS; row++) {
            const size_t index = (VGA_COLS * row) + col;
            vga_buffer[index] = ((uint16_t)term_color << 8) | ' ';
        }
    }
}

void term_putc(char c) {
    if (c == '\n') {
        term_col = 0;
        term_row++;
        return;
    }
    
    const size_t index = (VGA_COLS * term_row) + term_col;
    vga_buffer[index] = ((uint16_t)term_color << 8) | c;
    term_col++;
    if (term_col >= VGA_COLS) {
        term_col = 0;
        term_row++;
    }
}

void term_print(const char* str) {
    for (size_t i = 0; str[i] != '\0'; i++) {
        term_putc(str[i]);
    }
}

void kernel_main() {
    term_clear();
    term_print("==================================================\n");
    term_print("        ChallengerOS 64-bit Kernel Baslatildi!    \n");
    term_print("==================================================\n\n");
    term_print("[BILGI] 64-bit Long Mode aktif.\n");
    term_print("[BILGI] C Çekirdegine (Kernel) basariyla gecildi.\n");
    term_print("[BILGI] AI modulleri ve guvenlik katmanlari bekleniyor...\n");

    // Sonsuz döngü (İşletim sisteminin kapanmaması için)
    while (1) {
        // İleride buraya klavye girişleri vb. eklenecek
    }
}
