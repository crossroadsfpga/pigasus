/*
 * Copyright (c) 2017-2018, Intel Corporation.
 * Intel, the Intel logo, Intel, MegaCore, NIOS II, Quartus and TalkBack
 * words and logos are trademarks of Intel Corporation or its subsidiaries
 * in the U.S. and/or other countries. Other marks and brands may be
 * claimed as the property of others. See Trademarks on intel.com for
 * full list of Intel trademarks or the Trademarks & Brands Names Database
 * (if Intel) or see www.intel.com/legal (if Altera).
 * All rights reserved.
 *
 * This software is available to you under a choice of one of two
 * licenses. You may choose to be licensed under the terms of the GNU
 * General Public License (GPL) Version 2, available from the file
 * COPYING in the main directory of this source tree, or the
 * BSD 3-Clause license below:
 *
 *     Redistribution and use in source and binary forms, with or
 *     without modification, are permitted provided that the following
 *     conditions are met:
 *
 *      - Redistributions of source code must retain the above
 *        copyright notice, this list of conditions and the following
 *        disclaimer.
 *
 *      - Redistributions in binary form must reproduce the above
 *        copyright notice, this list of conditions and the following
 *        disclaimer in the documentation and/or other materials
 *        provided with the distribution.
 *
 *      - Neither Intel nor the names of its contributors may be
 *        used to endorse or promote products derived from this
 *        software without specific prior written permission.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
 * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
 * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#include "intel_fpga_pcie.h"
#include "intel_fpga_pcie_dma.h"
#include "intel_fpga_pcie_ioctl.h"

#ifdef DMA_SUPPORTED
/******************************************************************************
 * Static function prototypes
 *****************************************************************************/
static void dma_init(struct dev_bookkeep *dev_bk);
static void dma_start(struct dev_bookkeep *dev_bk, uint8_t lptr,
                      bool lptr_wrap, bool is_read);
static void set_desc(struct desc *desc, uint64_t ep_addr, dma_addr_t rp_addr,
                     uint32_t byte_len, uint32_t id, bool is_read);

/******************************************************************************
 * Main DMA operation functions
 *****************************************************************************/
int intel_fpga_pcie_dma_queue(struct dev_bookkeep *dev_bk, unsigned long uarg)
{
    struct intel_fpga_pcie_arg karg;
    uint64_t ep_addr;
    uintptr_t kmem_offset;
    uint32_t size;
    bool is_read;
    struct kmem_info *kmem_info;
    struct dma_info *dma_info;
    int dma_idx;
    uint8_t lptr;

    if (copy_from_user(&karg, (void *)uarg, sizeof(karg))) {
        INTEL_FPGA_PCIE_DEBUG("couldn't copy arg from user.");
        return -EFAULT;
    }

    kmem_info = &dev_bk->kmem_info;
    dma_info  = &dev_bk->dma_info;
    ep_addr   = karg.ep_addr + ONCHIP_MEM_BASE;
    kmem_offset = (uintptr_t)karg.user_addr;
    size      = karg.size;
    is_read   = karg.is_read;
    dma_idx   = is_read ? DMA_RD_IDX : DMA_WR_IDX;

    // Check input arguments
    if (unlikely((size % 4) || (size < 4) || size > (1*1024*1024))) {
        INTEL_FPGA_PCIE_VERBOSE_DEBUG("requested DMA transfer length "
                                      "is invalid.");
        return -EINVAL;
    }

    // TODO: EP address range check.
    // if (unlikely(size >= DMA_MEM_SIZE ||
    //              ep_addr > DMA_MEM_OFFSET ||
    //              ep_addr > DMA_MEM_OFFSET
    //              )) {
    //     INTEL_FPGA_PCIE_VERBOSE_DEBUG("requested end point memory address "
    //                                   "range is invalid.");
    //     return -EINVAL;
    // }

    if (unlikely((kmem_offset+size) > kmem_info->size)) {
        INTEL_FPGA_PCIE_VERBOSE_DEBUG("requested kernel memory address range "
                                      "is invalid.");
        return -EINVAL;
    }

    if (unlikely(dma_info->num_pending[dma_idx] == 128)) {
        INTEL_FPGA_PCIE_VERBOSE_DEBUG("no unused descriptor available.");
        return -EBUSY;
    }
    lptr = dma_info->last_ptr[dma_idx];

    if (lptr >= 127) {
        if (dma_info->num_pending[dma_idx] > 0) {
            dma_info->last_ptr_wrap[dma_idx] = true;
        }
        lptr = 0;
    } else {
        ++lptr;
    }
    set_desc(&dma_info->dt_virt_addr[dma_idx]->descriptor[lptr], ep_addr,
             kmem_info->bus_addr + kmem_offset, size, lptr, is_read);
    dma_info->last_ptr[dma_idx] = lptr;
    ++dma_info->num_pending[dma_idx];

    return 0;
}

