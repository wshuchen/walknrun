#!/bin/bash

## walknrun-locateRun.sh
# Retrieve run coordinate from paf files of the three genomes
# for a specified query genome.
# Due to conditions set for alignment and graph construction, 
# a gene in a paf file may not be included in a graph.

## Output: a file with run number and lengths for all chromosomes.

## Usage: 
#  ./locateRun.sh ["genomes"] [chrom_num] [symbol] [length] < rank > < chrom_paf > 
  
genomes=$1          # "query_genome target_genome1 target_genome2"
chrom_num=$2        # e.g., 12 for rice        
symbol=$3           # One of -, A, B, C, d, e, f, or customized one
length=${4:-5}      # Miminum length (number of genes) of a run
rank=${5:-0}        # 0 for all, 1 for the longest, 2 for {1..2}, etc.
chrom_paf=${6:-""}  # Use chromsome instead of genome paf file

chrom_name=chr
graph_prefix=$(echo $genomes | sed "s/ /_/g")
genomes=($genomes)
query_genome=${genomes[0]}  # This sets the first genome to be the query

paf_dir=PAF
walk_dir=Walks
query_walk_dir=${walk_dir}/${query_genome}-walks
if ! [[ -d ${query_walk_dir} && -d ${paf_dir} ]]; then
    echo "ERROE: ${paf_dir} and ${query_walk_dir} directories not found
         in current directory."
fi

## Extract the runs.
# Output file: 
# ${graph_prefix}_${chrom}_${query_genome}_${symbol}${length}_run$rank
for n in $(seq ${chrom_num}); do
    chrom="${chrom_name}${n}"
    getGeneRun.sh ${query_walk_dir}/${graph_prefix}_${chrom}_${query_genome}_walk \
        ${symbol} ${length} ${rank}
done

# Extract the coordinates. paf files must be included in quotation marks.
if ls ${graph_prefix}_*_run* > /dev/null; then
    for file in ${graph_prefix}_*_run*; do
        echo
        if [[ ${chrom_only} ]]; then  # Get the pos from chromosome paf
            chr=$(echo "$file" | sed "s/\(^.*\)\(chr[1-9]\{1,2\}\)\(.*\)/\2/;")
            getRunCoordinate.sh ${file} \
                "${paf_dir}/${genomes[0]}_${chr}.paf \
                ${paf_dir}/${genomes[1]}_${chr}.paf \
                ${paf_dir}/${genomes[2]}_${chr}.paf"
        else # From whole genome paf
            getRunCoordinate.sh ${file} \
                "${paf_dir}/${genomes[0]}.paf \
                ${paf_dir}/${genomes[1]}.paf \
                ${paf_dir}/${genomes[2]}.paf"
        fi
    done
fi

## Comment out to be called in a loop in other script.
# Otherwise uncomment to clean up the files.
# Clean up.
# out_dir=${query_genome}-${symbol}${length}-run${rank}s
# mkdir "${out_dir}"
# mv *_run${rank} *_run${rank}_pos ${out_dir}
# rm *.run[^$rank]*
