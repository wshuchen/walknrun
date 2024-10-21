#!/bin/bash

# walknrun-getAssemblyChromSeq.sh
# Extract chromosome sequences from an assembly (RefSeq or GenBank),
# and insert a genome name with chromosome number 
# right after ">" and before the original ID or name.
# Use seqkit (https://bioinf.shenwei.me/seqkit) commands. Can take *.gz file.

# Output: genome_name.fasta

# Usage:
# ./getAssemblyChromSeq [assembly] [genome_name] <chrom_number>

assembly=$1                 # GCA_001514335.2_ASM151433v2_genomic.fna.gz
genome_name=$2              # Name of the genome
chrom_number=${3:-"12"}     # chromosome number. Defult=12 for rice.

# For GCA*.fna.gz, genome name could be
# genome_name=$(echo $assembly | cut -d"_" -f3) # ASM151433v2

# Make a list of chromosome names. Sort it just in case.
# GenBank: CM*; Refseq: NC_*.
chr_list=$(zgrep ">" ${assembly} | cut -d" " -f1 | cut -d">" -f2 |\
        # Typically chromosome sequences come first.
        head -n ${chrom_number})
echo "Checking chromosome sequence IDs:"
echo ${chr_list}

# Extract chromosome sequences, and insert ${genome_name}_chrN after ">".
N=1
for i in ${chr_list}; do
    # Extract the sequence by ID
    seqkit grep -p "$i" ${assembly} |\
    seqkit replace -p ^ -r "${genome_name}_chr$N " >> ${genome_name}.fasta
    (( N += 1 ))
done

# Check the result.
echo "Checking chromosome entries of ${genome_name}.fasta:"
grep ">" ${genome_name}.fasta
