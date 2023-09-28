include: f"{workflow.basedir}/rules/parse.input.smk"
        

# Ratatosk
rule ratatosk:
    input:
        short = get_files(config["short"]),
        ont = get_files(config["ont"])
    output:
        "ont.corrected.fastq"
    threads:
        config["ratatosk"]["cores"]
    resources:
        mem = config["ratatosk"]["mem"]
    singularity:
        config["singularity"]
    shell:
        """
        mkdir -p ratatosk
        cd ratatosk
        Ratatosk correct -v -c 7 -s {input.short} -l {input.ont} -o ratatosk
        chmod +x {workflow.basedir}/scripts/replaceIUPAC.py
        {workflow.basedir}/scripts/replaceIUPAC.py ratatosk.fastq > ../ont.corrected.fastq
        rm ratatosk.fastq
        """
