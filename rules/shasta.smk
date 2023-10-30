include: f"{workflow.basedir}/rules/parse.input.smk"
import os
import shutil
import gzip

def unzip_and_collect_files(input_files):
    tmp_dir = os.path.join(config["outdir"], "tmp_unzip")
if not os.path.exists(tmp_dir):
        os.makedirs(tmp_dir)
    
    all_files = []
    
    for file in input_files:
        if file.endswith('.gz'):
            with gzip.open(file, 'rb') as f_in:
                unzipped_name = os.path.join(tmp_dir, os.path.basename(file)[:-3])
                with open(unzipped_name, 'wb') as f_out:
                    shutil.copyfileobj(f_in, f_out)
            all_files.append(unzipped_name)
        else:
            all_files.append(file)
    
    return ' '.join(all_files)


if not config.get("correction"):
    rule shasta:
        input:
            ont = get_files(config["ont"])
        params:
            all_files = lambda wildcards, input: unzip_and_collect_files(input.ont)
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
                --input {params.all_files}

            cp shasta/Assembly.fasta assembly.fasta

            # Remove the temp directory
            rm -rf tmp_unzip
            """
            
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

            # Remove the temp directory
            rm -rf tmp_unzip
            """
