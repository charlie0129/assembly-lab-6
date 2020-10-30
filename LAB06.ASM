; DOS-BOX MASM代码
assume cs:codesg
; 按键和频率相对应
datasg segment
    frequency dw 131, 147, 165, 175, 196, 220, 247
              dw 262, 294, 330, 349, 392, 440, 494
              dw 524, 587, 659, 698, 784, 880, 988
    keys      db "zxcvbnmasdfghjqwertyu"
datasg ends

stacksg segment stack
    dw 128 dup(0)
stacksg ends

codesg segment
read:
    mov ah, 01h
    int 21h
    cmp al, 1bh 
    jz quit   ; escape

play:
    mov cx, 21 ;循环计算器  循环21次
    mov di, 0  ;keys下标
    mov si, 0  ;freq下标
  choosekey:
    cmp al, ds:keys[di]
    jz output
    inc di ; +1
    add si, 2  ;+2
    loop choosekey  ; 
    jmp loop1  ; 输入的是无效字符
  output:
    ;  283h  43h
    mov dx, 43h  
    mov al, 00110110b  
    out dx, al
    ; 实验箱初始化
    mov ax, 2870h
    mov dx, 0012h
    div word ptr ds:frequency[si] ; 读取频率->ax
    ;  280h  42h
    mov dx, 42h
    out dx, al ;低位
    mov al, ah ;高位
    out dx, al
    ; start play
    mov dx, 28bh
    mov al, 10000000b
    out dx, al
    mov dx, 61h
    mov al, 03h
    out dx, al
    ; delay 两层循环空转
    mov AX, 10H ;可修改0000~0FFFFH之内 越大延时越高
    rep2:
    mov CX, 0FFFFH
    rep1:
    loop rep1 
    dec AX ;AX-1->AX
    cmp AX,0H ;比较AX和0的大小
jnz rep2 ;AX不等于0则跳转到 REP2
    ; stop play
    and al, 00h
    mov dx, 61h
    out dx, al

start:
    ; set segment registers
    mov ax, datasg
    mov ds, ax
  loop1:
    call read
    call play
    jmp loop1
    ; exit
  quit:
    ; output CR (\r)
    mov dl,0dh
    mov ah,02h
    int 21h
    ; output LF (\n)
    mov dl,0ah
    mov ah,02h
    int 21h
    mov ax, 4c00h
    int 21h   
codesg ends

end start
