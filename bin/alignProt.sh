#!/bin/bash

## walknrun-alignProt.sh
# Align protein genes to genomes 
# using miniprot (Heng Li, https://github.com/lh3/miniprot).
# Refer to miniport program for preparation.

## Output: two directories with genome index and alignment respectively.

## usage:
# ./alignProt.sh [genome_dir] [protein_fastas] [chrom_num] < miniprot_opts >

genome_dir=$1                           # With genome files *.fasta
protein_seq=$2                          # Protein sequence file
chrom_num=$3                            # Total chromosome number
threads=$4                              # Threads for miniport to use
miniprot_opts=${5:-'-I -p 0.8 -N 15'}   # Options for miniprot alignment
                                        # Default -G 200k -p 0.7 -N 30

chrom_name=chr                          # For different naming convention
idx_dir=MPidx                           # miniprot genome indices *.mpi
paf_dir=PAF                             # *.paf

## Create two directories for index and alignment.
[[ ! -d ${idx_dir} ]] && mkdir ${idx_dir}
[[ ! -d ${paf_dir} ]] && mkdir ${paf_dir}

## Indexing and alignment
for genome in ${genome_dir}/*.fasta; do
    genome_name=$(basename ${genome} .fasta)

    # Indexing
    if [[ ! -f ${idx_dir}/${genome_name}.mpi ]]; then
        echo
        echo "Creating genome index for ${genome_name}"
        miniprot -t ${threads} -d ${genome_name}.mpi ${genome} \
            >& ${genome_name}_mpi_log
        mv ${genome_name}.mpi ${genome_name}_mpi_log ${idx_dir}
    fi

    # Alignment, output *.paf.
    echo "Aligning protein sequences ${protein_seq} to ${genome_name}"
    miniprot -t ${threads} "${miniprot_opts}" \
        ${idx_dir}/${genome_name}.mpi ${protein_seq} \
        1> ${genome_name}.paf \
        2> ${genome_name}_log

    # Extract alignement for individual chromosomes.
    for n in $(seq ${chrom_num}); do
        chrom="${chrom_name}$n"
        grep -P "${chrom}\t" ${genome_name}.paf \
            > ${genome_name}_${chrom}.paf
    done        
done

## Move *.paf to PAF directory.
mv *.paf *_log ${paf_dir}

echo -e "\nDone. See alignment files *.paf in ${paf_dir} directory.\n"
