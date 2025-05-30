; Macro for ISRs without an error code
%macro ISR_NOERRCODE 1
  GLOBAL isr%1        ; Declare the ISR as global
  isr%1:
    ;cli                 ; Clear interrupts
    push byte 0         ; Push a dummy error code
    push byte %1        ; Push the ISR number
    jmp isr_common_stub ; Jump to the common ISR stub
%endmacro

; Macro for ISRs with an error code
%macro ISR_ERRCODE 1
  GLOBAL isr%1        ; Declare the ISR as global
  isr%1:
    ;cli                 ; Clear interrupts
    push byte %1        ; Push the ISR number (error code will be pushed by CPU)
    jmp isr_common_stub ; Jump to the common ISR stub
%endmacro 

; Define ISRs for interrupt vectors 0-31
ISR_NOERRCODE 0
ISR_NOERRCODE 1
ISR_NOERRCODE 2
ISR_NOERRCODE 3
ISR_NOERRCODE 4
ISR_NOERRCODE 5
ISR_NOERRCODE 6
ISR_NOERRCODE 7
ISR_ERRCODE 8   ; Double Fault (has error code)
ISR_NOERRCODE 9
ISR_ERRCODE 10  ; Invalid TSS (has error code)
ISR_ERRCODE 11  ; Segment Not Present (has error code)
ISR_ERRCODE 12  ; Stack Fault (has error code)
ISR_ERRCODE 13  ; General Protection Fault (has error code)
ISR_ERRCODE 14  ; Page Fault (has error code)
ISR_NOERRCODE 15
ISR_NOERRCODE 16
ISR_ERRCODE 17
ISR_NOERRCODE 18
ISR_NOERRCODE 19
ISR_NOERRCODE 20
ISR_NOERRCODE 21
ISR_NOERRCODE 22
ISR_NOERRCODE 23
ISR_NOERRCODE 24
ISR_NOERRCODE 25
ISR_NOERRCODE 26
ISR_NOERRCODE 27
ISR_NOERRCODE 28
ISR_NOERRCODE 29
ISR_ERRCODE 30  ; Security Exception (has error code)
ISR_NOERRCODE 31

EXTERN isr_handler

; Common ISR stub
isr_common_stub:
   pusha                    ; Push all general-purpose registers

   mov ax, ds               ; Save the data segment descriptor
   push eax                 ; Push it onto the stack

   mov ax, 0x10             ; Load the kernel data segment descriptor
   mov ds, ax
   mov es, ax
   mov fs, ax
   mov gs, ax

   call isr_handler         ; Call the C-level ISR handler

   pop eax                  ; Restore the original data segment descriptor
   mov ds, ax
   mov es, ax
   mov fs, ax
   mov gs, ax

   popa                     ; Pop all general-purpose registers
   add esp, 8               ; Clean up the pushed error code and ISR number
   sti                      ; Set interrupts
   iret                     ; Return from interrupt

;IRQ
%macro IRQ 2
  global irq%1
  irq%1:
    ;cli
    push byte 0
    push byte %2
    jmp irq_common_stub
%endmacro

IRQ   0,    32
IRQ   1,    33
IRQ   2,    34
IRQ   3,    35
IRQ   4,    36
IRQ   5,    37
IRQ   6,    38
IRQ   7,    39
IRQ   8,    40
IRQ   9,    41
IRQ  10,    42
IRQ  11,    43
IRQ  12,    44
IRQ  13,    45
IRQ  14,    46
IRQ  15,    47

extern irq_handler

irq_common_stub:
   pusha                    ; Pushes edi,esi,ebp,esp,ebx,edx,ecx,eax

   mov ax, ds               ; Lower 16-bits of eax = ds.
   push eax                 ; save the data segment descriptor

   mov ax, 0x10  ; load the kernel data segment descriptor
   mov ds, ax
   mov es, ax
   mov fs, ax
   mov gs, ax

   call irq_handler

   pop ebx        ; reload the original data segment descriptor
   mov ds, bx
   mov es, bx
   mov fs, bx
   mov gs, bx

   popa                     ; Pops edi,esi,ebp...
   add esp, 8     ; Cleans up the pushed error code and pushed ISR number
   sti
   iret 