int intel_fpga_pcie_dma_send(struct dev_bookkeep *dev_bk, unsigned long uarg)
{
    struct timeval start_tv, end_tv;
    uint32_t timeout;
    bool send_transfer[2];
    bool has_pending[2];
    uint8_t lptr[2];
    bool lptr_wrap[2];
    int i;
    struct dma_info *dma_info;
    void *__iomem dma_ctrl_bar_base;

    timeout = DMA_TIMEOUT;
    dma_info = &dev_bk->dma_info;
    dma_ctrl_bar_base = dev_bk->bar[DMA_CTRL_BAR].base_addr;

    for (i=0; i<2; ++i) {
        send_transfer[i] = (uarg >> i) & 0x1UL;
        has_pending[i] = dma_info->num_pending[i] > 0;
        lptr[i] = dma_info->last_ptr[i];
        lptr_wrap[i] = dma_info->last_ptr_wrap[i];

        if (send_transfer[i]) {
            dma_info->last_ptr_wrap[i] = false;
            dma_info->num_pending[i] = 0;
        }
    }

    if (unlikely(!send_transfer[0] && !send_transfer[1])) {
        INTEL_FPGA_PCIE_VERBOSE_DEBUG("must initiate DMA read or DMA write.");
        return -EINVAL;
    }

    if (unlikely(!(send_transfer[0] && has_pending[0]) &&
                 !(send_transfer[1] && has_pending[1]))) {
        INTEL_FPGA_PCIE_VERBOSE_DEBUG("no DMA queued for either read "
                                       "or write.");
        return -ENODATA;
    }

    do_gettimeofday(&start_tv);

    for (i=0; i<2; ++i) {
        if (!send_transfer[i]) continue;

        dma_start(dev_bk, lptr[i], lptr_wrap[i], i==DMA_RD_IDX ? true : false);
    }

    while (true) {
        if ((!send_transfer[0] || dma_info->dt_virt_addr[0]->header.status[lptr[0]]) &&
            (!send_transfer[1] || dma_info->dt_virt_addr[1]->header.status[lptr[1]])) {
            break;
        }

        if (timeout == 0) {
            break;
        }

        --timeout;
        cpu_relax();
    }

    do_gettimeofday(&end_tv);
    dev_bk->dma_info.timer = (end_tv.tv_sec - start_tv.tv_sec)*1000000 +
                             end_tv.tv_usec - start_tv.tv_usec;
    if (timeout == 0) {
        INTEL_FPGA_PCIE_WARN("DMA operation timed out.");
        return -ETIME;
    }

    return 0;
}

/**
 * intel_fpga_pcie_dma_probe() - Initialize DMA controller and driver with
 *                               non-recurring information necessary for
 *                               DMA operation.
 *
 * @dev_bk: Pointer to the device bookkeeping structure. The structure
 *          contains DMA information structure, such as descriptor
 *          tables or number of pending/completed DMA descriptors.
 *
 * Return: 0 if successful, negative error code otherwise.
 */
