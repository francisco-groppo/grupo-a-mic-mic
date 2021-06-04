%include "linux64.inc"

section .data
img_color times 786486 db 0   ; space to color image
img_bw times 786486 db 0      ; space to bw image
path_img_color db "lena_color.bmp", 0
path_img_bw db  "lena_bw.bmp", 0

section .text
    global _start

_start:
    ;   open file
    mov rax, SYS_OPEN
    mov rdi, path_img_color
    mov rsi, O_RDONLY
    mov rdx, 0644o
    syscall

    ;   read file and store on img_color
    mov rdi, rax
    mov rax, SYS_READ
    mov rsi, img_color
    mov rdx, 786486
    syscall

    ; close file
    mov rax, SYS_CLOSE
    syscall

    ; store header on img_bw and img_gray
    mov rax, img_color
    mov rbx, img_bw
    mov r9, 0

loop_header:
    mov r8, [rax]
    mov [rbx], r8
    inc rax
    inc rbx
    inc r9
    cmp r9, 47
    jne loop_header

    ;   convert to grayscale
    mov rax, img_color+54
    mov rbx, img_bw+54

loop_b_or_w:
    mov r10b, [rax]     ; r10 = b
    shr r10b, 2         ; r10 = b/4

    mov r11b, [rax+1]   ; r11 = 
    shr r11b, 1         ; r11 = g/2

    mov r12b, [rax+2]   ; r12 = r
    shr r12b, 2         ; r12 = r/4

    add r10b, r11b      ; r10b = b/4+g/2
    add r10b, r12b      ; grayscale = r10b = b/4+g/2+r/4=(b+2g+r)/2

    cmp r10, 95     ; limiar = 95
    jge white
    jl  black

loop_bw:
    add rax, 3          ; inc address
    add rbx, 3          ; inc address

    ;cmp rax, img_gray
    cmp rax, img_bw
    jne loop_b_or_w

    ; create bw image
    mov rax, SYS_OPEN
    mov rdi, path_img_bw
    mov rsi, O_CREAT+O_WRONLY
    mov rdx, 0644o
    syscall

    ; write to the bw image
    mov rdi, rax
    mov rax, SYS_WRITE
    mov rsi, img_bw
    mov rdx, 786486
    syscall

    ; close bw image
    mov rax, SYS_CLOSE
    syscall

_exit:
    mov rax, SYS_EXIT
    mov rdi, 0
    syscall

white:
    mov r10b, 255
    mov [rbx], r10b
    mov [rbx+1], r10b
    mov [rbx+2], r10b
    jmp loop_bw

black:
    mov r10b, 0
    mov [rbx], r10b
    mov [rbx+1], r10b
    mov [rbx+2], r10b
    jmp loop_bw

