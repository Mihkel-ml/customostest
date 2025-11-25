org 0x7C00
bits 16

%define ENDL 0x0D, 0x0A

; bios params block fat12 header
jmp short start
nop

bdp_oem: db "MSW1N4.1"        ; 8bytes
bdp_bytes_per_sector: dw 512 ; 2bytes
bdp_sectors_per_cluster: db 1 ; 1byte
bdp_reserved_sectors: dw 1    ; 2bytes
bdp_fat_count: db 2            ; 1byte
bdp_dir_entries_count: dw 0E0h ; 2bytes
bdp_total_sectors: dw 2880 ; 2bytes
bdp_media_descriptor_type: db 0F0h ; 1byte
bdp_sectors_per_fat: dw 9      ; 2bytes
bdp_sectors_per_track: dw 18   ; 2bytes
bdp_head_count: dw 2           ; 2bytes
bdp_hidden_sectors: dd 0       ; 4bytes
bdp_large_sector_count: dd 0     ; 4bytes

; extended boot record
ebr_drive_number: db 0    ; 1byte
                  db 0    ; reserved
ebr_signature:    db 29h ; 1byte
ebr_volume_id:    dd 0x12345678 ; 4bytes
ebr_volume_label: db "ROBOT OS   " ; 11bytes
ebr_system_id:    db "FAT12   " ; 8bytes


start:
    jmp main

; prints a string on the screen
; params:
;  ds:si points to string ending with 0
puts:
    ; save registers we will modify
    push si
    push ax

.loop:
    lodsb                ; loads next character in al
    or al, al           ; check if next character is null
    jz .done 
    
    mov bh, 0
    mov ah, 0x0e        ; call bios interrupt
    int 0x10
    jmp .loop

.done:
    pop ax
    pop si
    ret
main:

    ; setup data segments 
    mov ax, 0                  ; cant write to ds/es directly
    mov ds, ax
    mov es, ax

    ; setup stack
    mov ss, ax 
    mov sp, 0x7C00             ; stack grows down from here
    
    ; print msg
    mov si, msg_hello
    call puts

    hlt

.halt:
    jmp .halt


msg_hello: db "RobotOS", ENDL, 0


times 510-($-$$) db 0
dw 0AA55h