int intel_fpga_pcie_dma_probe(struct dev_bookkeep *dev_bk)
{
    int retval;

    // Set DMA mask to limit the address range allocated for DMA by kernel.
#if (DMA_VERSION_MAJOR == 1)
    if (dma_set_mask_and_coherent(&dev_bk->dev->dev, DMA_BIT_MASK(32))) {
        // TXS uses 32-bit addressing by default in the example design.
        INTEL_FPGA_PCIE_ERR("couldn't use 32-bit mapping for DMA.");
        retval = -EADDRNOTAVAIL;
        goto failed_dma_mask;
    } else {
        INTEL_FPGA_PCIE_DEBUG("using a 32-bit mapping for DMA.");
    }
#elif (DMA_VERSION_MAJOR == 4)
    if (dma_set_mask_and_coherent(&dev_bk->dev->dev, DMA_BIT_MASK(64))) {
        INTEL_FPGA_PCIE_WARN("couldn't use 64-bit mapping for DMA.");
        if (dma_set_mask_and_coherent(&dev_bk->dev->dev, DMA_BIT_MASK(32))) {
            INTEL_FPGA_PCIE_ERR("couldn't use 32-bit mapping for DMA.");
            retval = -EADDRNOTAVAIL;
            goto failed_dma_mask;
        } else {
            INTEL_FPGA_PCIE_DEBUG("using a 32-bit mapping for DMA.");
        }
    } else {
        INTEL_FPGA_PCIE_DEBUG("using a 64-bit mapping for DMA.");
    }
#endif

    //Create read and write descriptor tables to be used in DMAs.
    dev_bk->dma_info.dt_virt_addr[DMA_RD_IDX] =
        dma_alloc_coherent(&dev_bk->dev->dev,
                           sizeof(*(dev_bk->dma_info.dt_virt_addr[DMA_RD_IDX])),
                           &dev_bk->dma_info.dt_bus_addr[DMA_RD_IDX],
                           GFP_KERNEL);
    if (!dev_bk->dma_info.dt_virt_addr[DMA_RD_IDX]) {
        INTEL_FPGA_PCIE_ERR("couldn't create read descriptor table.");
        retval = -ENOMEM;
        goto failed_rd_dt;
    }

    dev_bk->dma_info.dt_virt_addr[DMA_WR_IDX] =
        dma_alloc_coherent(&dev_bk->dev->dev,
                           sizeof(*(dev_bk->dma_info.dt_virt_addr[DMA_WR_IDX])),
                           &dev_bk->dma_info.dt_bus_addr[DMA_WR_IDX],
                           GFP_KERNEL);
    if (!dev_bk->dma_info.dt_virt_addr[DMA_WR_IDX]) {
        INTEL_FPGA_PCIE_ERR("couldn't create write descriptor table.");
        retval = -ENOMEM;
        goto failed_wr_dt;
    }

    // Allow device to generate upstream requests.
    pci_set_master(dev_bk->dev);

    // Initialize version-specific DMA information
    dma_init(dev_bk);

    up(&dev_bk->sem);
    return 0;

failed_wr_dt:
    dma_free_coherent(&dev_bk->dev->dev,
                      sizeof(*(dev_bk->dma_info.dt_virt_addr[DMA_RD_IDX])),
                      dev_bk->dma_info.dt_virt_addr[DMA_RD_IDX],
                      dev_bk->dma_info.dt_bus_addr[DMA_RD_IDX]);
failed_rd_dt:
failed_dma_mask:
    return retval;
}

