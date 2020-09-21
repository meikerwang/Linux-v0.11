SETUPLEN=2
SETUPSEG=0x07e0
entry _start
_start:
    !显示信息包括'Loading'+回车+换行
    ! BIOS 中断0x10的功能号ah=0x03,bh=0
    mov ah,#0x03
    xor bh,bh
    int 0x10

    ! 显示字符数量, 总共有 40 个字符
    mov cx,#40
    ! page 0, attribute 7 (normal)
    mov bx,#0x0007
    mov bp,#msg1
    ! 相比与 linux-0.11 中的代码，需要增加对 es 的处理，因为原代码中在输出之前已经处理了 es
    mov ax,#0x07c0
    mov es,ax
    mov ax,#0x1301
    int 0x10

! 利用0x13中断将setup程序模块从磁盘第2扇区读入到0x90200处, 读4个扇区
load_setup:
    ! 设置驱动器和磁头(drive 0, head 0): 软盘 0 磁头
    mov dx,#0x0000
    ! 设置扇区号和磁道(sector 2, track 0): 0 磁头、0 磁道、2 扇区
    mov cx,#0x0002
    ! 设置读入的内存地址：BOOTSEG+address = 512，偏移512字节
    mov bx,#0x0200
    ! SETUPLEN是读入的扇区个数，Linux 0.11 设置的是 4，
    ! 我们不需要那么多，我们设置为 2（因此还需要添加变量 SETUPLEN=2）
    mov ax,#0x0200+SETUPLEN
    ! 应用 0x13 号 BIOS 中断读入 2 个 setup.s扇区
    int 0x13
    ! 读入成功，跳转到 ok_load_setup: ok - continue
    jnc ok_load_setup

    ! 软驱、软盘有问题才会执行到这里。我们的镜像文件比它们可靠多了
    mov dx,#0x0000
    ! 否则复位软驱 reset the diskette
    mov ax,#0x0000
    int 0x13
    ! 重新循环，再次尝试读取
    jmp load_setup

! 跳到 setup 执行
ok_load_setup:
    ! 要注意：我们没有将 bootsect 移到 0x9000，因此跳转后的段地址应该是 0x7ce0
    ! 即我们要设置 SETUPSEG=0x07e0
    jmpi 0,SETUPSEG

! 放置需要显示的字符串
msg1:
    ! 字符为0A(10)表示换行, 0D(13)表示回车, 共1+1 + 字符数 + 2+2 = 2 + 34 + 6 = 40
    .byte   13,10
    .ascii  "Hello OS world, my name is Wangzhi"
    .byte   13,10,13,10

! 512B, 需要保证最后连个字节为AA55, 需要设置为510
! 下面语句表示从地址510开始, 因此最后两个字节用于引导识别使用
.org 510
boot_flag:
    .word   0xAA55

