## Snakemake workflow for hibrid assembly
Worflow steps:
1. Before-assembly correction (Ratatosk)
2. Assembly (Shasta, Verkko, Hifiasm)
3. Filtering of small contigs
4. Polishing (PEPPER + Pilon)
5. Quality control (QUAST, MERQURY, Yak)

### Dependencies
1. Snakemake
2. Singularity
  

### Installation
```bash
# Install Snakemake
conda install -c bioconda snakemake

# Install Singularity
conda install -c conda-forge singularity

# Pull singularity container
singularity pull --arch amd64 library://eamozheiko/containers/assembly_workflow:1.3

# Pull Snakemake workflow

```

### Quick start
1. Configure config.yaml and cluster.yaml



#### Input:
    HiFi, ONT, paternal NGS, maternal NGS, child NGS (Assembly parameters automaticaly depends on input)
    
#### Output:

{outdir}/result/report.tsv, "outdir" can be specified in config
    
#### Features:

1. Possible input
a. directory with fastq
b. .fastq, .fastq.gz
c. .fofn

2. Selection of correction tool in config (only Ratatosk now), or nocorrection mode if "correction" variable not specified in config
Example, type in config: correction: 'ratatosk'

3. Selection of assembly tool (verkko, shasta, hifiasm)
Example, type in config: assembly: 'verkko'

4. Optional min contig filter (0, by default)

5. QC of assembly: QUAST, Merqury, Yak
  a. N50, NG50
  b. Contig count
  c. K-mers completeness
  d. QV
  e. Switch error
  f. Hamming error

#### Usage Cluster execution

Example:
```bash
source /hwfssz8/MGI_LATVIA/BIT/mgi_lvprod/eamozheiko/soft/miniconda3/bin/activate
conda activate snakemake
PATH_TO_SMK=/media/evgeniy/OS/fastq/asm_smk_v1.3
SFILE=${PATH_TO_SMK}/main.smk
CLUSTER_CONFIG=${PATH_TO_SMK}/cluster.yaml
CONFIG=${PATH_TO_SMK}/config.yaml
snakemake \
--snakefile ${SFILE} \
--configfile ${CONFIG} ${CLUSTER_CONFIG} \
--use-singularity \
--cores 2
```
