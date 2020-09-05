//--------------------------------------------------------------------------
// Copyright (C) 2020 Carnegie Mellon University. All rights reserved.
//
// This program is free software; you can redistribute it and/or modify it
// under the terms of the GNU General Public License Version 2 as published
// by the Free Software Foundation.  You may not use, modify or distribute
// this program under any other version of the GNU General Public License.
//
// This program is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// General Public License for more details.
//
// You should have received a copy of the GNU General Public License along
// with this program; if not, write to the Free Software Foundation, Inc.,
// 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
//--------------------------------------------------------------------------

#ifndef PIGASUS_PCIE_H
#define PIGASUS_PCIE_H

#include <sys/ioctl.h>

namespace snort
{

// make sure these codes mirror the ones in kernel/linux/intel_fpga_pcie_ioctl.h
#define INTEL_FPGA_PCIE_IOCTL_MAGIC         0x70
#define INTEL_FPGA_PCIE_IOCTL_CHR_SEL_DEV   _IOW (INTEL_FPGA_PCIE_IOCTL_MAGIC, \
                                                  0, unsigned int)
#define INTEL_FPGA_PCIE_IOCTL_CHR_GET_DEV   _IOR (INTEL_FPGA_PCIE_IOCTL_MAGIC, \
                                                  1, unsigned int *)
#define INTEL_FPGA_PCIE_IOCTL_CHR_SEL_BAR   _IOW (INTEL_FPGA_PCIE_IOCTL_MAGIC, \
                                                  2, unsigned int)
#define INTEL_FPGA_PCIE_IOCTL_CHR_GET_BAR   _IOR (INTEL_FPGA_PCIE_IOCTL_MAGIC, \
                                                  3, unsigned int *)
#define INTEL_FPGA_PCIE_IOCTL_CHR_USE_CMD   _IOW (INTEL_FPGA_PCIE_IOCTL_MAGIC, \
                                                  4, bool)
#define INTEL_FPGA_PCIE_IOCTL_CFG_ACCESS    _IOWR(INTEL_FPGA_PCIE_IOCTL_MAGIC, \
                                                  5,                           \
                                                  struct intel_fpga_pcie_arg *)
#define INTEL_FPGA_PCIE_IOCTL_SRIOV_NUMVFS  _IOW (INTEL_FPGA_PCIE_IOCTL_MAGIC, \
                                                  6, int)
#define INTEL_FPGA_PCIE_IOCTL_SET_KMEM_SIZE _IOW (INTEL_FPGA_PCIE_IOCTL_MAGIC, \
                                                  7, unsigned int)
#define INTEL_FPGA_PCIE_IOCTL_DMA_QUEUE     _IOWR(INTEL_FPGA_PCIE_IOCTL_MAGIC, \
                                                  8,                           \
                                                  struct intel_fpga_pcie_arg *)
#define INTEL_FPGA_PCIE_IOCTL_DMA_SEND      _IOW (INTEL_FPGA_PCIE_IOCTL_MAGIC, \
                                                  9, unsigned int)
#define INTEL_FPGA_PCIE_IOCTL_GET_KTIMER    _IOR (INTEL_FPGA_PCIE_IOCTL_MAGIC, \
                                                  10, unsigned int *)
#define INTEL_FPGA_PCIE_IOCTL_MAXNR 10

#define RULE_ID_LINE_LEN 64 // bytes
#define RULE_ID_SIZE 2 // bytes
#define NB_RULES_IN_LINE (RULE_ID_LINE_LEN/RULE_ID_SIZE)

// 16384 (1MB) * 8 (scale) - 64 (head/copy) - 1 (global)
// 16384 (1MB) * 2 (scale) - 1 (global)
// 16384 (1MB) * 16 (scale) - 1 (global)
#define BUFFER_SIZE (16384*16-1)
    
#define C2F_BUFFER_SIZE 512
// In terms of dwords. 1 means the first 16 dwords are global registers
// the 1024 is the extra page for memory-copy
#define C2F_BUFFER_OFFSET ((BUFFER_SIZE+1)*16+1024)
// 4 bytes, 1 dword
#define HEAD_OFFSET 4
#define C2F_TAIL_OFFSET 16

#define PDU_ID_OFFSET 0
#define PDU_SIZE_OFFSET 6
#define PDU_FLIT_OFFSET 7
#define ACTION_OFFSET 8

#define ACTION_NO_MATCH 1
#define ACTION_MATCH 2

typedef struct pcie_block {
    uint32_t tail;
    uint32_t head;
    uint32_t kmem_low;
    uint32_t kmem_high;
    uint32_t c2f_tail;
    uint32_t c2f_head;
    uint32_t c2f_kmem_low;
    uint32_t c2f_kmem_high;
    uint32_t padding0;
    uint32_t padding1;
    uint32_t padding2;
    uint32_t padding3;
    uint32_t padding4;
    uint32_t padding5;
    uint32_t padding6;
    uint32_t padding7;
} pcie_block_t;

typedef struct block {
    uint32_t pdu_id;
    uint16_t dst_port;
    uint16_t src_port;
    uint32_t dst_ip;
    uint32_t src_ip;
    uint32_t protocol;
    uint32_t num_rule_id; // number of 512-bit lines in the rule_id block
    uint32_t pdu_size; // in bytes
    uint32_t pdu_flit;
    uint32_t action;
    uint8_t *pdu_payload; // immediately after pdu_hdr
    uint16_t *rule_id; // after the pdu_payload, 512bit aligned
} block_s;

// Structure used by SET_KMEM_SIZE call
struct intel_fpga_pcie_ksize {
    unsigned int size; // size of the allocated memory region. Passing in a 
                       // size of 0 will free the currently allocated memory
    int core_id; // core id of the user process
} __attribute__ ((packed));

/**
 * struct intel_fpga_pcie_cmd - Main structure for user to communicate to
 *                              kernel the target and source of a read or
 *                              write transaction.
 */
struct intel_fpga_pcie_cmd {
    /** @bar_num: BAR to be targeted for the transaction. */
    unsigned int bar_num;

    /** @bar_offset: Byte offset within BAR to target. */
    uint64_t bar_offset;

    /**
     * @user_addr: Address in user-space to write/read data.
     *             Always a virtual address. Used as the source of write data
     *             and the destination of the read data.
     */
    void *user_addr;
} __attribute__ ((packed));

typedef void (proc_packet_f)(block_s*);

ssize_t get_dev_handles(ssize_t& dev_handle, ssize_t& uio_dev_handle);
void dma_run(ssize_t dev_handle, ssize_t uio_dev_handle,
             proc_packet_f* proc_pkt, volatile int* keep_running);
void print_pcie_block(pcie_block_t * pb);
void print_slot(uint32_t *rp_addr, uint32_t start, uint32_t range);
void print_fpga_reg(ssize_t dev_handle);
void print_block(block_s *block);
void fill_block(uint32_t *addr, block_s *block);
uint32_t c2f_copy_head(uint32_t c2f_tail, pcie_block_t *global_block, 
         block_s *block, uint32_t *kdata);
void print_payload(block_s *block, uint32_t pkt_cnt);
} // namespace snort

#endif // PIGASUS_PCIE_H
