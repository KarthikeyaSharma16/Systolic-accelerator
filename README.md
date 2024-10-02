## Instructions to install Icarus Verilog
`sudo apt install iverilog`  

`sudo apt install gtkwave`

## Run script
`./run.sh`

## TODOs:
- Optimize dataflow to support either weight stationary (or) input stationary (or) output stationary mapping.
- Include support for sparsity and scratchpads.
- Extend 4x4 to 16x16 architecture.
- Matrix mapping for convolution operation.
- Workload characterization?

## References
1. Sparse accelerator
    - https://arxiv.org/pdf/1708.04485
    - https://dl.acm.org/doi/pdf/10.1109/MICRO56248.2022.00096
2. Systolic accelerator Architectures
    - https://hparch.gatech.edu/papers/bahar_2020_meissa.pdf
    - https://arxiv.org/pdf/2211.12600
    - https://arxiv.org/pdf/1811.02883
    - https://ieeexplore.ieee.org/stamp/stamp.jsp?tp=&arnumber=9180403
    - https://tnm.engin.umich.edu/wp-content/uploads/sites/353/2020/08/2020.6.sparse-tpu_ics2020.pdf