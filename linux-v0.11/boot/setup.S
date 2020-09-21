entry _start
_start:
    !显示信息包括'Loading'+回车+换行
    ! BIOS 中断0x10的功能号ah=0x03,bh=0
    mov ah,#0x03
    xor bh,bh
    int 0x10

    ! 显示字符数量, 总共有 25 个字符
    mov cx,#25
    ! page 0, attribute 7 (normal)
    mov bx,#0x0007
    mov bp,#msg1
    ! 相比与 linux-0.11 中的代码，需要增加对 es 的处理，因为原代码中在输出之前已经处理了 es
    mov ax,#0x07c0
    mov es,ax
    mov ax,#0x1301
    int 0x10

! 设置一个死循环
inf_loop:
    jmp inf_loop

! 放置需要显示的字符串
msg1:
    ! 字符为0A(10)表示换行, 0D(13)表示回车, 共1+1 + 字符数 + 2+2 = 2 + 34 + 6 = 40
    .byte   13,10
    .ascii  "Now we are in SETUP"
    .byte   13,10,13,10

! 512B, 需要保证最后连个字节为AA55, 需要设置为510
! 下面语句表示从地址510开始, 因此最后两个字节用于引导识别使用
.org 510
boot_flag:
    .word   0xAA55

