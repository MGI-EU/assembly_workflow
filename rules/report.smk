if config.get("paternal_short") and config.get("maternal_short"):
    rule report:
        input:
            quast = "quast/report.tsv",
            merqury_k_completeness = "merqury/completeness.stats",
            merqury_qv = "merqury/merqury.qv",
            yak = "yak/report.tsv"
        output:
            report = "result/report.tsv"
        params:
            sample = config.get("sample", "sample_name")
        shell:
            """
            set +e
            rm assembly.fasta
            rm assembly.filtred.fasta
            rm assembly.polished.ont.fasta
            # QUAST
            ## contiguty
            CONTIGS_0BP=$(grep -m 1 -P "^# contigs \(>= 0 bp\)" {input.quast} | awk '{{print $NF}}')
            NG50=$(grep -m 1 -P "^NG50" {input.quast} | awk '{{print $NF}}')
            NG50_PER_MB=$(echo "scale=2; $NG50 / 1000000" | bc)
            N50=$(grep -m 1 -P "^N50" {input.quast} | awk '{{print $NF}}')
            N50_PER_MB=$(echo "scale=2; $N50 / 1000000" | bc)
            ## missasemblies
            MISSASM=$(grep -m 1 -P "^# misassemblies" {input.quast} | awk '{{print $NF}}')
            MISMATCH=$(grep -m 1 -P "^# mismatches per 100 kbp" {input.quast} | awk '{{print $NF}}')
            INDELS=$(grep -m 1 -P "^# indels per 100 kbp" {input.quast} | awk '{{print $NF}}')
            ## aligned length
            ALIGNED_LENGTH=$(grep -m 1 -P "^Total aligned length" {input.quast} | awk '{{print $NF}}')
            TOTAL_LENGTH=$(grep -m 1 -P "^Total length \(>= 0 bp\)" {input.quast} | awk '{{print $NF}}')

            # Merqury
            K_COMP=$(cat {input.merqury_k_completeness} | head -n1 |  awk '{{print $5}}') 
            QV=$(cat {input.merqury_qv} | head -n1 | awk '{{print $4}}')
            
            # Yak
            SWRATE=$(awk -F'\t' '/^W/ {{print $4}}' {input.yak})
            HRATE=$(awk -F'\t' '/^H/ {{print $4}}' {input.yak})

            # Write results to file
            if [ ! -e {output.report} ]; then
                echo -e "Assembly name\tTotal length\tAligned length\tNG50 (Mb)\tContigs Count\tK-mers completeness\tQV\tSwitch error\tHamming error\tMisassemblies (count)\tMismatches (per 100 kb)\tIndels (per 100kb)" > {output.report}
            fi

            echo "{params.sample}\t${{TOTAL_LENGTH:-}}\t${{ALIGNED_LENGTH:-}}\t${{NG50_PER_MB:-}}\t${{CONTIGS_0BP:-}}\t${{K_COMP:-}}\t${{QV:-}}\t${{SWRATE:-}}\t${{HRATE:-}}\t${{MISSASM:-}}\t${{MISMATCH:-}}\t${{INDELS:-}}" >> {output.report}
            """

if not config.get("paternal_short") or not config.get("maternal_short"):
    rule report:
        input:
            quast = "quast/report.tsv",
            merqury_k_completeness = "merqury/completeness.stats",
            merqury_qv = "merqury/merqury.qv",
        output:
            report = "result/report.tsv"
        params:
            sample = config.get("sample", "sample_name")
        shell:
            """
            set +e
            rm assembly.fasta
            rm assembly.filtred.fasta
            rm assembly.polished.ont.fasta
            # QUAST
            ## contiguty
            CONTIGS_0BP=$(grep -m 1 -P "^# contigs \(>= 0 bp\)" {input.quast} | awk '{{print $NF}}')
            NG50=$(grep -m 1 -P "^NG50" {input.quast} | awk '{{print $NF}}')
            NG50_PER_MB=$(echo "scale=2; $NG50 / 1000000" | bc)
            N50=$(grep -m 1 -P "^N50" {input.quast} | awk '{{print $NF}}')
            N50_PER_MB=$(echo "scale=2; $N50 / 1000000" | bc)
            ## missasemblies
            MISSASM=$(grep -m 1 -P "^# misassemblies" {input.quast} | awk '{{print $NF}}')
            MISMATCH=$(grep -m 1 -P "^# mismatches per 100 kbp" {input.quast} | awk '{{print $NF}}')
            INDELS=$(grep -m 1 -P "^# indels per 100 kbp" {input.quast} | awk '{{print $NF}}')
            ## aligned length
            ALIGNED_LENGTH=$(grep -m 1 -P "^Total aligned length" {input.quast} | awk '{{print $NF}}')
            TOTAL_LENGTH=$(grep -m 1 -P "^Total length \(>= 0 bp\)" {input.quast} | awk '{{print $NF}}')

            # Merqury
            K_COMP=$(cat {input.merqury_k_completeness} | head -n1 |  awk '{{print $5}}') 
            QV=$(cat {input.merqury_qv} | head -n1 | awk '{{print $4}}')


            # Write results to file
            if [ ! -e {output.report} ]; then
                echo -e "Assembly name\tTotal length\tAligned length\tN50 (Mb)\tNG50 (Mb)\tContigs Count\tK-mers completeness\tQV\tSwitch error\tHamming error\tMisassemblies (count)\tMismatches (per 100 kb)\tIndels (per 100kb)" > {output.report}
            fi

            echo "{params.sample}\t${{TOTAL_LENGTH:-}}\t${{ALIGNED_LENGTH:-}}\t${{N50_PER_MB:-}}\t${{NG50_PER_MB:-}}\t${{CONTIGS_0BP:-}}\t${{K_COMP:-}}\t${{QV:-}}\t${{SWRATE:-}}\t${{HRATE:-}}\t${{MISSASM:-}}\t${{MISMATCH:-}}\t${{INDELS:-}}" >> {output.report}
            """
