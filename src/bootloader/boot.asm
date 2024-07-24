org 0x7C00
bits 16

%define ENDL 0x0D, 0x0A

;Headers di FAT12 (senza questa parte si sminchia il FAT12 e non si crea l'immagine floppy)

jmp short start
nop

oem:					db 'MSWIN4.1'
bytes_per_sector:		dw 512
sectors_per_cluster:	db 1
reserved_sectors:		dw 1
fat_count:				db 2
dir_entries_count:		dw 0E0h
total_sectors:			dw 2880
media_descriptor_type:	db 0F0h
sectors_per_fat:		dw 9
sectors_per_track:		dw 18
heads:					dw 2
hidden_sectors:			dd 0
large_sector_count:		dd 0

ebr_drive_number:			db 0
							db 0
ebr_signature:				db 29h
ebr_volume_id:				db 12h, 34h, 56h, 78h	
ebr_volume_label:			db 'XanvicOS   '
ebr_system_id:				db 'FAT12   '

;Codice del bootloader

start:
	;Inizializza segmenti di dati

	mov ax, 0
	mov ds, ax
	mov es, ax

	;Iniializza gli stack

	mov ss, ax
	mov sp, 0x7C00

.dopo:

	;Mostra il messaggio di caricamento

	mov si, msg_caricamento
	call puts

	;Legge cose dal floppy

	mov [ebr_drive_number], dl

	;Legge i parametri del disco

	push es
	mov ah, 08h
	int 13h
	jc errore_floppy
	pop es

	and cl, 0x3F
	xor ch, ch
	mov [sectors_per_track], cx

	inc dh
	mov [heads], dh

	;Calcola l'indirizzo LBA della root del filesystem FAT12

	mov ax, [sectors_per_fat]
	mov bl, [fat_count]
	xor bh, bh
	mul bx
	add ax, [reserved_sectors]
	push ax

	;Calcola il peso della root

	mov ax, [sectors_per_fat]
	shl ax, 5
	xor dx, dx
	div word [bytes_per_sector]

	test dx, dx
	jz .root_dopo
	inc ax 

.root_dopo:
	;Legge la root
	mov cl, al
	pop ax
	mov dl, [ebr_drive_number]
	mov bx, buffer
	call lettura_disco

	;Cerca il kernel
	xor bx, bx
	mov di, buffer

.cerca_kernel:
	mov si, file_kernel_bin
	mov cx, 11
	push di
	repe cmpsb
	pop di
	je .kernel_trovato

	add di, 32
	inc bx
	cmp bx, [dir_entries_count]
	jl .cerca_kernel

	;Kernel non trovato
	jmp errore_kernel_non_trovato

.kernel_trovato:
	mov si, msg_kernel_trovato
	call puts

	mov ax, [di + 26]
	mov [kernel_cluster], ax

	mov ax, [reserved_sectors]
	mov bx, buffer 
	mov cl, [sectors_per_fat]
	mov dl, [ebr_drive_number]
	call lettura_disco

	mov bx, KERNEL_LOAD_SEGMENT
	mov es, bx
	mov bx, KERNEL_LOAD_OFFSET

.carica_kernel:
	mov ax, [kernel_cluster]
	add ax, 31

	mov cl, 1
	mov dl, [ebr_drive_number]
	call lettura_disco

	add bx, [bytes_per_sector]

	mov ax, [kernel_cluster]
	mov cx, 3
	mul cx
	mov cx, 2
	div cx

	mov si, buffer
	add si, ax
	mov ax, [ds:si]

	or dx, dx
	jz .pari

.dispari:
	shr ax, 4
	jmp .prossimo_cluster

.pari:
	and ax, 0x0FFF

.prossimo_cluster:
	cmp ax, 0x0FF8
	jae .fine_lettura

	mov [kernel_cluster], ax
	jmp .carica_kernel

.fine_lettura:
	mov dl, [ebr_drive_number]
	
	mov ax, KERNEL_LOAD_SEGMENT
	mov ds, ax
	mov es, ax

	jmp KERNEL_LOAD_SEGMENT:KERNEL_LOAD_OFFSET
	jmp premi_per_riavviare

;Trasforma/Converte un indirizzo LBA in uno CHS

lba_to_chs:
	push ax
	push dx
	
	xor dx, dx
	div word [sectors_per_track]
	
	inc dx
	mov cx, dx

	xor dx, dx
	div word [heads]

	mov dh, dl
	mov ch, al
	shl ah, 6
	or cl, ah

	pop ax
	mov dl, al
	pop ax

	ret

;Legge i settori da un disco

lettura_disco:
	push cx

	call lba_to_chs
	pop ax

	mov ah, 02h
	mov di, 3

.riprova:
	pusha
	stc
	int 13h
	jnc .fine

	;Errore nella lettura del disco
	popa
	call disk_reset

	dec di
	test di, di
	jnz .riprova

.errore:
	jmp errore_floppy

.fine:
	popa

	ret

disk_reset:
	pusha
	mov ah, 0
	stc
	int 13h
	jc errore_floppy
	popa
	ret

puts:
    ;Salva i registri
    push si
    push ax
    push bx

.loop:
    lodsb            
    or al, al           ; verify if next character is n
    jz .fine

    mov ah, 0x0E        ; call bios interrupt
    mov bh, 0           ; set page number to 0
    int 0x10

    jmp .loop

.fine:
    pop bx
    pop ax
    pop si    
    ret

;Mostra delle stringhe sullo schermo

msg_caricamento:
	db 'Caricamento...', ENDL, 0

msg_errore_lettura:
	db 'Errore del disco', ENDL, 0

msg_kernel_non_trovato:
	db 'Kernel non trovato', ENDL, 0

msg_kernel_trovato:
	db 'Kernel trovato', ENDL, 0

;Errori

errore_floppy:
	mov si, msg_errore_lettura
	call puts
	jmp premi_per_riavviare

errore_kernel_non_trovato:
	mov si, msg_kernel_non_trovato
	call puts
	jmp premi_per_riavviare

;Variabili

file_kernel_bin:				db 'KERNEL  BIN'
kernel_cluster:					dw 0
KERNEL_LOAD_SEGMENT 			equ 0x2000
KERNEL_LOAD_OFFSET				equ 0

;Cose che non so dove mettere

premi_per_riavviare:
	mov ah, 0
	int 16h
	jmp 0FFFFh:0 

times 510-($-$$) db 0
dw 0AA55h

buffer:
