//--------------------------------------------------------------------------
// Copyright (C) 2015-2018 Cisco and/or its affiliates. All rights reserved.
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

// hyperscan.cc author Russ Combs <rucombs@cisco.com>

#ifndef HYPERSCAN_H
#define HYPERSCAN_H

#ifdef HAVE_CONFIG_H
#include "config.h"
#include <iostream>
#endif

#include <hs_compile.h>
#include <hs_runtime.h>

#include <cassert>
#include <cstring>
#include <unordered_map>

#include "detection/fp_create.h"
#include "detection/treenodes.h"
#include "framework/mpse.h"
#include "log/messages.h"
#include "main/snort_config.h"
#include "utils/stats.h"

#define likely(x)       __builtin_expect((x),1)
#define unlikely(x)     __builtin_expect((x),0)

namespace snort
{

struct Pattern
{
    std::string pat;
    unsigned len;
    unsigned flags;
    bool no_case;
    bool negate;

    void* user;
    void* user_tree;
    void* user_list;

    Pattern(const uint8_t*, unsigned, const Mpse::PatternDescriptor&, void*);
    void escape(const uint8_t*, unsigned, bool);
};

typedef std::vector<Pattern> PatternVector;

//-------------------------------------------------------------------------
// mpse
//-------------------------------------------------------------------------

class HyperscanMpse : public Mpse
{
public:
    HyperscanMpse(SnortConfig*, const MpseAgent* a)
        : Mpse("hyperscan")
    {
        agent = a;
        ++instances;
#ifdef PIGASUS
        compressed_sid_id_map_outdated = false;
#endif
    }

    ~HyperscanMpse() override
    {
        if ( hs_db )
            hs_free_database(hs_db);

        if ( agent )
            user_dtor();
    }

    int add_pattern(
        SnortConfig*, const uint8_t* pat, unsigned len,
        const PatternDescriptor& desc, void* user) override
    {
        Pattern p(pat, len, desc, user);
        pvector.emplace_back(p);
        ++patterns;
#ifdef PIGASUS
        compressed_sid_id_map_outdated = true;
#endif
        return 0;
    }

#ifdef PIGASUS
    void update_compressed_sid_id_map() {
	    uint32_t sid, compressed_sid;

        compressed_sid_id_map.clear();
        for (int i = 0; i < pvector.size(); ++i) {
            PMX* pmx = (PMX*) pvector[i].user;
            OptTreeNode* otn = (OptTreeNode*) pmx->rule_node.rnRuleData;
            sid = otn->sigInfo.sid;
            try {
                compressed_sid = SnortConfig::sid_compressed_sid_map.at(sid);
                compressed_sid_id_map[compressed_sid] = i;
            } catch (const std::out_of_range& e) {
                // std::cout << "Warning: rule with SID " << sid << " was loaded but does not have an equivalent compressed SID" << std::endl;
            }
        }
        compressed_sid_id_map_outdated = false;
    }
#endif

    int prep_patterns(SnortConfig*) override;

    int _search(const uint8_t*, int, MpseMatch, void*, int*) override;

    int get_pattern_count() override
    { return pvector.size(); }

    int match(unsigned id, unsigned long long to);

    static int match(
        unsigned id, unsigned long long from, unsigned long long to,
        unsigned flags, void*);

#ifdef PIGASUS
    Pattern& get_pattern_from_id(unsigned id)
    { return pvector[id]; }

    Pattern* get_pattern_from_compressed_sid(unsigned compressed_sid) {
        auto it = compressed_sid_id_map.find(compressed_sid);
        if (it == compressed_sid_id_map.end()) {
            return NULL;
        }
        return &pvector[it->second];
    }
#endif

private:
    void user_ctor(SnortConfig*);
    void user_dtor();

    const MpseAgent* agent;
    PatternVector pvector;

    hs_database_t* hs_db = nullptr;

    static THREAD_LOCAL MpseMatch match_cb;
    static THREAD_LOCAL void* match_ctx;
    static THREAD_LOCAL int nfound;

#ifdef PIGASUS
    /*
     * The FPGA is only aware of Compressed SIDs, we need a map from Compressed 
     * SIDs to the IDs used internally by HyperscanMpse
     */
    std::unordered_map<uint32_t, uint32_t> compressed_sid_id_map;
    bool compressed_sid_id_map_outdated;
#endif

public:
    static uint64_t instances;
    static uint64_t patterns;
};

}

#endif // HYPERSCAN_H

