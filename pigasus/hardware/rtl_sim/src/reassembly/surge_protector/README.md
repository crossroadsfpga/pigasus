# SurgeProtector: Mitigating Temporal Algorithmic Complexity Attacks (ACAs) using Adversarial Scheduling

## Algorithmic Complexity Attacks (ACAs)
Many Network Functions (NFs) on the Internet are inherently vulnerable to temporal Algorithmic Complexity Attacks (ACAs), a highly potent class of Denial-of-Service (DoS) attacks targeting the algorithms and/or data-structures underlying the NFs. With an ACA, an attacker crafts carefully-designed inputs that require a _small amount of network and compute resources_ for the attacker to produce, and yet consume a _large amount of compute resources_ at the target system. Given a sufficient request rate, an attacker can drive the victim into overload, causing it to drop requests from the innocent, intended users of the service. ACAs are particularly dangerous because they allow a adversary with only modest resources to overload a much more powerful service (e.g., an attacker producing just 100Mbps of adversarial traffic may be able to overwhelm an NF provisioned to handle 10Gbps in the common case).

## ACA Vulnerability in Pigasus
In order to detect attack signatures spanning multiple TCP segments, Pigasus performs TCP reassembly (i.e., the process of reconstructing a TCP bytestream from a sequence of order-of-order packets) for each out-of-order flow. Given the limited BRAM available aboard FPGAs, the Pigasus reassembler prioritizes memory efficiency, and employs a linked list-based design to manage out-of-order flow state. While this achieves excellent memory utilization, the worst-case linear complexity of linked-list operations makes it susceptible to ACAs. An example of the vulnerability is illustrated below.

<p align="center">
  <img width="400" src=https://user-images.githubusercontent.com/6562132/159199150-52c2ad6a-1b1f-409f-904a-729a44d03efb.png>
</p>

When a new packet arrives (with PSN range \[35, 50) in the above figure), the reassembler linearly scans the list and inserts the node at the appropriate position. In order to exploit this, an attacker crafts _highly out-of-order flows_, linearly increasing the number of traversals required for each subsequent attack packet. Finally, they use _minimum-sized packets_ (with a 1-byte TCP payload) to inflate their packet arrival rate, maximizing the work injected into the system. We find that this is a highly effective DoS attack against Pigasus, allowing the attacker to displace ~9.5Gbps of innocent traffic using just 500Mbps of attack bandwidth.

## SurgeProtector
SurgeProtector is a scheduling framework developed at CMU that mitigates the impact of ACAs on NFs (such as Pigasus) using novel insights from adversarial scheduling theory. SurgeProtector interposes a _scheduler_ between the vulnerable component and its ingress link, which in turn decides the order in which packets are served by the NF. The key ingredient for ACA mitigation is the novel scheduling policy underlying the SurgeProtector scheduler: **Packet-Size Weighted Shortest-Job First (WSJF)**. While details are elided for the sake of brevity (please refer to the full research paper), WSJF imposes a theoretical upper-bound on the "harm" an adversary can induce via ACAs. In particular, it guarantees that, _to displace 1 bit-per-second (bps) of innocent traffic, the adversary must inject **at least** 1 bps of their own bandwidth into the attack_, significantly reducing the potency of ACAs. Further, this bound is independent of the load on the server, the packet and job size distributions for innocent traffic, and the underlying application itself. Thus, SurgeProtector represents a _general_ ACA mitigation strategy that is not tied to any specific NF.

This directory contains part of the source code used to implement SurgeProtector in the context of the Pigasus Reassembler (the scheduler itself is implemented in `scheduler_reassembly.sv`, which can be found in the parent directory). A brief description of each file is provided below:
- ffs.sv: Implements the _Find First Set_ operation to find the index of the least- and most-significant set bit in a given bitvector
- pipelined_heap.sv: Implements a fully pipelined min+max heap using a two-level Hierarchical Find-First Set (HFFS) queue; the heap supports `Insert`, `ExtractMin`, and `ExtractMax` operations, all with constant worst-case time complexity and a throughput of 1 op/cycle
- pipelined_heap_wrapper.sv: A wrapper for the pipelined_heap module that provides limited support for multiple ops/cycle and a more convenient heap interface
- heap_ops_pkg.sv: Package defining the available heap operations (`Insert`, `ExtractMin`, `ExtractMax`)
- bounded_wsjf_queue.sv: Implements the policy underlying SurgeProtector (Packet-Size Weighted Shortest-Job First) using the pipelined_heap data-structure

**IMPORTANT**: SurgeProtector is provided as an optional feature that is disabled by default. To enable it, uncomment ``// `define ENABLE_SURGEPROTECTOR`` in `pigasus.py`.
