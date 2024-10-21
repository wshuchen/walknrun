#!/bin/bash

## testWalknrun.sh
# Test run the work flow of warknrun from alignement to walk output
# using chromosome 1 to chromosome 3 from three rice genomes
# Azucena, IR64, and RD23, and proteins aligned to these three chromosomes.

genome_dir=genomes                       # Genomic fasta files
chrom_name=chr                           # Chromosome name
chrom_num=3                              # Total chromosome number
protein_seq=proteins.fasta               # Marker sequence file
miniprot_opts='-I -p 0.8 -N 15'          # Options for miniprot alignment
pangene_opts='0.8 -l 0.8 -E'             # Options for pangene graph construction
threads=16                               # Threads to for miniprot
idx_dir=MPidx                            # Directory for miniprot genome index
paf_dir=PAF                              # Directory for alignment
gfa_dir=GFA                              # Directory for graph
pav_dir=PAV                              # Directory for pav table
walk_dir=Walks                           # Directory for walks

## Assume we are in a test/ directory along with 
# bin/ containing all the scripts.
# genomes/ contains genome fasta files,
# and proteins.fasta in current directory.

## Make path to scripts available.
bin_path=$(echo ${PWD} | sed 's/\/test//')/bin
export PATH=${bin_path}:$PATH
# if [[ -d ${bin_path}/pangene ]]; then
#     export PATH=${bin_path}/pangene:$PATH
# fi

## Align protein sequences to genomes
alignProt.sh ${genome_dir} ${protein_seq} ${chrom_num} ${threads}

## Graph construction and PAV table generation
# Make a list of the combined genome names (e.g., A B C, B A C, C A B)
# The output walk and pav table will be for the first genome (query genome).
list3Genome.sh ${genome_dir} > 3genome_list

# Construct the graphs and generate PAV tables.
while read line; do
    makeGraphPav.sh "$line" ${chrom_num}
done < 3genome_list

## Walk extraction and pav symbolization.
echo
echo "Extracting walks and processing pav table"
while read line; do
    symbolizeWalkChroms.sh "$line" ${chrom_num}
done < 3genome_list

if [[ ! -d ${walk_dir} ]]; then
    mkdir ${walk_dir}
fi
mv *-walks ${walk_dir}
echo "Done."
echo ""