void intel_fpga_pcie_dma_remove(struct dev_bookkeep *dev_bk)
{
    pci_clear_master(dev_bk->dev);
    dma_free_coherent(&dev_bk->dev->dev,
                      sizeof(*(dev_bk->dma_info.dt_virt_addr[DMA_WR_IDX])),
                      dev_bk->dma_info.dt_virt_addr[DMA_WR_IDX],
                      dev_bk->dma_info.dt_bus_addr[DMA_WR_IDX]);
    dma_free_coherent(&dev_bk->dev->dev,
                      sizeof(*(dev_bk->dma_info.dt_virt_addr[DMA_RD_IDX])),
                      dev_bk->dma_info.dt_virt_addr[DMA_RD_IDX],
                      dev_bk->dma_info.dt_bus_addr[DMA_RD_IDX]);
}

static void set_desc(struct desc *desc, uint64_t ep_addr, dma_addr_t rp_addr,
                     uint32_t byte_len, uint32_t id, bool is_read)
{
    uint32_t ctrl;
    INTEL_FPGA_PCIE_VERBOSE_DEBUG("Setting %s desc %u with len %u rp %llx "
                                  " ep %llx\n", is_read ? "read" : "write",
                                  id, byte_len, rp_addr, ep_addr);
    if (is_read) {
        desc->src_addr = ep_addr;
        desc->dst_addr = (uint64_t) rp_addr;
    } else {
        desc->src_addr = (uint64_t) rp_addr;
        desc->dst_addr = ep_addr;
    }
    ctrl = byte_len/4;
#if (DMA_VERSION_MAJOR == 1)
    ctrl |= id << 18;
#elif (DMA_VERSION_MAJOR == 4)
    ctrl |= id << 24;
#endif
    desc->ctrl = cpu_to_le32(ctrl);
    desc->reserved[0] = cpu_to_le32(0x0);
    desc->reserved[1] = cpu_to_le32(0x0);
    desc->reserved[2] = cpu_to_le32(0x0);
}

/******************************************************************************
 * Version-specific DMA routines
 *****************************************************************************/
#if (DMA_VERSION_MAJOR == 1)
inline void set_rc_desc_base(void * __iomem dma_ctrl_bar_base,
                             uint64_t addr, bool is_read);
inline void set_ep_desc_base(void * __iomem dma_ctrl_bar_base,
                             uint64_t addr, bool is_read);
inline void set_lptr(void * __iomem dma_ctrl_bar_base,
                     uint8_t lptr, bool is_read);
inline uint8_t get_lptr(void * __iomem dma_ctrl_bar_base, bool is_read);

static void dma_init(struct dev_bookkeep *dev_bk)
{
    void *__iomem dma_ctrl_bar_base;
    // Let FPGA know where to fetch descriptor table + EP FIFO address.
    dma_ctrl_bar_base = dev_bk->bar[DMA_CTRL_BAR].base_addr;
    set_rc_desc_base(dma_ctrl_bar_base,
                     dev_bk->dma_info.dt_bus_addr[DMA_RD_IDX], true);
    set_rc_desc_base(dma_ctrl_bar_base,
                     dev_bk->dma_info.dt_bus_addr[DMA_WR_IDX], false);
    set_ep_desc_base(dma_ctrl_bar_base, RDESC_FIFO_ADDR, true);
    set_ep_desc_base(dma_ctrl_bar_base, WDESC_FIFO_ADDR, false);

    // Set last pointers in dev bookkeeper.
    dev_bk->dma_info.last_ptr[DMA_RD_IDX] = get_lptr(dma_ctrl_bar_base, true);
    dev_bk->dma_info.last_ptr[DMA_WR_IDX] = get_lptr(dma_ctrl_bar_base, false);
    mb();
}

static void dma_start(struct dev_bookkeep *dev_bk, uint8_t lptr,
                      bool lptr_wrap, bool is_read)
{
    void *__iomem dma_ctrl_bar_base;
    dma_ctrl_bar_base = dev_bk->bar[DMA_CTRL_BAR].base_addr;

    dev_bk->dma_info.dt_virt_addr[is_read ? DMA_RD_IDX : DMA_WR_IDX]->
        header.status[lptr] = 0;
    if (lptr_wrap) {
        set_lptr(dma_ctrl_bar_base, 127, is_read);
        wmb();
    }
    set_lptr(dma_ctrl_bar_base, lptr, is_read);
    wmb();
}

