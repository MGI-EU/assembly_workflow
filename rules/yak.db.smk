include: f"{workflow.basedir}/rules/parse.input.smk"


# yak db
rule yak_db_trio:
    input:
        paternal = get_files(config["paternal_short"]),
        maternal = get_files(config["maternal_short"])
    output:
        "yak/p.yak",
        "yak/m.yak"
    threads:
        config["yak_db_trio"]["cores"]
    resources:
        mem = config["yak_db_trio"]["mem"]
    singularity:
        config["singularity"]
    shell:
        """
        mkdir -p yak
        cd yak
        yak count -k31 -b37 -t{threads} -o m.yak {input.maternal}
        yak count -k31 -b37 -t{threads} -o p.yak {input.paternal}
        """