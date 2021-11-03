# Pigasus Releases

## Pigasus 2.0
Pigasus 2.0 makes the following main updates:
* Disaggregates Pigasus 1.0 into smaller component with natural module boundaries.
* Standardizes the interfaces between components to allow for easier composition.
* Parameterization for achieving different performance-resource tradeoffs.
* Leverages a minimal-version of the Fluid framework to easily recompose Pigasus designs at python level.
* Supports FPGA-to-FPGA networked connection with credit-based flow control enabling multi-FPGA scaling.
* Redesigns rule reduction logic to facilitate automation through a python template.
* Fixes several corner-case bugs.

## Pigasus 1.0
Pigasus 1.0 is kept at the `legacy` branch in the current repository.
Following are the key updates since the release of Pigasus 1.0:
* Optimizing the multiplication operation. After optimization, DSP utilization becomes 0 and the LUT ultilzation stays almost the same. (Credits to Dr. Moein Khazraee.)
* Support for the production MX dev board with part number 1SM21BHU2F53E1VG.
* Add a sample rule for the sample input packet trace.
* Fix bugs of Flow reassembly race conditions.