inline void set_rc_desc_base(void * __iomem dma_ctrl_bar_base,
                             uint64_t addr, bool is_read)
{
    iowrite32(cpu_to_le32((addr) >> 32),
              dma_ctrl_bar_base + RC_DESC_BASE_H_REG_OFFSET +
              (is_read ? DMA_FROM_DEVICE_REG_OFFSET :
                         DMA_TO_DEVICE_REG_OFFSET));
    iowrite32(cpu_to_le32(addr & 0xFFFFFFFFULL),
              dma_ctrl_bar_base + RC_DESC_BASE_L_REG_OFFSET +
              (is_read ? DMA_FROM_DEVICE_REG_OFFSET :
                         DMA_TO_DEVICE_REG_OFFSET));
}

inline void set_ep_desc_base(void * __iomem dma_ctrl_bar_base,
                             uint64_t addr, bool is_read)
{
    iowrite32(cpu_to_le32((addr) >> 32),
              dma_ctrl_bar_base + EP_FIFO_BASE_H_REG_OFFSET +
              (is_read ? DMA_FROM_DEVICE_REG_OFFSET :
                         DMA_TO_DEVICE_REG_OFFSET));
    iowrite32(cpu_to_le32(addr & 0xFFFFFFFFULL),
              dma_ctrl_bar_base + EP_FIFO_BASE_L_REG_OFFSET +
              (is_read ? DMA_FROM_DEVICE_REG_OFFSET :
                         DMA_TO_DEVICE_REG_OFFSET));
}

inline void set_lptr(void * __iomem dma_ctrl_bar_base,
                     uint8_t lptr, bool is_read)
{
    iowrite32(cpu_to_le32(lptr),
              dma_ctrl_bar_base + LPTR_REG_OFFSET +
              (is_read ? DMA_FROM_DEVICE_REG_OFFSET :
                         DMA_TO_DEVICE_REG_OFFSET));
}

inline uint8_t get_lptr(void * __iomem dma_ctrl_bar_base, bool is_read)
{
    return ioread8(dma_ctrl_bar_base + LPTR_REG_OFFSET +
                   (is_read ? DMA_FROM_DEVICE_REG_OFFSET :
                              DMA_TO_DEVICE_REG_OFFSET));
}
/* End if DMA_VERSION_MAJOR == 1 */
#elif (DMA_VERSION_MAJOR == 4)
static void set_status_desc(struct desc *desc, uint64_t status_addr);

static void dma_init(struct dev_bookkeep *dev_bk)
{
    dev_bk->dma_info.last_ptr[DMA_RD_IDX] = 127;
    dev_bk->dma_info.last_ptr[DMA_WR_IDX] = 127;
}

