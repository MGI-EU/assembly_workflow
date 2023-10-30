include: f"{workflow.basedir}/rules/parse.input.smk"
if config.get("paternal_short") and config.get("maternal_short"):
    include: f"{workflow.basedir}/rules/yak.db.smk"


if config.get("hifi") and not config.get("paternal_short") and not config.get("ont") and not config.get("correction"):
    rule hifiasm:
        input:
            hifi = get_files(config["hifi"])
        output:
            "assembly.fasta"
        threads:
            config["hifiasm"]["cores"]
        resources:
            mem = config["hifiasm"]["mem"]
        singularity:
            config["singularity"]
        shell:
            """
            rm -rf hifiasm
            mkdir -p hifiasm
            cd hifiasm
            hifiasm -o hifiasm -t {threads} {input.hifi}
            awk '/^S/ {{split($4,a,":"); print ">" $2; print $3}}' *.p_utg.gfa > ../assembly.fasta
            """


if config.get("hifi") and not config.get("paternal_short") and config.get("ont") and not config.get("correction"):
    rule hifiasm:
        input:
            ont = get_files(config["ont"]),
            hifi = get_files(config["hifi"])
        output:
            "assembly.fasta"
        threads:
            config["hifiasm"]["cores"]
        resources:
            mem = config["hifiasm"]["mem"]
        singularity:
            config["singularity"]
        shell:
            """
            rm -rf hifiasm
            mkdir -p hifiasm
            cd hifiasm
            echo {input.ont} | tr ' ' '\n' > ont.hifiasm.fofn
            while read -r line; do
              # Extract just the filename from the full path
              filename=$(basename -- "$line")
              
              # If the file is a .fastq file, simply add its original path to the new fofn
              if [[ $line == *.fastq ]]; then
                echo "$line" >> ont.fastq.unziped.fofn
              # If the file is a .fastq.gz file, unzip it to a new .fastq file in the current directory and add the new file to the new fofn
              elif [[ $line == *.fastq.gz ]]; then
                new_file="${{filename%.gz}}"
                gunzip -c "$line" > "./$new_file"
                echo "$(pwd)/$new_file" >> ont.fastq.unziped.fofn
                echo "$(pwd)/$new_file" >> ont.fastq.to.rm.fofn
              fi
            done < ont.hifiasm.fofn

            while read -r line; do cat "$line"; done < ont.fastq.unziped.fofn > ont.combined.fastq
            hifiasm -o hifiasm -t {threads} --ul ont.combined.fastq {input.hifi}
            awk '/^S/ {{split($4,a,":"); print ">" $2; print $3}}' *.p_utg.gfa > ../assembly.fasta


            rm ont.combined.fastq
            rm ont.hifiasm.fofn
            while read -r line; do rm "$line"; done < ont.fastq.to.rm.fofn
            rm ont.fastq.to.rm.fofn
            rm ont.fastq.unziped.fofn
            """


if config.get("hifi") and config.get("paternal_short") and config.get("maternal_short") and not config.get("ont") and not config.get("correction"):
    rule hifiasm:
        input:
            hifi = get_files(config["hifi"]),
            phapmers = "yak/p.yak",
            mhapmers = "yak/m.yak"
        output:
            "assembly.fasta"
        threads:
            config["hifiasm"]["cores"]
        resources:
            mem = config["hifiasm"]["mem"]
        singularity:
            config["singularity"]
        shell:
            """
            rm -rf hifiasm
            mkdir -p hifiasm
            cd hifiasm
            hifiasm -o hifiasm -t {threads} -1 ../{input.phapmers} -2 ../{input.mhapmers} {input.hifi}
            awk '/^S/ {{split($4,a,":"); print ">" $2; print $3}}' *.p_utg.gfa > ../assembly.fasta
            """

if config.get("hifi") and config.get("paternal_short") and config.get("maternal_short") and config.get("ont") and not config.get("correction"):
    rule hifiasm:
        input:
            ont = get_files(config["ont"]),
            hifi = get_files(config["hifi"]),
            phapmers = "yak/p.yak",
            mhapmers = "yak/m.yak"
        output:
            "assembly.fasta"
        threads:
            config["hifiasm"]["cores"]
        resources:
            mem = config["hifiasm"]["mem"]
        singularity:
            config["singularity"]
        shell:
            """
            rm -rf hifiasm
            mkdir -p hifiasm
            cd hifiasm
            echo {input.ont} | tr ' ' '\n' > ont.hifiasm.fofn
            while read -r line; do
              # Extract just the filename from the full path
              filename=$(basename -- "$line")
              
              # If the file is a .fastq file, simply add its original path to the new fofn
              if [[ $line == *.fastq ]]; then
                echo "$line" >> ont.fastq.unziped.fofn
              # If the file is a .fastq.gz file, unzip it to a new .fastq file in the current directory and add the new file to the new fofn
              elif [[ $line == *.fastq.gz ]]; then
                new_file="${{filename%.gz}}"
                gunzip -c "$line" > "./$new_file"
                echo "$(pwd)/$new_file" >> ont.fastq.unziped.fofn
                echo "$(pwd)/$new_file" >> ont.fastq.to.rm.fofn
              fi
            done < ont.hifiasm.fofn

            while read -r line; do cat "$line"; done < ont.fastq.unziped.fofn > ont.combined.fastq
            hifiasm -o hifiasm -t {threads} --ul ont.combined.fastq -1 ../{input.phapmers} -2 ../{input.mhapmers} {input.hifi}
            awk '/^S/ {{split($4,a,":"); print ">" $2; print $3}}' *.p_utg.gfa > ../assembly.fasta


            rm ont.combined.fastq
            rm ont.hifiasm.fofn
            while read -r line; do rm "$line"; done < ont.fastq.to.rm.fofn
            rm ont.fastq.to.rm.fofn
            rm ont.fastq.unziped.fofn
            """

###################################################################################
## rules with correction 
###################################################################################

if config.get("hifi") and not config.get("paternal_short") and config.get("ont") and config.get("correction"):
    rule hifiasm:
        input:
            ont = "ont.corrected.fastq",
            hifi = get_files(config["hifi"])
        output:
            "assembly.fasta"
        threads:
            config["hifiasm"]["cores"]
        resources:
            mem = config["hifiasm"]["mem"]
        singularity:
            config["singularity"]
        shell:
            """
            rm -rf hifiasm
            mkdir -p hifiasm
            cd hifiasm
            hifiasm -o hifiasm -t {threads} --ul ../{input.ont} {input.hifi}
            awk '/^S/ {{split($4,a,":"); print ">" $2; print $3}}' *.p_utg.gfa > ../assembly.fasta
            """



if config.get("hifi") and config.get("paternal_short") and config.get("maternal_short") and config.get("ont") and config.get("correction"):
    rule hifiasm:
        input:
            ont = "ont.corrected.fastq",
            hifi = get_files(config["hifi"]),
            phapmers = "yak/p.yak",
            mhapmers = "yak/m.yak"
        output:
            "assembly.fasta"
        threads:
            config["hifiasm"]["cores"]
        resources:
            mem = config["hifiasm"]["mem"]
        singularity:
            config["singularity"]
        shell:
            """
            rm -rf hifiasm
            mkdir -p hifiasm
            cd hifiasm
            hifiasm -o hifiasm -t {threads} --ul ../{input.ont} -1 ../{input.phapmers} -2 ../{input.mhapmers} {input.hifi}
            awk '/^S/ {{split($4,a,":"); print ">" $2; print $3}}' *.p_utg.gfa > ../assembly.fasta
            """
