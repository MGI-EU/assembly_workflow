## Snakemake workflow for hybrid assembly
### Workflow steps:
1. Before-assembly correction (Ratatosk)
2. Assembly (Shasta, Verkko, Hifiasm)
3. Filtering of small contigs
4. Polishing (PEPPER + Pilon)
5. Quality control (QUAST, MERQURY, Yak)

### Dependencies
1. Conda
1. Snakemake
3. Singularity
  

### Installation
```bash

# Install Snakemake and Singularity
conda create -n assembly_workflow
conda activate assembly_workflow
conda install -c bioconda snakemake
conda install -c conda-forge singularity

# Pull singularity container
singularity pull --arch amd64 library://eamozheiko/containers/assembly_workflow:1.3

# Pull Snakemake workflow
git clone https://github.com/eamozheiko/assembly_workflow.git
```

### Quick start
To run this worflow follow this steps:
1. Configure config.yaml and cluster.yaml
2. Download model for PEPPER ONT polishing if necessary
3. Edit run command
**Example:**
#### Cluster execution
```bash
conda activate assembly_workflow
PATH_TO_SMK=/home/user/assembly_workflow
SFILE=${PATH_TO_SMK}/main.smk
CLUSTER_CONFIG=${PATH_TO_SMK}/cluster.yaml
CONFIG=${PATH_TO_SMK}/config.yaml
snakemake \
    --use-singularity \
    --snakefile ${SFILE} \
    --configfile ${CONFIG} ${CLUSTER_CONFIG} \
    --cluster-config ${CLUSTER_CONFIG} \
    --jobs 10 \
    --keep-going \
    --rerun-incomplete \
    --latency-wait 60 \
    --use-singularity \
    --singularity-args "--bind /path/to/you/data:/data" \
    --cluster "qsub -V -cwd -P {cluster.project} -q {cluster.queue} -l vf={cluster.mem},p={cluster.cores} -binding linear:{cluster.cores} -o {cluster.output} -e {cluster.error}"
```
#### Local execution
```bash
conda activate assembly_workflow
PATH_TO_SMK=/home/user/assembly_workflow
SFILE=${PATH_TO_SMK}/main.smk
CLUSTER_CONFIG=${PATH_TO_SMK}/cluster.yaml
CONFIG=${PATH_TO_SMK}/config.yaml
snakemake \
    --use-singularity \
    --snakefile ${SFILE} \
    --configfile ${CONFIG} ${CLUSTER_CONFIG} \
    --use-singularity \
    --singularity-args "--bind /path/to/you/data:/data" \
    --cores 4
```

### Workflow description
#### Input:
Fastq files of HiFi, ONT, paternal NGS, maternal NGS, child NGS (Assembly parameters automaticaly depends on input).
You don't need all this fastq input, you only need HiFi or ONT as the basis of the assembly.
    
#### Output:

{outdir}/result/report.tsv, "outdir" can be specified in config.
    
#### Features:

1. **Possible Input:**
   a. Directory with fastq files
   b. .fastq, .fastq.gz
   c. .fofn

2. **Selection of Correction Tool in Config:**
   - Currently, only Ratatosk is available.
   - Alternatively, use no-correction mode if "correction" variable is not specified in config.
     - Example: In config, type correction: 'ratatosk'

3. **Selection of Assembly Tool:**
   - Available options: verkko, shasta, hifiasm.
     - Example: In config, type assembly: 'verkko'

4. **Optional Min Contig Filter:**
   - Default is 0.

5. **QC of Assembly:**
   a. N50, NG50
   b. Contig count
   c. K-mers completeness
   d. QV
   e. Switch error
   f. Hamming error



