#include <asm/desc.h>

void my_store_idt(struct desc_ptr *idtr) {

    asm volatile("sidt %0" : "=m" (*idtr)); // Store the IDT register into idtr

}

void my_load_idt(struct desc_ptr *idtr) {

    asm volatile("lidt %0" : : "m" (*idtr)); // Load the IDT register from idtr

}

void my_set_gate_offset(gate_desc *gate, unsigned long addr) {

    gate->offset_low = addr & 0xFFFF; // Set the lower 16 bits of the offset
    gate->offset_middle = (addr >> 16) & 0xFFFF; // Set the middle 16 bits of the offset
    gate->offset_high = (addr >> 32) & 0xFFFFFFFF; // Set the upper 32 bits of the offset

}

unsigned long my_get_gate_offset(gate_desc *gate) {

    unsigned long addr = ((unsigned long) gate->offset_low) |
                         ((unsigned long) gate->offset_middle << 16) |
                         ((unsigned long) gate->offset_high << 32);
    return addr;

}
