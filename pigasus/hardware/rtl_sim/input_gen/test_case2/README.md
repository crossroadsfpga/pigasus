This tests evaluate 16 packet with each packet contains the fast pattern of one rule. They should all match fast pattern matcher and port group matcher. Packet 1,2,3,4,9,16 should match non-fast-pattern matcher. The rest are filtered out by non-fast-pattern matcher because the other string patterns do not show up in the packet. Packet 16 is special, it is a false-positive, meaning that even though this packet should be filtered out by non-fast-pattern matcher, some rules are falsely triggered. These false-positives will be resolved by full matcher (not included in RTL simulation). 

Below are the sid of the rules(snort rules-29114).
25358,23616,21332,13898,33088,35051,37626,40888,48565,48626,49917,50519,26889,26887,26878,26876

