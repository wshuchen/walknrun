#!/bin/bash

# walknrun-symbolizeWalkChroms.sh
# Call symbolizeWalk.sh to generate symolized walks and summaries
# for all chromosomes of a genome in the three-genome graph.

# Output: *_walk, *_walk_summary in a walk dir.

# Usage:
#./symbolizeWalkChroms.sh [genomes] [chrom_num]

genomes=$1          # "genomeA genomeB genomeC"
chrom_num=$2        # Chromosome number

chrom_name=chr
graph_prefix=$(echo $genomes | sed "s/ /_/g")
genomes=($genomes)
query_genome=${genomes[0]}  # genomeA

gfa_dir=GFA
pav_dir=PAV
# Expect these two directories in current directory; otherwise,
# provide the paths.
if ! [[ -d ${gfa_dir} && -d ${pav_dir}  ]]; then
    echo "Paths for graph and pav table not found."
    echo "Expecting ${gfa_dir} and ${pav_dir} in current directory."
    echo "Please provide the paths in the script as needed."
    exit
fi

# Make a dirctory for the output files.
walk_dir=${query_genome}-walks
if [[ ! -d ${walk_dir} ]]; then
    mkdir ${walk_dir}
fi

# Extract walks for individual chromosomes for the genomes.
for n in $(seq ${chrom_num})
do
    echo "Working on chr$n of ${query_genome}"
    chrom="${chrom_name}${n}"
    gfa_file=${gfa_dir}/${graph_prefix}_${chrom}.gfa
    pav_file=${pav_dir}/${graph_prefix}_${chrom}_pav_table
    symbolizeWalk.sh ${gfa_file} ${pav_file} ${query_genome} ${chrom}
    mv ${graph_prefix}_${chrom}_* ${walk_dir}
done
