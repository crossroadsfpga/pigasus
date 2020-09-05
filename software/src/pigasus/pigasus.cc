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

#ifdef HAVE_CONFIG_H
#include "config.h"
#endif

#include <daq.h>

#include <algorithm>
#include <csignal>
#include <cstring>
#include <fstream>
#include <iostream>
#include <vector>

#include "detection/detection_options.h"
#include "detection/fp_detect.h"
#include "detection/ips_context.h"
#include "detection/pcrm.h"
#include "framework/cursor.h"
#include "framework/ips_option.h"
#include "log/messages.h"
#include "search_engines/hyperscan.h"

#include "pcie/pcie.h"

#include "pigasus.h"
//Zhipeng Start
#include "time/clock_defs.h"
int for_loop_duration;
//Zhipeng End

#define USE_FILE 0
#define PIGASUS_DEBUG 0

#if USE_FILE
#include <chrono>
#endif

namespace snort
{

static volatile int keep_running = 1;
static unsigned long long match_cntr = 0;
static unsigned long long no_match_cntr = 0;

static std::vector<uint16_t> rule_sids_vector;

static const char* name = "pkt_data"; // only pkt_data for now
Cursor cursor(name, NULL, 0);

void int_handler(int signal __attribute__((unused))) {
    keep_running = 0;
}

static void print_eval_status(IpsOption::EvalStatus eval_status) {
    switch (eval_status)
    {
    case IpsOption::EvalStatus::NO_MATCH:
        std::cout << "NO MATCH" << std::endl;
        break;
    case IpsOption::EvalStatus::MATCH:
        std::cout << "MATCH" << std::endl;
        break;
    case IpsOption::EvalStatus::NO_ALERT:
        std::cout << "NO ALERT" << std::endl;
        break;
    case IpsOption::EvalStatus::FAILED_BIT:
        std::cout << "FAILED BIT" << std::endl;
        break;
    }
}

IpsOption::EvalStatus eval_node(detection_option_tree_node_t* node,
                                Cursor cursor)
{
    IpsOption::EvalStatus eval_status;
    #if PIGASUS_DEBUG
    std::cout << "Evaluate node (option_type: " << node->option_type
              << ")" << std::endl;
    #endif

    if (node->option_type == RULE_OPTION_TYPE_LEAF_NODE) {
    #if PIGASUS_DEBUG
        std::cout << "Leaf node" << std::endl;
    #endif
        return IpsOption::EvalStatus::MATCH;
    }

    IpsOption* opt = (IpsOption*) node->option_data;

    #if PIGASUS_DEBUG
    std::cout << "rule name: " << opt->get_name() << std::endl;
    #endif

    if (node->option_type == RULE_OPTION_TYPE_CONTENT) {
        IpsOption* opt = (IpsOption*) node->option_data;

        #if PIGASUS_DEBUG
        std::cout << "rule name: " << opt->get_name() << std::endl;
        #endif

        eval_status = opt->eval(cursor, nullptr);
        if (eval_status != IpsOption::EvalStatus::MATCH) {
            return eval_status;
        }
    }

    for (int i = 0; i < node->num_children; ++i) {
        eval_status = eval_node(node->children[i], cursor);
        if (eval_status != IpsOption::EvalStatus::MATCH) {
            return eval_status;
        }
    }

    return IpsOption::EvalStatus::MATCH;
}

static inline IpsOption::EvalStatus eval_tree(
    detection_option_tree_root_t* root, Cursor cursor)
{
    IpsOption::EvalStatus eval_status;

    for (int i = 0; i < root->num_children; ++i) {
        eval_status = eval_node(root->children[i], cursor);
        if (eval_status != IpsOption::EvalStatus::MATCH) {
            return eval_status;
        }
    }

    return IpsOption::EvalStatus::MATCH;
}

static IpsOption::EvalStatus process_pdu_payload(PortGroup* port_group,
    uint8_t* data, long size, std::vector<uint16_t>& rule_sids)
{
    IpsOption::EvalStatus eval_status = IpsOption::EvalStatus::NO_MATCH;

    HyperscanMpse* so = dynamic_cast<HyperscanMpse*>(
        port_group->mpse[PM_TYPE_PKT]);

    cursor.set(name, data, size);

    for (auto rule_sid : rule_sids) {
        detection_option_tree_root_t* root;
        #if PIGASUS_DEBUG
        std::cout << "looking for rule sid: " << rule_sid << std::endl;
        #endif
        Pattern* patt = so->get_pattern_from_compressed_sid(rule_sid);
        if (patt == NULL) {
            continue;
        }
        root = (detection_option_tree_root_t*) patt->user_tree;

        #if PIGASUS_DEBUG
        std::cout << "evaluate sid: " << rule_sid << std::endl;
        #endif
        eval_status = eval_tree(root, cursor);
        
        if (eval_status != IpsOption::EvalStatus::NO_MATCH) {
            return eval_status;
        }
    }

    return eval_status;
}

static inline IpsOption::EvalStatus process_pdu(uint8_t* data, long size,
    uint16_t s_port, uint16_t d_port, std::vector<uint16_t>& rule_sids)
{
    IpsOption::EvalStatus eval_status = IpsOption::EvalStatus::NO_MATCH;
    PORT_RULE_MAP* tcp_prm = SnortConfig::get_conf()->prmTcpRTNX;
    PortGroup* src = nullptr, * dst = nullptr, * any = nullptr;

    #if PIGASUS_DEBUG
    std::cout << "d_port: " << d_port << "  s_port: " << s_port << std::endl; 
    #endif
    if (!prmFindRuleGroupTcp(tcp_prm, d_port, s_port, &src, &dst, &any)) {
        return eval_status; // no rule found for the specfied src and dst ports
    }
    if (dst) {
        #if PIGASUS_DEBUG
        std::cout << "dst:" << std::endl;
        #endif
        eval_status = process_pdu_payload(dst, data, size, rule_sids);
        if (eval_status != IpsOption::EvalStatus::NO_MATCH) {
            return eval_status;
        }
    }
    if (src) {
        #if PIGASUS_DEBUG
        std::cout << "src:" << std::endl;
        #endif
        eval_status = process_pdu_payload(src, data, size, rule_sids);
        if (eval_status != IpsOption::EvalStatus::NO_MATCH) {
            return eval_status;
        }
    }
    if (any) {
        #if PIGASUS_DEBUG
        std::cout << "any:" << std::endl;
        #endif
        eval_status = process_pdu_payload(any, data, size, rule_sids);
    }

    return eval_status;
}

void process_pdu(block_s* block)
{
    uint16_t* raw_sids = block->rule_id;

    for (uint16_t i = 0; i < (block->num_rule_id * NB_RULES_IN_LINE); ++i) {
        if (raw_sids[i]) {
            if (std::find(rule_sids_vector.begin(), rule_sids_vector.end(),
                        raw_sids[i]) == rule_sids_vector.end()) {
                rule_sids_vector.push_back(raw_sids[i]);
            }
        }
    }

    IpsOption::EvalStatus eval_status = process_pdu(block->pdu_payload,
        block->pdu_size, block->src_port, block->dst_port, rule_sids_vector);

    rule_sids_vector.clear();

    switch (eval_status)
    {
    case IpsOption::EvalStatus::NO_MATCH:
        ++no_match_cntr;
        break;
    case IpsOption::EvalStatus::MATCH:
        ++match_cntr;
        break;
    }
}

void init_rule_id_map(PortGroup* port_group)
{
    if (port_group == nullptr) {
        return;
    }

    for (int pg_type = PM_TYPE_PKT; pg_type < PM_TYPE_MAX; ++pg_type ) {
        Mpse* mpse = port_group->mpse[pg_type];

        if (mpse == nullptr) {
            continue;
        }
        // #if PIGASUS_DEBUG
        // std::cout << "pg type: " << pm_type_strings[pg_type] << std::endl;
        // #endif

        HyperscanMpse* so = dynamic_cast<HyperscanMpse*>(mpse);
        so->update_compressed_sid_id_map();
    }
}

void pigasus_init()
{
    signal(SIGINT, int_handler);

    // TODO(sadok): should we do other than TCP?
    PORT_RULE_MAP* tcp_prm = SnortConfig::get_conf()->prmTcpRTNX;
    // PORT_RULE_MAP* ip_prm = SnortConfig::get_conf()->prmIpRTNX;
    int port;

    for (port = 0; port < snort::MAX_PORTS; ++port) {
        init_rule_id_map(tcp_prm->prmDstPort[port]);
        init_rule_id_map(tcp_prm->prmSrcPort[port]);
    }
    init_rule_id_map(tcp_prm->prmGeneric);

    rule_sids_vector.reserve(MAX_NUM_RULE_IDS);
}

#if USE_FILE

void pigasus_loop()
{
    // HACK must be inside the lua dir when running
    // const char* data_file_name = "pdu0.bin";
    const char* data_file_name = "../test/test4/pdu3.bin";
    const char* rule_ids_file_name = "../test/test4/rule_ids3.txt";
    uint16_t s_port = 1025;
    uint16_t d_port = 1024;

    static std::vector<uint16_t> rule_sids_from_file;

    std::ifstream f(data_file_name);
    f.seekg(0, f.end);
    long size = f.tellg();
    f.seekg(0);
    char* data = new char[size];
    f.read(data, size);
    f.close();

    f = std::ifstream(rule_ids_file_name);
    uint16_t sid;
    while (f >> sid) {
        rule_sids_from_file.push_back(sid);
        #if PIGASUS_DEBUG
        std::cout << "sid: " << sid << std::endl;
        #endif
    }
    f.close();

    for (auto rule_sid : rule_sids_from_file) {
        if (std::find(rule_sids_vector.begin(), rule_sids_vector.end(),
                        rule_sid) == rule_sids_vector.end()) {
            rule_sids_vector.push_back(rule_sid);
            #if PIGASUS_DEBUG
            std::cout << "rule_sid: " << rule_sid << std::endl;
            #endif
        }
    }
    IpsOption::EvalStatus eval_status = process_pdu((uint8_t*) data, size,
        s_port, d_port, rule_sids_vector);
    rule_sids_vector.clear();


    print_eval_status(eval_status);

    delete[] data;
}

#else

void pigasus_loop()
{
    int result;
    block_s block;
    ssize_t dev_handle, uio_dev_handle;
    
    if (get_dev_handles(dev_handle, uio_dev_handle)) {
        FatalError("Problem contacting kernel module, is it loaded?\n");
    }

    if (ioctl(dev_handle, INTEL_FPGA_PCIE_IOCTL_CHR_USE_CMD, true)) {
        FatalError("Could not switch to CMD use mode!\n");
    }

    dma_run(dev_handle, uio_dev_handle, process_pdu, &keep_running);

    if (ioctl(dev_handle, INTEL_FPGA_PCIE_IOCTL_CHR_USE_CMD, false)) {
        FatalError("Could not switch out of CMD use mode!\n");
    }

    // print stats
    std::cout << std::dec;
    std::cout << "nb matches: " << match_cntr << std::endl;
    std::cout << "nb no matches: " << no_match_cntr << std::endl;
}

#endif  // USE_FILE

} // namespace snort
