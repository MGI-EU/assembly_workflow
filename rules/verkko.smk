include: f"{workflow.basedir}/rules/parse.input.smk"

rule meryl_db_trio:
    input: 
        paternal = get_files(config["paternal_short"]),
        maternal = get_files(config["maternal_short"])
    output: 
        directory("meryl/p.compress.only.meryl"),
        directory("meryl/m.compress.only.meryl")
    threads:
        config["meryl_db_trio"]["cores"]
    resources:
        mem = config["meryl_db_trio"]["mem"]
    singularity:
        config["singularity"]
    shell:
        """
        mkdir -p meryl
        cd meryl
        meryl count compress k=31 threads={threads} {input.paternal} output p.compress.meryl
        meryl count compress k=31 threads={threads} {input.maternal} output m.compress.meryl
        ${{CONDA_PREFIX}}/share/merqury/trio/hapmers.sh m.compress.meryl p.compress.meryl
        """

if config.get("hifi") and not config.get("short") and not config.get("ont") and not config.get("correction"):
    rule verkko:
        input:
            hifi = get_files(config["hifi"])
        output:
            "assembly.fasta"
        threads:
            config["verkko"]["cores"]
        resources:
            mem = config["verkko"]["mem"]
        singularity:
            config["singularity"]
        shell:
            """
            verkko -d verkko \
                --hifi {input.hifi} \
                --no-nano \
                --threads {threads}

            cp verkko/assembly.fasta assembly.fasta
            """

if config.get("hifi") and not config.get("short") and config.get("ont") and not config.get("correction"):
    rule verkko:
        input:
            ont = get_files(config["ont"]),
            hifi = get_files(config["hifi"])
        output:
            "assembly.fasta"
        threads:
            config["verkko"]["cores"]
        resources:
            mem = config["verkko"]["mem"]
        singularity:
            config["singularity"]
        shell:
            """
            verkko -d verkko \
                --hifi {input.hifi} \
                --nano {input.ont} \
                --threads {threads}

            cp verkko/assembly.fasta assembly.fasta
            """


if config.get("hifi") and config.get("short") and not config.get("ont") and not config.get("correction"):
    rule verkko:
        input:
            hifi = get_files(config["hifi"]),
            phapmers = directory("meryl/p.compress.only.meryl"),
            mhapmers = directory("meryl/m.compress.only.meryl")
        output:
            "assembly.fasta"
        threads:
            config["verkko"]["cores"]
        resources:
            mem = config["verkko"]["mem"]
        singularity:
            config["singularity"]
        shell:
            """
            verkko -d verkko \
                --hifi {input.hifi} \
                --no-nano \
                --threads {threads} \
                --hap-kmers {input.phapmers} \
                            {input.mhapmers} \
                            trio

            cp verkko/assembly.fasta assembly.fasta
            """

if config.get("hifi") and config.get("short") and config.get("ont") and not config.get("correction"):
    rule verkko:
        input:
            ont = get_files(config["ont"]),
            hifi = get_files(config["hifi"]),
            phapmers = directory("meryl/p.compress.only.meryl"),
            mhapmers = directory("meryl/m.compress.only.meryl")
        output:
            "assembly.fasta"
        threads:
            config["verkko"]["cores"]
        resources:
            mem = config["verkko"]["mem"]
        singularity:
            config["singularity"]
        shell:
            """
            verkko -d verkko \
                --hifi {input.hifi} \
                --nano {input.ont} \
                --threads {threads} \
                --hap-kmers {input.phapmers} \
                            {input.mhapmers} \
                            trio

            cp verkko/assembly.fasta assembly.fasta
            """
###################################################################################
## rules with correction 
###################################################################################

if config.get("hifi") and not config.get("short") and config.get("ont") and config.get("correction"):
    rule verkko:
        input:
            ont = "ont.corrected.fastq",
            hifi = get_files(config["hifi"])
        output:
            "assembly.fasta"
        threads:
            config["verkko"]["cores"]
        resources:
            mem = config["verkko"]["mem"]
        singularity:
            config["singularity"]
        shell:
            """
            verkko -d verkko \
                --hifi {input.hifi} \
                --nano {input.ont} \
                --threads {threads}

            cp verkko/assembly.fasta assembly.fasta
            """

if config.get("hifi") and config.get("short") and config.get("ont") and config.get("correction"):
    rule verkko:
        input:
            ont = "ont.corrected.fastq",
            hifi = get_files(config["hifi"]),
            phapmers = lambda wildcards: directory("meryl/p.compress.only.meryl") if "ont" in config else [],
            mhapmers = lambda wildcards: directory("meryl/m.compress.only.meryl") if "ont" in config else []
        output:
            "assembly.fasta"
        threads:
            config["verkko"]["cores"]
        resources:
            mem = config["verkko"]["mem"]
        singularity:
            config["singularity"]
        shell:
            """
            verkko -d verkko \
                --hifi {input.hifi} \
                --nano {input.ont} \
                --threads {threads} \
                --hap-kmers {input.phapmers} \
                            {input.mhapmers} \
                            trio

            cp verkko/assembly.fasta assembly.fasta
            """
