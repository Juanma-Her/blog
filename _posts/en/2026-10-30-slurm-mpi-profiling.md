---
title: "What I learned profiling MPI jobs under Slurm"
date: 2026-10-30
description: "Most of our slowdown was in the job script, not in the code."
tags: [hpc, mpi]
ref: slurm-mpi-profiling
---

Sample post for the HPC topic. Real content arrives in M4.

```bash
#!/bin/bash
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=32
srun --cpu-bind=cores ./solver input.dat
```
{: data-file="jobs/solver.sbatch"}

Strong scaling efficiency on $$p$$ processes is $$E(p) = \frac{T_1}{p \, T_p}$$.
