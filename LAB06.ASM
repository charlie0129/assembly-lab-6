
assume cs:code
; 按键和频率相对应
data segment
    frequency dw 131, 147, 165, 175, 196, 220, 247
              dw 262, 294, 330, 349, 392, 440, 494
              dw 524, 587, 659, 698, 784, 880, 988
    keys      db "zxcvbnmasdfghjqwertyu"
data ends

stack segment stack
    dw 128 dup(0)
stack ends

code segment

; 读入键盘输入部分
read:
; 从键盘上读取一个输入ascii码到al，并打印到屏幕上
    mov ah, 01h 
    int 21h
; 如果读入的是esc键，跳转到退出部分
    cmp al, 1bh 
    jz quit   

play:
    mov cx, 21 ;设置cx循环21次，因为要比较21个字符
    mov di, 0  ;设置di存储指向keys数据段的指针
    mov si, 0  ;设置si存储指向freq数据段的指针
  ; 判断按下的按键
  choosekey:
    cmp al, ds:keys[di] ; key数据值与读入的键盘码(al)比较    
    jz output           ; 若匹配则进入输出部分
    inc di              ; 否则di+1， si+2
    add si, 2           
    loop choosekey      ; 循环回开头，尝试匹配下一个
    jmp mainloop           ; 如果输入的是其他字符，重新回到读入部分
  
  ; 输出声音
  output:
    ;初始化8254的2号定时器
    ;dx-端口号,原PC机端口43H，实验箱为283H
    ;al-控制字,原PC机为0b6h，实验箱为36h（00110110b）
    mov dx, 43h  
    mov al, 0b6h 
    out dx, al
    ; 定义基准频率：122870H,高四位存在bx中，低四位存在ax中
    mov ax, 2870h
    mov bx, 0012h
    ; 除法计算，将基准频率与data段找到的要播放的频率值相除
    ; 结果存放在ax中
    div word ptr ds:frequency[si] 

    ; 将计算结果存入2号计时器的计数常熟寄存器端口
    ; 原PC机：42H，实验箱：280H
    mov dx, 42h ; 定义端口
    out dx, al ;分两次输出到端口，先是低四位al
    mov al, ah ;将高四位转移到al的低四位
    out dx, al ;输出高四位到端口

    ; 输出声音：
    ; 输出到实验箱，端口28bh，控制码80h
    mov dx, 28bh
    mov al, 10000000b
    out dx, al
    ; 输出到PC机，端口61h，控制码03h
    mov dx, 61h
    mov al, 00000011b
    out dx, al

    ; 设置延时
    mov ah, 00h 
    int 1ah    ; 召唤一次时钟中断（约55ms）
    mov bp, 4  ; 更改此计数器以改变延时的时间（bp*55ms），约18次为1秒
    mov bx, dx ; 返回时间计数器的低位，存入bx
  delaylop:
    mov ah, 00h
    int 1ah    ; 再次召唤时钟中断
    sub dx, bx ; 返回的时钟计数器值减去存储的值,即为调用时钟中断的次数
    cmp dx, bp ; 如果次数没有到达设定的次数，继续循环
    jbe delaylop

    ; 停止播放
    and al, 00h ; 重置控制码为0
    mov dx, 61h
    out dx, al

start:
    ; 设置data段基址
    mov ax, data
    mov ds, ax
  mainloop:
    ; 开始读和播放主循环
    call read
    call play
    jmp mainloop
  quit:
    ; 按下esc键以后
    ; 打印一个换行，然后结束程序
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
code ends

end start
