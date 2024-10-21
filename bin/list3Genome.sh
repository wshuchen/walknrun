#!/bin/bash

# walknrun-list3genome.sh
# Make a combination of genome names, three each line. 
# No order for the second and the third, i.e., ABC=ACB. 
# The script keeps ABC only.
# Print to stdout.

# Output: a list of combination of genome names, three each line.

# Usage:
# ./list3genome.sh [genome_dir] 

genome_dir=$1   # with genome1.fasta, genome2.fasta, etc

# Get the genome names.
genome_list=$(ls ${genome_dir}/*.fasta | sed "s/^.*\///g; s/.fasta//g")

# Print out not redundant combination of three names.
for i in ${genome_list}; do
    for j in ${genome_list}; do
        [[ $j = $i ]] && continue
        for k in ${genome_list}; do
            [[ $k = $j ]] && break
            [[ $k = $i ]] && continue
            echo "$i $k $j"           
        done
    done
done
