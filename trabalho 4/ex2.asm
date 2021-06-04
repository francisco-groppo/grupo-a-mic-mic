%include "linux64.inc"

section .data
img_color times 786486 db 0    ; 
img_brt times 786486 db 0      ; 
path_img_color db "lena_color.bmp", 0
img_out db  "lena_brt.bmp", 0

section .text
    global _start

_start:
    ; Open RGB image
    mov rax, SYS_OPEN
    mov rdi, path_img_color
    mov rsi, O_RDONLY
    mov rdx, 0644o
    syscall

    ; Read RGB image and store on img_color
    mov rdi, rax
    mov rax, SYS_READ
    mov rsi, img_color
    mov rdx, 786486
    syscall

    ; Close RGB image
    mov rax, SYS_CLOSE
    syscall

    ; Copy bpm header of img_color to img_brt and gray_img (first 54 bytes)
    mov rax, img_color
    mov rbx, img_brt
    mov r9, 0

_loopHeader:
    mov r8, [rax]
    mov [rbx], r8
    inc rax
    inc rbx
    inc r9
    cmp r9, 47
    jne _loopHeader

    ; Convert RGB to gray scale
    mov rax, img_color+54
    mov rbx, img_brt+54

brt_ou_n:
    mov r10b, [rax] ; 
    cmp r10, 215     ; threshold=40, 255-40=215
    jge pixel_br
    jl  pixel_brt


loop_brt:
    add rax, 1
    add rbx, 1

    cmp rax, img_brt
    jne brt_ou_n


    ; Create new BW image
    mov rax, SYS_OPEN
    mov rdi, img_out
    mov rsi, O_CREAT+O_WRONLY
    mov rdx, 0644o
    syscall

    ; Writing the BW image
    mov rdi, rax
    mov rax, SYS_WRITE
    mov rsi, img_brt
    mov rdx, 786486
    syscall

    ; Close BW image
    mov rax, SYS_CLOSE
    syscall

_exit:
    mov rax, SYS_EXIT
    mov rdi, 0
    syscall

pixel_br:
    mov r10b, 255
    mov [rbx], r10b
    jmp loop_brt

pixel_brt:
    add r10b, 40
    mov [rbx], r10b
    jmp loop_brt