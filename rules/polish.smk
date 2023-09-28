include: f"{workflow.basedir}/rules/parse.input.smk"

# PEPPER, if ONT is available and no parental data
if not config.get("paternal_short") and config.get("ont") and config.get("polish_ont"):
    rule pepper:
        input:
            assembly = "assembly.filtred.fasta",
            ont = config["ont"],
            polish_model = config["polish_model"]
        output:
            "assembly.polished.ont.fasta"
        threads:
            config["pepper"]["cores"]
        resources:
            mem = config["pepper"]["mem"]
        singularity:
            config["singularity"]
        shell:
            """
            mkdir -p pepper
            cd pepper
            minimap2 -x map-ont -t {threads} -d pepper.mmi ../{input.assembly}
            minimap2 -ax map-ont -t {threads} pepper.mmi {input.ont} | samtools sort -@ {threads} | samtools view -@ {threads} -b > pepper.bam
            samtools index -@ {threads} pepper.bam


            pepper polish \
                --bam pepper.bam \
                --fasta ../{input.assembly} \
                --model_path {input.polish_model} \
                --output_file out \
                --threads {threads} \
                --batch_size 128
            cat out/_pepper_polished.fa > ../assembly.polished.ont.fasta
            """
else:
    rule blank_ont_polish:
        input:
            "assembly.filtred.fasta"
        output:
            "assembly.polished.ont.fasta"
        threads:
            config["blank_ont_polish"]["cores"]
        resources:
            mem = config["blank_ont_polish"]["mem"]
        singularity:
            config["singularity"]
        shell:
            """
            cp {input} {output}
            """

if config.get("short") and config.get("polish_short"):
    rule pilon:
        input:
            assembly = "assembly.polished.ont.fasta",
            short = config["short"]
        output:
            "assembly.polished.ont.short.fasta"
        threads:
            config["pilon"]["cores"]
        resources:
            mem = config["pilon"]["mem"]
        singularity:
            config["singularity"]
        shell:
            """
            mkdir -p pilon
            cd pilon
            rm -f reference.fasta
            ln -s ../{input.assembly} reference.fasta
            
            bwa index reference.fasta
            time bwa mem -t {threads} reference.fasta {input.short} | samtools sort -@ {threads} | samtools view -@ {threads} -b > pepper.bam
            samtools index pepper.bam

            pilon -Xms16G -Xmx16G \
                --bam pepper.bam \
                --genome reference.fasta \
                --threads {threads} \
                --output polished
            cat polished.fasta > ../assembly.polished.ont.short.fasta
            """
else:
    rule blank_short_polish:
        input:
            "assembly.polished.ont.fasta"
        output:
            "assembly.polished.ont.short.fasta"
        threads:
            config["blank_short_polish"]["cores"]
        resources:
            mem = config["blank_short_polish"]["mem"]
        singularity:
            config["singularity"]
        shell:
            """
            cp {input} {output}
            """
