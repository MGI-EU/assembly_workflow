workdir: config["outdir"]

import os

# Create directories if they don't exist
singularity_cache_dir = f"{outdir}/singularity_cache"
singularity_tmp_dir = f"{outdir}/singularity_tmp"

os.makedirs(singularity_cache_dir, exist_ok=True)
os.makedirs(singularity_tmp_dir, exist_ok=True)

# Set Singularity cache and tmp directories to config["outdir"]
os.environ['SINGULARITY_CACHEDIR'] = singularity_cache_dir
os.environ['SINGULARITY_TMPDIR'] = singularity_tmp_dir

include: f"{workflow.basedir}/rules/parse.input.smk"
if config.get("correction"):
    include: f"{workflow.basedir}/rules/{config['correction']}.smk"
include: f"{workflow.basedir}/rules/{config.get('assembly', 'hifiasm')}.smk"
include: f"{workflow.basedir}/rules/filter.small.contigs.smk"
include: f"{workflow.basedir}/rules/assembly.quality.control.smk"
include: f"{workflow.basedir}/rules/polish.smk"
include: f"{workflow.basedir}/rules/report.smk"


rule all:
    input:
        "result/report.tsv",  # Final output file
        