static void dma_start(struct dev_bookkeep *dev_bk, uint8_t lptr,
                      bool lptr_wrap, bool is_read)
{
    void *__iomem dt_fetch_queue_addr;
    struct desc dt_fetch_desc = {0};
    int i;
    uint32_t ctrl;

    if (lptr_wrap) {
        INTEL_FPGA_PCIE_ERR("DMA Version 4.0 should not wrap around for descriptors.");
        return;
    }

    // Clear done status flag.
    dev_bk->dma_info.dt_virt_addr[is_read ? DMA_RD_IDX : DMA_WR_IDX]->
        header.status[lptr] = 0;
    if (is_read) {
        set_status_desc(&dev_bk->dma_info.dt_virt_addr[DMA_RD_IDX]->descriptor[lptr+1],
                        dev_bk->dma_info.dt_bus_addr[DMA_RD_IDX] + 4*lptr);
    } else {
        // Need to fetch status desc into different destination.
        set_desc(&dev_bk->dma_info.dt_virt_addr[DMA_WR_IDX]->descriptor[lptr+1],
                 WRITE_DESC_PRIO_OFFSET,
                 dev_bk->dma_info.dt_bus_addr[DMA_WR_IDX] +
                 (uintptr_t)(512 + (lptr+2)*32), 32, lptr+1, false);
        set_status_desc(&dev_bk->dma_info.dt_virt_addr[DMA_WR_IDX]->descriptor[lptr+2],
                        dev_bk->dma_info.dt_bus_addr[DMA_WR_IDX] + 4*lptr);
    }

    // Fetch DT from RP into descriptor FIFO queues.
    dt_fetch_desc.src_addr = dev_bk->dma_info.dt_bus_addr[is_read ? DMA_RD_IDX : DMA_WR_IDX] + 512;
    dt_fetch_desc.dst_addr = is_read ? WRITE_DESC_NORM_OFFSET : READ_DESC_NORM_OFFSET;

    /*
      One extra descriptor is required to be fetched.
      For reads (Host <-- FPGA), the last descriptor sets the DMA done status.
      For writes (Host --> FPGA), the last descriptor fetches the status
        descriptor which then sets the DMA done status.
     */
    ctrl = (lptr+2) * 8; // 8DW per descriptor.

    ctrl |= 1 << 20;    // Single destination
    ctrl |= 0xFE << 24; // Special descriptor ID
    dt_fetch_desc.ctrl = cpu_to_le32(ctrl);

    dt_fetch_queue_addr = dev_bk->bar[DMA_CTRL_BAR].base_addr +
                          (uintptr_t)(is_read ? READ_DESC_PRIO_OFFSET :
                                                READ_DESC_NORM_OFFSET);

    for (i=0; i<4; ++i) {
        iowrite32(*((uint32_t *)(&dt_fetch_desc)+i), dt_fetch_queue_addr+i*4);
    }
    wmb();
    // Most significant DWord must be written last.
    iowrite32(*((uint32_t *)(&dt_fetch_desc)+4), dt_fetch_queue_addr+16);
    wmb();

    // This version of DMA does not require consecutive descriptors
    // to be used - can simply start back at
    dev_bk->dma_info.last_ptr[DMA_RD_IDX] = 127;
    dev_bk->dma_info.last_ptr[DMA_WR_IDX] = 127;
}

static void set_status_desc(struct desc *desc, uint64_t status_addr)
{
    uint32_t ctrl;

    desc->src_addr = 0x1ULL;    // The data to write to status location.
    desc->dst_addr = status_addr;
    ctrl = 1;   // 1 DW status
    ctrl |= 1 << 18;    // Immediate access
    ctrl |= 255 << 24;  // Status descriptor ID == 255
    desc->ctrl = cpu_to_le32(ctrl);
    desc->reserved[0] = cpu_to_le32(0x0);
    desc->reserved[1] = cpu_to_le32(0x0);
    desc->reserved[2] = cpu_to_le32(0x0);
}
#endif /* End if DMA_VERSION_MAJOR == 4 */

#else /* Else ifndef DMA_SUPPORTED */

int intel_fpga_pcie_dma_queue(struct dev_bookkeep *dev_bk, unsigned long uarg)
{
    INTEL_FPGA_PCIE_DEBUG("DMA is not supported by the device.");
    return -EOPNOTSUPP;
}

int intel_fpga_pcie_dma_send(struct dev_bookkeep *dev_bk, unsigned long uarg)
{
    INTEL_FPGA_PCIE_DEBUG("DMA is not supported by the device.");
    return -EOPNOTSUPP;
}

int intel_fpga_pcie_dma_probe(struct dev_bookkeep *dev_bk)
{
    return 0;
}

void intel_fpga_pcie_dma_remove(struct dev_bookkeep *dev_bk)
{
    return;
}

#endif /* End of ifndef DMA_SUPPORTED */
