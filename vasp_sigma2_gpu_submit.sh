#!/bin/bash
# ==============================================================================
# VASP 6.x GPU-Accelerated SLURM Submission Script
# Author: Murugesan Rasukkannu 
# Role: Senior Computational Physicist & Hardware Systems Engineer
# Target Architecture: Norwegian Sigma2 (Betzy/Fram) or EuroHPC (LUMI)
# ==============================================================================

#SBATCH --job-name=HSE06_BandStruct
#SBATCH --account=nn9999k                # Replace with active Sigma2 project ID
#SBATCH --partition=accel                 # GPU partition 
#SBATCH --nodes=2                        # Multi-node scaling
#SBATCH --ntasks-per-node=8              # MPI ranks per node
#SBATCH --gpus-per-node=4                # NVIDIA A100 GPU allocation
#SBATCH --mem=256G                       # Hard memory limit to prevent OOM kills
#SBATCH --time=48:00:00                  # Wall clock time limit (48 Hours)
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=rmrmurugesh@gmail.com

# 1. Environment Purge and Module Loading
echo "--- Initializing HPC Environment ---"
module purge
module load Python/3.10.4-GCCcore-11.3.0
module load VASP/6.3.2-foss-2022a-CUDA-11.7.0  # OpenACC enabled VASP binary

# 2. OpenMP Thread Optimization for Hybrid MPI/OpenMP
export OMP_NUM_THREADS=1
export MKL_NUM_THREADS=1

# 3. Directory and Data Management
export WORK_DIR=${SLURM_SUBMIT_DIR}
cd ${WORK_DIR}

echo "Starting VASP GPU calculation at $(date)"
echo "Allocated Nodes: ${SLURM_JOB_NODELIST}"

# 4. Quantum Simulation Execution
# Utilizing srun for optimal MPI binding on SLURM architecture
srun --mpi=pmi2 vasp_std > vasp_terminal.out

echo "VASP simulation completed at $(date)"

# 5. Automated Data Pipeline Trigger
# Immediately launch the Python post-processing toolkit upon successful convergence
if grep -q "reached required accuracy" vasp_terminal.out; then
    echo "Convergence verified. Triggering Advanced Post-Processing..."
    python3 advanced_post_processing.py
else
    echo "WARNING: VASP calculation did not converge normally. Skipping post-processing."
    exit 1
fi

echo "--- Full Pipeline Execution Complete ---"
