workdir: config["outdir"]
include: f"{workflow.basedir}/rules/parse.input.smk"
if config.get("paternal_short") and config.get("maternal_short"):
    include: f"{workflow.basedir}/rules/yak.db.smk"


# Meryl db from ONT
if not config.get("hifi") and not config.get("short") and config.get("ont"):
    rule meryl_db:
        input:
            fastq = get_files(config["ont"])
        output:
            directory("fastq.meryl")
        threads:
            config["meryl_db"]["cores"]
        resources:
            mem = config["meryl_db"]["mem"]
        singularity: 
            config["singularity"]
        shell:
            """
            meryl count k=31 threads={threads} {input.fastq} output fastq.meryl
            """
            
# Meryl db from short reads
if not config.get("hifi") and config.get("short"):
    rule meryl_db:
        input:
            fastq = get_files(config["short"])
        output:
            directory("fastq.meryl")
        threads:
            config["meryl_db"]["cores"]
        resources:
            mem = config["meryl_db"]["mem"]
        singularity: 
            config["singularity"]
        shell:
            """
            meryl count k=31 threads={threads} {input.fastq} output fastq.meryl
            """
            
# Meryl db from HiFi
if config.get("hifi"):
    rule meryl_db:
        input:
            fastq = get_files(config["hifi"])
        output:
            directory("fastq.meryl")
        threads:
            config["meryl_db"]["cores"]
        resources:
            mem = config["meryl_db"]["mem"]
        singularity: 
            config["singularity"]
        shell:
            """
            meryl count k=31 threads={threads} {input.fastq} output fastq.meryl
            """

# QUAST
if config.get("path_to_reference"):
    rule quast:
        input:
            assembly = "assembly.polished.ont.short.fasta",
            ref = config["path_to_reference"]
        output:
            "quast/report.tsv"
        threads:
            config["quast"]["cores"]
        resources:
            mem = config["quast"]["mem"]
        singularity:
            config["singularity"]
        shell:
            """
            quast.py -t {threads} -r {input.ref} {input.assembly} -o quast
            """

if not config.get("path_to_reference"):
    rule quast:
        input:
            assembly = "assembly.polished.ont.short.fasta"
        output:
            "quast/report.tsv"
        threads:
            config["quast"]["cores"]
        resources:
            mem = config["quast"]["mem"]
        singularity:
            config["singularity"]
        shell:
            """
            quast.py -t {threads} {input.assembly} -o quast
            """

# MERQURY
rule merqury:
    input:
        assembly = "assembly.polished.ont.short.fasta",
        meryl_db = "fastq.meryl"
    output:
        "merqury/completeness.stats",
        "merqury/merqury.qv"
    threads:
        config["merqury"]["cores"]
    resources:
        mem = config["merqury"]["mem"]
    singularity:
       config["singularity"]
    shell:
        """
        rm -rf merqury
        mkdir -p merqury
        cd merqury
        ${{MERQURY}}/merqury.sh ../{input.meryl_db} ../{input.assembly} merqury
        mv merqury.completeness.stats completeness.stats
        mv merqury.assembly.polished.ont.short.qv merqury.qv
        """

# Yak trioeval
if config.get("paternal_short") and config.get("maternal_short"):
    rule yak_trio_eval:
        input:
            assembly = "assembly.polished.ont.short.fasta",
            phapmers = "yak/p.yak",
            mhapmers = "yak/m.yak"
        output:
            "yak/report.tsv"
        params:
            sample = config.get("sample", "sample_name"),
        threads:
            config["yak_trio_eval"]["cores"]
        resources:
            mem = config["yak_trio_eval"]["mem"]
        singularity:
            config["singularity"]
        shell:
            """
            mkdir -p yak
            yak trioeval -t {threads} {input.phapmers} {input.mhapmers} {input.assembly} > yak/report.tsv
            """
