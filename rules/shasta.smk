include: f"{workflow.basedir}/rules/parse.input.smk"


if not config.get("correction"):
    rule shasta:
        input:
            ont = get_files(config["ont"])
        output:
            "assembly.fasta"
        threads:
            config["shasta"]["cores"]
        resources:
            mem = config["shasta"]["mem"]
        singularity:
            config["singularity"]
        shell:
            """
            rm -rf shasta
            shasta \
                --assemblyDirectory shasta \
                --threads {threads} \
                --config Nanopore-UL-Oct2021 \
                --input {input.ont}
            cp shasta/Assembly.fasta assembly.fasta

            """

# with correction rule
if config.get("correction"):
    rule shasta:
        input:
            ont = "ont.corrected.fastq"
        output:
            "assembly.fasta"
        threads:
            config["shasta"]["cores"]
        resources:
            mem = config["shasta"]["mem"]
        singularity:
            config["singularity"]
        shell:
            """
            rm -rf shasta
            shasta \
                --assemblyDirectory shasta \
                --threads {threads} \
                --config Nanopore-UL-Oct2021 \
                --input {input.ont}
            cp shasta/Assembly.fasta assembly.fasta

            """
