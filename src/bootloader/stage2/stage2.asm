org 0x0
bits 16


%define ENDL 0x0D, 0x0A

;Codice del kernel
start:
    mov si, msg_helloworld
    call puts
	call premi_per_riavviare

.halt:
    cli
    hlt

puts:
    ; save registers we will modify
    push si
    push ax
    push bx

.loop:
    lodsb
    or al, al
    jz .fine

    mov ah, 0x0E
    mov bh, 0
    int 0x10

    jmp .loop

.fine:
    pop bx
    pop ax
    pop si    
    ret

;Stringhe
msg_helloworld: 
	db 'Hello World dallo stage2 del Bootloader!', ENDL, 0

msg_premi_per_riavviare:
	db 'Premi un tasto per riavviare...', ENDL, 0
;Errori

;Variabili

;Cose che non so dove mettere
premi_per_riavviare:
	mov si, msg_premi_per_riavviare
	call puts
	mov ah, 0
	int 16h
	jmp 0FFFFh:0 