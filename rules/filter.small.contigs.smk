# Filter small contigs, threshold=0 by defaults
rule filter_contigs:
    input:
        init_assembly = "assembly.fasta"
    output:
        assembly = "assembly.filtred.fasta"
    params:
        threshold = config.get("threshold", 0),
        workdir = config["outdir"]
    shell:
        """
        chmod +x {workflow.basedir}/scripts/filter_contigs.sh
        {workflow.basedir}/scripts/filter_contigs.sh {input.init_assembly} {params.threshold} {params.workdir}
        """
