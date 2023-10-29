## Snakemake workflow for hybrid assembly
### Workflow steps:
1. Before-assembly correction [Ratatosk](https://github.com/DecodeGenetics/Ratatosk)
2. Assembly [Shasta](https://github.com/chanzuckerberg/shasta) or [Verkko](https://github.com/marbl/verkko) or [Hifiasm](https://github.com/chhylp123/hifiasm)
3. Filtering of small contigs
4. Polishing [PEPPER](https://github.com/kishwarshafin/pepper/tree/r0.1) + [Pilon](https://github.com/broadinstitute/pilon)
5. Quality control [QUAST](https://github.com/ablab/quast), [MERQURY](https://github.com/marbl/merqury), [Yak](https://github.com/lh3/yak)

### Dependencies
- [Conda](https://github.com/conda/conda)
- [Snakemake](https://snakemake.github.io/)
- [Singularity](https://singularity.hpcng.org)
  

### Installation
```bash

# Install Snakemake and Singularity
conda create -n assembly_workflow -y
conda activate assembly_workflow
conda install -c bioconda snakemake -y
conda install -c conda-forge singularity -y

# Pull and Converting .sif to sandbox (Highly recommended)
sudo singularity build --sandbox assembly_workflow/  library://eamozheiko/containers/assembly_workflow:1.4

# Pull Snakemake workflow
git clone https://github.com/MGI-EU/assembly_workflow.git
```

### Quick start
To run this worflow follow this steps:
1. Configure config.yaml and cluster.yaml
2. Download model for PEPPER ONT polishing if necessary. The model files for PEPPER are available here: [https://github.com/kishwarshafin/pepper/tree/r0.1/models](https://github.com/kishwarshafin/pepper/tree/r0.1/models)
3. Edit paths
```bash
conda activate assembly_workflow

# Edit this paths
PATH_TO_WORKFLOW=/home/user/assembly_workflow
MOUNT_HOST=/path/to/host/data
MOUNT_CONTAINER=/path/to/data/in/container

SFILE=${PATH_TO_WORKFLOW}/main.smk
CONFIG=${PATH_TO_WORKFLOW}/config.yaml
CLUSTER_CONFIG=${PATH_TO_WORKFLOW}/cluster.yaml
```
3. Run workflow

**Example:**
#### Cluster execution
```bash
snakemake \
    --snakefile ${SFILE} \
    --configfile ${CONFIG} ${CLUSTER_CONFIG} \
    --cluster-config ${CLUSTER_CONFIG} \
    --jobs 10 \
    --keep-going \
    --rerun-incomplete \
    --latency-wait 60 \
    --use-singularity \
    --singularity-args "--bind ${MOUNT_HOST}:${MOUNT_CONTAINER},${PATH_TO_WORKFLOW}:${PATH_TO_WORKFLOW}" \
    --cluster "qsub -V -cwd -P {cluster.project} -q {cluster.queue} -l vf={cluster.mem},p={cluster.cores} -binding linear:{cluster.cores} -o {cluster.output} -e {cluster.error}"
```
#### Local execution
```bash
snakemake \
    --use-singularity \
    --snakefile ${SFILE} \
    --configfile ${CONFIG} ${CLUSTER_CONFIG} \
    --singularity-args "--bind ${MOUNT_HOST}:${MOUNT_CONTAINER},${PATH_TO_WORKFLOW}:${PATH_TO_WORKFLOW}" \
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
   - Directory with fastq files
   - .fastq, .fastq.gz
   - .fofn

2. **Selection of Correction Tool in Config:**
   - Currently, only Ratatosk is available.
     - Example: correction: 'ratatosk'
   - Alternatively, use no-correction mode if "correction" variable is not specified in config.

3. **Selection of Assembly Tool:**
   - Available options in config: verkko, shasta, hifiasm.
     - Example: assembly: 'verkko'

4. **Optional Min Contig Filter:**
   - Default is 0.

5. **QC of Assembly:**
   - N50, NG50
   - Contig count
   - K-mers completeness
   - QV
   - Switch error
   - Hamming error



