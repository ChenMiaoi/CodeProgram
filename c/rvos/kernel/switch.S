# 保存所有的通用寄存器
# tp和gp不需要保存，因为tp(thread pointer)用于保存hart id对上下文的切换没有影响
.macro reg_save base
    sw ra, 0(\base)
    sw sp, 4(\base)
	sw t0, 16(\base)
	sw t1, 20(\base)
	sw t2, 24(\base)
	sw s0, 28(\base)
	sw s1, 32(\base)
	sw a0, 36(\base)
	sw a1, 40(\base)
	sw a2, 44(\base)
	sw a3, 48(\base)
	sw a4, 52(\base)
	sw a5, 56(\base)
	sw a6, 60(\base)
	sw a7, 64(\base)
	sw s2, 68(\base)
	sw s3, 72(\base)
	sw s4, 76(\base)
	sw s5, 80(\base)
	sw s6, 84(\base)
	sw s7, 88(\base)
	sw s8, 92(\base)
	sw s9, 96(\base)
	sw s10, 100(\base)
	sw s11, 104(\base)
	sw t3, 108(\base)
	sw t4, 112(\base)
	sw t5, 116(\base)
# 此处我们不对t6进行保存，因为t6已经用于base，我们需要在外部进行额外保存操作
.endm

# 恢复任务的上下文通用寄存器
.macro reg_restore base
    lw ra, 0(\base)
	lw sp, 4(\base)
	lw t0, 16(\base)
	lw t1, 20(\base)
	lw t2, 24(\base)
	lw s0, 28(\base)
	lw s1, 32(\base)
	lw a0, 36(\base)
	lw a1, 40(\base)
	lw a2, 44(\base)
	lw a3, 48(\base)
	lw a4, 52(\base)
	lw a5, 56(\base)
	lw a6, 60(\base)
	lw a7, 64(\base)
	lw s2, 68(\base)
	lw s3, 72(\base)
	lw s4, 76(\base)
	lw s5, 80(\base)
	lw s6, 84(\base)
	lw s7, 88(\base)
	lw s8, 92(\base)
	lw s9, 96(\base)
	lw s10, 100(\base)
	lw s11, 104(\base)
	lw t3, 108(\base)
	lw t4, 112(\base)
	lw t5, 116(\base)
	lw t6, 120(\base)
.endm

.text
# 当进入中断或异常时，就会陷入内核态
# 定义的类C函数为：void trap_vector(void)
# 在后续要进入的C函数为： reg_t trap_handler(reg_t epc, reg_t cause, contect* ctx)
.global trap_vector
# 我们规定trap vector必须总是以4字节对齐的
.align 4
trap_vector:
	# 此处和__switch_to逻辑类似，首先保存当前任务上下文
	csrrw 	t6, mscratch, t6
	reg_save t6

	# 保存当前任务的mscratch
	mv 		t5, t6
	csrr	t6, mscratch
	sw		t6, 120(t5)

	# 保存当前任务的mepc
	csrr	a0, mepc
	sw		a0, 124(t5)

	csrw	mscratch, t5

	# 对trap_handler传参
	#! bug mcause = 0x0000 0001
	csrr	a0, mepc
	csrr	a1, mcause
	csrr 	a2, mscratch
	call	trap_handler

	# 返回后，接收trap_handler返回值
	csrw	mepc, a0

	# 恢复上下文寄存器
	csrr	t6, mscratch
	reg_restore	t6

	# 返回用户态
	mret

# 函数原型为： void __switch_to(context_t* next)
# 在rv中有规定，函数传参用a0...保存
.global __switch_to
.align 4
__switch_to:
	# 指向下一个任务的栈指针
	csrw	mscratch, a0

	# 获取mepc，载入下一个任务的pc，为后续mret返回做出设置
	lw		a1, 124(a0)
	csrw	mepc, a1

	# 恢复下一个任务的上下文寄存器
	mv		t6, a0
	reg_restore t6

	#! 此处导致异常，跳转到trap，然后异常问题
	mret
    # mscratch通常指向hart运行的栈指针
    # 我们需要把mscratch的指向更换为下一个任务
#     csrrw   t6, mscratch, t6    
#     beqz    t6, 1f              # 如果t6是0，也就是说是空任务，就跳转到1执行
#                                 # 所以，这里的逻辑也规定了，在进行sched初始化时
#                                 # 需要将mscratch寄存器的值初始化为0

#     reg_save    t6              # 保存当前任务的上下文

#     # 保存当前任务的栈指针到上下文中
#     # 外部的额外保存，注意，此处的t5和上面reg_save的t5含义不一样
#     mv      t5, t6
#     csrr    t6, mscratch
#     sw      t6, 120(t5)

# 1:
#     csrw    mscratch, a0        # 将下一个任务的栈指针写入mscratch
#     mv      t6, a0
    
#     reg_restore t6              # 开始恢复下一个任务的上下文

#     ret                         # 跳入下一个任务开始执行

.end
