
# HPC SLURM Automation for VASP 6.x

## Overview
This repository contains a production-ready Bash scripting architecture for deploying GPU-accelerated VASP (Vienna Ab initio Simulation Package) calculations on enterprise/national supercomputing clusters (e.g., Norwegian Sigma2/Betzy or EuroHPC LUMI).

## Architecture Highlights
* **GPU Scaling:** Configured for Multi-Node, Multi-GPU (NVIDIA A100) architecture using OpenACC-enabled VASP binaries to reduce HSE06 hybrid functional calculation times by up to 10x.
* **Memory Management:** Hard-coded RAM limits (`--mem=256G`) and optimized thread binding (`OMP_NUM_THREADS=1`) to prevent node-level Out-Of-Memory (OOM) crashes during heavy wavefunction iterations.
* **Automated CI/CD-style Pipeline:** The bash script doesn't just run the physics simulation. It actively parses the output file for convergence verification, and if successful, automatically triggers a Python-based post-processing toolkit to extract data and plot publication-ready graphics.

## Deployment
Submit the job to the SLURM workload manager using:
```bash
sbatch vasp_sigma2_gpu_submit.sh
