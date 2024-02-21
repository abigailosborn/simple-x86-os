bits 16 
org 0x7c00

mov si, 0

; AH = 0x0E (opcode?)
; AL = ASCII char to write
; si = counter
print:
	mov ah, 0x0e
	mov al, [hello, si]
	; interrupt to print
	int 0x10
	; increment counter
	add si, 1
	; loop until done printing
	cmp byte[hello + si], 0
	jne print

boot:
	; enable A20 line, allowing
	; us to address more than 1Mb
	; of memory (^_^)
	mov ax, 0x2401
	int 0x15
	; some bullshit idfk (set
	; VGA text mode to 3?)
	mov ax, 0x3
	int 0x10

; setting up the Global Descriptor Table (GDT)
	lgdt [gdt_pointer]
	mov eax, cr0
	; enable protected mode
	or eax, 0x1
	mov cr0, eax
	jmp CODE_SEG:boot2

; defining some *magic* bytes for the GDT?
gdt_start:
	dq 0x0
gdt_code:
	dw 0xFFFF
	dw 0x0
	db 0x0
	db 10011010b
	db 11001111b
	db 0x0
gdt_data:
	dw 0xFFFF
	dw 0x0
	db 0x0
	db 10010010b
	db 11001111b
	db 0x0		
gdt_end:

; make the GDT pointer structure
; layout:
;	  GDT size (16 bits)
;	  GDT ptr  (32 bits)
gdt_pointer:
	dw gdt_end - gdt_start
	dd gdt_start

; define the code and data
; segments of the GDT
CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

; We're In.
bits 32

boot2:
	; set every 16 bit register to
	; point to the GDT's data segment
	mov ax, DATA_SEG
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ss, ax

; using the memory-mapped
; VGA text buffer to write
; text out to the screen
	mov esi, hello
	mov ebx, 0xb8000
.loop:
	lodsb
	or al, al
	jz halt
	or eax, 0x0100
	mov word[ebx], ax
	; increment counter
	add ebx, 2
	jmp .loop
halt:
	cli
	hlt


hello:
	db "Hello, World!", 0
; zero out the rest of the boot sector 
times 510 - ($ - $$) db 0
; * magic *
dw 0xAA55
