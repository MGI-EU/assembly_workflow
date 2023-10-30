#!/bin/bash

ASSEMBLY=$1
THRESHOLD=$2
WDIR=$3

cd ${WDIR}

if [[ ${ASSEMBLY} == *.gfa ]]; then
    awk -v thr=${THRESHOLD} '/^S/ {split($4,a,":"); if (a[3] > thr) print ">"$2"\n"$3}' ${ASSEMBLY} > assembly.filtred.fasta
elif [[ ${ASSEMBLY} == *.fasta || ${ASSEMBLY} == *.fa ]]; then
    ## extract lens
    cat ${ASSEMBLY} | awk 'BEGIN{l=0}{
        if(substr($0, 1, 1) == ">" && NR!=1){
          print l
          l = 0
        } else {
          l = l + length($0)
        }
    }END{print l}' > lens
    
    ## filter small contigs
    cat ${ASSEMBLY} | awk -v thr=${THRESHOLD}  'BEGIN{getline l < "lens"}{
        if(substr($0, 1, 1) == ">"){
          if(l > thr){
            f = 1
          } else {
            f = 0
          }
          getline l < "lens"
        }
        
        if(f == 1){
          print $0
        }
    }' > assembly.filtred.fasta
else
    echo "Unsupported file type!"
    exit 1
fi

rm -f lens

exit
