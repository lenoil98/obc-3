/*
 * labels.c
 * 
 * This file is part of the Oxford Oberon-2 compiler
 * Copyright (c) 2006--2016 J. M. Spivey
 * All rights reserved
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 * 3. The name of the author may not be used to endorse or promote products
 *    derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
 * OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#include "config.h"
#include "vm.h"
#include "vminternal.h"
#include <stdio.h>
#include <stdlib.h>

/* There's a (little, we hope) pool of memory for recording branch
   info, used by both us and the client.  Notes about forward branches
   are recycled via a free-list, and the whole pool is made free
   before translating each procedure.  To cope with really huge
   procedures, there's a chain of pools of increasing size.  None of
   this memory is ever returned. */

#define NPOOLS 10

static unsigned char *pool[NPOOLS];
static int cpool = -1;

/* vm_scratch -- allocate memory for storing branch info, etc. */
void *vm_scratch(int size) {
     void *p;
     int poolsize;
     static unsigned char *freeptr, *limit;

     while (cpool < 0 || freeptr + size > limit) {
	  cpool++;
	  if (cpool >= NPOOLS) vm_panic("patch memory overflow");
	  poolsize = (1 << cpool) * PAGESIZE;
	  if (pool[cpool] == NULL)
	       pool[cpool] = (unsigned char *) vm_alloc(poolsize);
	  freeptr = pool[cpool]; limit = freeptr + poolsize;
     }

     p = (void *) freeptr;
     freeptr += size;
     return p;
}

/* Keep a table of branch targets, and deal with forward branches
   by backpatching when the target address is known.  */

typedef struct _branch *branch;

struct _vmlabel {
     int l_serial;              /* Serial number */
     code_addr l_val;           /* Native code address */
     branch l_branches;
};

/* A (forward) branch waiting to be patched */
struct _branch {
     int b_kind;		/* BRANCH or CASELAB */
     code_addr b_loc;		/* Branch location */
     branch b_next;		/* Next branch with same target */
};

static branch brfree;           /* Free list for branch records */

/* bralloc -- allocate a branch record from the free list or pool */
static branch bralloc(void) {
     if (brfree != NULL) {
	  branch p = brfree;
	  brfree = brfree->b_next;
	  return p;
     }

     return (branch) vm_scratch(sizeof(struct _branch));
}

static int nlabs = 0;

/* vm_newlab -- allocate a label */
vmlabel vm_newlab(void) {
     vmlabel q = (vmlabel) vm_scratch(sizeof(struct _vmlabel));
     q->l_serial = ++nlabs;
     q->l_val = NULL;
     q->l_branches = NULL;
     return q;
}

#ifdef DEBUG
char *fmt_lab(vmlabel lab) {
     static char buf[16];
     sprintf(buf, "L%d", lab->l_serial);
     return buf;
}
#endif

/* install -- patch in a branch target */
static void install(int kind, code_addr loc, code_addr val) {
     switch (kind) {
     case BRANCH:
          vm_patch(loc, val);
          break;
     case ABS:
     case CASELAB:
          * (unsigned *) loc = (unsigned) (ptr) val;
          break;
     case HI16:
          * (unsigned *) loc =
               (* (unsigned *) loc & ~0xffff)
               | (((unsigned) (ptr) val >> 16) & 0xffff);
          break;
     case LO16:
          * (unsigned *) loc =
               (* (unsigned *) loc & ~0xffff)
               | ((unsigned) (ptr) val & 0xffff);
          break;
     default:
          vm_panic("bad branch code");
     }
}

/* vm_label -- place a label */
void vm_label(vmlabel lab) {
     code_addr val = pc; 
     branch q = NULL;

#ifdef DEBUG
     if (vm_debug >= 1)
          printf("--- %s:\n", fmt_lab(lab));
#endif

     lab->l_val = val;

     /* Backpatch any forward branches to this location */
     for (branch p = lab->l_branches; p != NULL; q = p, p = p->b_next)
          install(p->b_kind, p->b_loc, val);

     /* Put the branch records back on the free-list */
     if (q != NULL) {
	  q->b_next = brfree;
	  brfree = lab->l_branches;
	  lab->l_branches = NULL;
     }
}

/* vm_branch -- note a branch for patching */
void vm_branch(int kind, code_addr loc, vmlabel lab) {
     if (lab->l_val != NULL)
          install(kind, loc, lab->l_val);
     else {
          branch br = bralloc();
          br->b_kind = kind;
          br->b_loc = loc;
          br->b_next = lab->l_branches;
          lab->l_branches = br;
     }
}

/* vm_reset -- discard branch information at end of procedure */
void vm_reset(void) {
     cpool = -1;
     brfree = NULL;
}

/* Jump tables */

static unsigned *caseptr;

/* vm_jumptable -- begin a jump table */
int vm_jumptable(int n) {
     code_addr table = vm_literal(n * sizeof(unsigned));
     caseptr = (unsigned *) table;
     return vm_addr(table);
}

/* vm_caselab -- add an address to the current jump table */
void vm_caselab(vmlabel lab) {
     vm_branch(CASELAB, (code_addr) caseptr, lab);
     caseptr++;
}     
