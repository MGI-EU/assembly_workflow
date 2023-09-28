workdir: config["outdir"]


envvars: 
     "SINGULARITY_CACHEDIR",
     "SINGULARITY_TMPDIR"

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
        