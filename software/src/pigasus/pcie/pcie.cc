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

#include <termios.h>
#include <time.h>
#include <cerrno>
#include <cstdlib>
#include <ctime>
#include <iomanip>
#include <iostream>
#include <limits>
#include <stdexcept>
#include <system_error>
#include <cstring>
#include <cstdio>

#include <sched.h>
#include <fcntl.h>

#include <sys/mman.h>

#include "pcie.h"

// test counter
#include <unistd.h>
#include "pcie_tsc_clock.h"

namespace snort {

ssize_t get_dev_handles(ssize_t& dev_handle, ssize_t& uio_dev_handle)
{
    ssize_t fd;
    int result;
    unsigned int bdf = 0;
    unsigned int bar = 0;

    fd = open("/dev/intel_fpga_pcie_drv", O_RDWR | O_CLOEXEC);
    if (fd < 0) {
        return fd;
    }
    dev_handle = fd;

    fd = open("/dev/uio0", O_RDWR | O_CLOEXEC); // HACK(sadok) assume it's uio0
    if (fd < 0) {
        close(dev_handle);
        return fd;
    }
    uio_dev_handle = fd;

    if (ioctl(dev_handle, INTEL_FPGA_PCIE_IOCTL_CHR_GET_DEV, &bdf)) {
        close(dev_handle);
        close(uio_dev_handle);
    }

    if (ioctl(dev_handle, INTEL_FPGA_PCIE_IOCTL_CHR_GET_BAR, &bar)) {
        close(dev_handle);
        close(uio_dev_handle);
    }

    return 0;
}

void dma_run(ssize_t dev_handle, ssize_t uio_dev_handle,
             proc_packet_f* proc_pkt, volatile int* keep_running)
{
    int result;
    void *mmap_addr, *uio_mmap_bar2_addr;
    uint32_t *kdata, *cpu_head_reg;
    pcie_block_t *uio_data_bar2;
    int core_id;

    unsigned int cpu_head = 0; // head ptr
    unsigned int cpu_tail;
    int free_slot; // number of free slots in ring buffer
    unsigned int allocated_size;
    unsigned int copy_size;

    void *c2f_mmap_addr;
    uint32_t *c2f_kdata;
    unsigned int c2f_allocated_size;
    unsigned int c2f_cpu_head; // head ptr
    unsigned int c2f_cpu_tail = 0;
    int c2f_free_slot; // number of free slots in ring buffer
    struct intel_fpga_pcie_ksize arg;

    int curr_time = 0;

    // test counter
    uint64_t duration = 0;
    uint64_t start = PCIe_TscClock::counter();
    sleep(1);
    uint64_t end = PCIe_TscClock::counter();
    uint64_t elapsed = end - start;
    printf("elapsed = %lu \n", elapsed);
    printf("clock scale = %li \n", pcie_clock_scale());
    printf("usec %f \n", float(elapsed) / float(pcie_clock_scale()));

    block_s pdu; //current PDU block
    pcie_block_t *global_block; // The global 512-bit register array.

    // Add one more page for rounding pkts.
    allocated_size = (BUFFER_SIZE+1) * 16 * 4 + 4096;

    core_id = sched_getcpu();
    std::cout << "Core_id:" << core_id << std::endl;
    if (core_id < 0) {
        std::cout << "Could not get cpu id!" << std::endl;
        return;
    }

#ifdef OFFLINE    
	FILE *ptr_fp;
    int counter;
    int capture_size;
    capture_size = 262123*16;
    //capture_size = 126340*16;

	kdata = (uint32_t *)malloc(allocated_size);
	if(!kdata)
	{
		printf("Memory allocation error!\n");
		exit(1);
	}else printf("Memory allocation successful.\n");
	if((ptr_fp = fopen("capture.bin", "rb"))==NULL)
	{
		printf("Unable to open the file!\n");
		exit(1);
	}else printf("Opened file successfully for reading.\n");

	/* Part G */

	if(fread(&kdata[16], capture_size * sizeof( uint32_t ), 1, ptr_fp) != 1)
	{
		printf( "Read error!\n" );
		exit( 1 );
	}else printf( "Read was successful.\n" );
	fclose(ptr_fp);
#else
    // Obtain kernel memory.

    // set kernel memory size and core id
    arg.size = allocated_size;
    arg.core_id = core_id;
    if (ioctl(dev_handle, INTEL_FPGA_PCIE_IOCTL_SET_KMEM_SIZE, &arg)) {
        std::cout << "Could not get kernel memory!" << std::endl;
        return;
    }

    // mmap kernel memory region
    mmap_addr = mmap(NULL, allocated_size, PROT_READ|PROT_WRITE, MAP_SHARED,
                     dev_handle, 0);
    if (mmap_addr == MAP_FAILED) {
        std::cout << "Could not get mmap kernel memory!" << std::endl;
        return;
    }
    kdata = reinterpret_cast<uint32_t *>(mmap_addr);

    // Using BAR 2
    unsigned int offset = 2 * getpagesize();
    uio_mmap_bar2_addr = mmap(NULL, 2 * sizeof(pcie_block), PROT_READ|PROT_WRITE,
                              MAP_SHARED, uio_dev_handle, offset);
    if (uio_mmap_bar2_addr == MAP_FAILED) {
        std::cout << "Could not get mmap uio memory!" << std::endl;
        return;
    }
    uio_data_bar2 = reinterpret_cast<pcie_block_t *>(uio_mmap_bar2_addr);
    
    //calculate the corresponding head offset
    cpu_head_reg = &(uio_data_bar2->head) + core_id*4; // start from core 0
    *cpu_head_reg = 0;

    // Global registers is the first slot of the ring buffer.
    global_block = (pcie_block_t *) kdata;

    // print the FPGA side registers
    print_fpga_reg(dev_handle);
#endif

    unsigned long long rx_pkts = 0;
    unsigned long long num_rules = 0;
    unsigned int last_pdu_flit = 0;
    unsigned int last_pdu_id = 0;
    unsigned int run_cnt = 0;

    // Main Loop
    while (*keep_running) {
#ifdef OFFLINE
        cpu_tail = capture_size/16;
#else
        cpu_tail = global_block->tail; // only read it once
#endif   
        if (cpu_tail == cpu_head) {
#ifdef OFFLINE
            if(run_cnt == NUM_RUN-1){
                break;
            } else {
                cpu_head = 0;
                run_cnt++;
            }
#else
            continue;
#endif
        }
 
        if (cpu_tail <= cpu_head) {
            free_slot = cpu_head - cpu_tail;
        } else {
            free_slot = BUFFER_SIZE - cpu_tail + cpu_head;
        }
#ifdef CAPTURE
        if (free_slot < 32){
            break;
        }
#endif

        // fill in the pdu hdr
        fill_block(&kdata[(cpu_head+1)*16],&pdu);

        // We need to copy the begining of the ring buffer to the last page
        if ((cpu_head + pdu.pdu_flit) > BUFFER_SIZE) {
            if ((cpu_head + pdu.pdu_flit) != BUFFER_SIZE) {
                copy_size = cpu_head + pdu.pdu_flit - BUFFER_SIZE;
                //printf("memcpy, cpu.head = %d, pdu.pdu_flit = %d, copy_size = %d \n", cpu_head, pdu.pdu_flit, copy_size);
                memcpy(&kdata[(BUFFER_SIZE+1)*16], &kdata[1*16], copy_size*16*4);
            }
        }

        proc_pkt(&pdu);

#ifndef CAPTURE
        // update cpu_head
        if ((cpu_head + pdu.pdu_flit) < BUFFER_SIZE) {
            cpu_head = cpu_head + pdu.pdu_flit;
        } else {
            cpu_head = cpu_head + pdu.pdu_flit - BUFFER_SIZE;
        }

    #ifndef OFFLINE
        // method using UIO
        asm volatile ("" : : : "memory"); // compiler memory barrier
        *cpu_head_reg = cpu_head;
    #endif
#endif
        ++rx_pkts;
        num_rules += pdu.num_rule_id;
    }
#ifdef CAPTURE
    FILE *ptr_fp;

	if((ptr_fp = fopen("capture.bin", "wb")) == NULL)
	{
		printf("Unable to open file!\n");
		exit(1);
	}else printf("Opened file successfully for writing.\n");

	/* Part D */
	if( fwrite(&kdata[16], (BUFFER_SIZE-free_slot)*64, 1, ptr_fp) != 1)
	{
		printf("Write error!\n");
		exit(1);
	}else printf("Write was successful.\n");
	fclose(ptr_fp);
	//free(ptr_d);
#endif
    printf("done! \n");

    std::cout << std::dec;
    std::cout << "rx pkts: " << rx_pkts << std::endl;
    std::cout << "num rules: " << num_rules << std::endl;
    std::cout << "cpu_head: " << cpu_head << std::endl;
    std::cout << "cpu_tail: " << cpu_tail << std::endl;
    std::cout << "c2f_cpu_head: " << c2f_cpu_head << std::endl;
    std::cout << "c2f_cpu_tail: " << c2f_cpu_tail << std::endl;

#ifdef FLUSH_BUFFER
    free(pkt_buf);
#endif

#ifdef OFFLINE    
	free(kdata);
#else
    if (munmap(mmap_addr, allocated_size)) {
        std::cout << "Could not unmap kernel memory!" << std::endl;
        return;
    }
#endif
}

void print_slot(uint32_t *rp_addr, uint32_t start, uint32_t range)
{
    for (unsigned int i = 0; i < range*16; ++i) {
        if (i%16==0) {
            printf("\n");
        }
        printf("rp_addr[%d] = 0x%08x \n", 16*start + i, rp_addr[16*start+i]);
    }
}

void print_fpga_reg(ssize_t dev_handle)
{
    int result;
    uint32_t temp_r;
    struct intel_fpga_pcie_cmd cmd;
    
    cmd.bar_num = 2;
    
    for (uint64_t i = 0; i < 32; ++i) {
        cmd.bar_offset = i * 4;
        cmd.user_addr = &temp_r;
        result = read(dev_handle, &cmd, 4); // 32 bit register
        printf("fpga_reg[%lu] = 0x%08x \n", i, temp_r);
    }
} 

void print_pcie_block(pcie_block_t * pb)
{
    printf("pb->tail = %d \n", pb->tail);
    printf("pb->head = %d \n", pb->head);
    printf("pb->kmem_low = 0x%08x \n", pb->kmem_low);
    printf("pb->kmem_high = 0x%08x \n", pb->kmem_high);
}

void fill_block(uint32_t *addr, block_s *block) {
    int reminder;
    int offset;

    block->pdu_id = addr[0];
    block->dst_port = addr[1] & 0xFFFF;
    block->src_port = (addr[1] >> 16) & 0xFFFF;
    block->dst_ip = addr[2];
    block->src_ip = addr[3];
    block->protocol = addr[4];

    block->num_rule_id = addr[5];

    block->pdu_size = addr[6];
    block->pdu_flit = addr[7];
    //block->pdu_flit = 25; //quick fix
    block->pdu_payload = (uint8_t*) &addr[16];

    // Calculate the offset of the rule_id
    reminder = block->pdu_size & 0x3F;
    offset = block->pdu_size >> 6;
    if (reminder > 0){
        offset += 1;
    }
    // include the hdr entry
    offset = (offset + 1) * 16; // 16 * 32 bit = 512 bit

    block->rule_id = (uint16_t *)&addr[offset];
}

void print_payload(block_s *block, uint32_t pkt_cnt) {
    uint32_t i;
    uint32_t ip_hdr;
    uint32_t tcp;
    uint32_t hdr_size;

    ip_hdr = block->pdu_payload[14] & 0xF;
    tcp = block->pdu_payload[23] == 6;
    if(tcp){
        //tcp hdr size
        hdr_size = (block->pdu_payload[14+ip_hdr*4+12] & 0xF0) >> 4;
        //total hdr size
        hdr_size = hdr_size*4+ip_hdr*4+14;
    } else {
        //total hdr size
        hdr_size = 8*4+ip_hdr*4+14;
    }

    printf("----Pkt %d payload------\n",pkt_cnt);
    for (i = 0; i < block->pdu_size-hdr_size; i++) {
        printf("%02x ", block->pdu_payload[i+hdr_size]);
        if ((i + 1) % 8 == 0) {
            printf(" ");
        }
        if ((i + 1) % 16 == 0) {
            printf("\n");
        }
        if (i > 2000) {
            printf("pdu_size is too big \n");
            break;
        }
    }
    printf("\n----Rule IDs------\n");
    // 512-bit aligned. 32 16-bit rule ID per line.
    for(i=0;i<block->num_rule_id*32;i++){
        if(block->rule_id[i]!=0){
            printf("ruleID[%d] = 0x%04x \n",i, block->rule_id[i]);
        }
        if (i > 2000) {
            printf("ruleID is too big \n");
            break;
        }
    }
}

void print_block(block_s *block) {
    uint32_t i;
    printf("=============PRINT BLOCK=========\n");
    printf("pdu_id      : 0x%08x \n", block->pdu_id);
    printf("dst_port    : 0x%04x \n", block->dst_port);
    printf("src_port    : 0x%04x \n", block->src_port);
    printf("dst_ip      : 0x%08x \n", block->dst_ip);
    printf("src_ip      : 0x%08x \n", block->src_ip);
    printf("protocol    : 0x%08x \n", block->protocol);
    printf("num_rule_id : 0x%08x \n", block->num_rule_id);
    printf("pdu_size    : 0x%08x \n", block->pdu_size);
    printf("pdu_flit    : 0x%08x \n", block->pdu_flit);
    printf("----PDU payload------\n");
    for (i = 0; i < block->pdu_size; i++) {
        printf("%02x ", block->pdu_payload[i]);
        if ((i + 1) % 8 == 0) {
            printf(" ");
        }
        if ((i + 1) % 16 == 0) {
            printf("\n");
        }
        if (i > 2000) {
            printf("pdu_size is too big \n");
            break;
        }
    }
    printf("\n----Rule IDs------\n");
    //512-bit aligned. 32 16-bit rule ID per line.
    for(i=0;i<block->num_rule_id*32;i++){
        if(block->rule_id[i]!=0){
            printf("ruleID[%d] = 0x%04x \n",i, block->rule_id[i]);
        }
        if (i > 2000) {
            printf("ruleID is too big \n");
            break;
        }
    }
}

uint32_t c2f_copy_head(uint32_t c2f_tail, pcie_block_t *global_block, 
        block_s *block, uint32_t *kdata) {
    uint32_t pdu_flit;
    uint32_t copy_flit;
    uint32_t free_slot;
    uint32_t c2f_head;
    uint32_t copy_size;
    uint32_t base_addr;

    c2f_head = global_block->c2f_head;
    // calculate free_slot
    if (c2f_tail < c2f_head) {
        free_slot = c2f_head - c2f_tail - 1;
    } else {
        // CPU2FPGA ring buffer does not have the global register. 
        // the free_slot should be at most one slot smaller than CPU2FPGA ring
        // buffer.
        free_slot = C2F_BUFFER_SIZE - c2f_tail + c2f_head - 1;
    }
    while (free_slot < 1) { 
        // recalculate free_slot
    	c2f_head = global_block->c2f_head;
    	if (c2f_tail < c2f_head) {
    	    free_slot = c2f_head - c2f_tail - 1;
    	} else {
    	    free_slot = C2F_BUFFER_SIZE - c2f_tail + c2f_head - 1;
    	}
    }
    base_addr = C2F_BUFFER_OFFSET+c2f_tail*16;

    //Fake match
    kdata[base_addr + PDU_ID_OFFSET] = block->pdu_id;
    //PDU_SIZE
    kdata[base_addr + PDU_SIZE_OFFSET] = block->pdu_size;
    //exclude the rule flits and header flit
    kdata[base_addr + PDU_FLIT_OFFSET] = block->pdu_flit - block->num_rule_id - 1;
    kdata[base_addr + ACTION_OFFSET] = ACTION_NO_MATCH;

    //update c2f_tail
    if(c2f_tail == C2F_BUFFER_SIZE-1){
        c2f_tail = 0;
    } else {
        c2f_tail += 1;
    }
    return c2f_tail;
}   

}  // namespace snort
