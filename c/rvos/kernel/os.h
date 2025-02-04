#ifndef __OS_H
#define __OS_H

#include "types.h"
#include "platform.h"

#include <stddef.h>
#include <stdarg.h>

/* uart.c */
extern void uart_init(void);
extern int  uart_putc(char c);
extern void uart_puts(char* s);
extern int  uart_getc(void);
extern void uart_isr(void);

/* printf.c */
extern int  printf(const char* fmt, ...);
extern void panic(const char* s);

/* mm.c */
extern void  page_init(void);
extern void* page_alloc(int npages);
extern void  page_free(void* p);

/* riscv.h */
#include "riscv.h"

/* sched.c */
#include "sched.h"
extern void sched_init(void);
extern void schedule(void);
extern int  task_create(void (*task)(void));
extern void task_delay(volatile int count);
extern void task_yield();

/* trap.c */
extern void  trap_init();
extern reg_t trap_handler(reg_t epc, reg_t cause, context_t* ctx);
extern void  trap_test();

/* plic.c */
extern void plic_init(void);
extern int  plic_claim(void);
extern void plic_complete(int irq);

/* timer.c */
#include "timer.h"
extern void timer_init(void);
extern void timer_load(int interval);
extern void timer_handler(void);
extern timer_t *timer_create(void (*handler)(void *arg), void *arg, uint32_t timeout);
extern void timer_delete(timer_t*timer);

/* lock.c */
extern int spin_lock(void);
extern int spin_unlock(void);

/* syscall.c */
extern void do_syscall(context_t* cxt);

#endif //! __OS_H
