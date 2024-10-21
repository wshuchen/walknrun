#!/bin/bash

## walknrun-makeGraphPav.sh
# Construct three-genome gene graph for whole genomes and individual chromosomes.
# Generate gene presence-absence variation (PAV) table from the graph.

## Output: two directories for graph *.gfa and pav tables respectively.

## Usage: ./makeGraphPav [genomes] [chrom_num] < pangene_opts >

genomes=$1                              # "genomeA genomeB genomeC"                          
chrom_num=$2                            # Total chromosome number
pangene_opts=${3:-'-e 0.8 -l 0.8 -E'}   # Options for graph construction
 
chrom_name=chr                          # Chromosome name
paf_dir=PAF
gfa_dir=GFA
pav_dir=PAV

# pangene options:  -e identity [0.5] 
#                   -l fraction of protein aligned [0.5]
#                   -E ignore single-exon genes; may exclude many genes

## Make two directories for output files.
if ! [[ -d ${gfa_dir} && -d ${pav_dir} ]]; then
    mkdir ${gfa_dir} ${pav_dir}
fi

## Construct the graphs and generate PAV tables.
# Create directories to collect files for each genomes in multigenome comparison.
echo $genomes |\
while read gA gB gC; do
    graph_prefix=${gA}_${gB}_${gC} 
    # Genome graph
    echo
    echo "Constructing graph and generating PAV table for $gA $gB $gC"
    pangene ${pangene_opts} \
        ${paf_dir}/${gA}.paf \
        ${paf_dir}/${gB}.paf \
        ${paf_dir}/${gC}.paf \
        > ${graph_prefix}.gfa \
        2> ${graph_prefix}_graph.log
    # genome PAV table
    pangene.js gfa2matrix ${graph_prefix}.gfa > ${graph_prefix}_pav_table
    
    # Individual chromosome graph and pav table
    for n in $(seq ${chrom_num})
    do
        chrom="${chrom_name}${n}"
        echo "Constructing graph and generating PAV table for ${chrom} of $gA $gB $gC"
        pangene ${pangene_opts} \
            ${paf_dir}/${gA}_${chrom}.paf \
            ${paf_dir}/${gB}_${chrom}.paf \
            ${paf_dir}/${gC}_${chrom}.paf \
            > ${graph_prefix}_${chrom}.gfa \
            2> "${graph_prefix}"_${chrom}_graph.log
        pangene.js gfa2matrix ${graph_prefix}_${chrom}.gfa \
            > ${graph_prefix}_${chrom}_pav_table
    done

    # # Collect files in a genome directory, helpful in multigenome comparison.
    # if ! [[ -d ${gfa_dir}/${gA} && -d ${pav_dir}/${gA} ]]; then
    #     mkdir ${gfa_dir}/${gA} ${pav_dir}/${gA}
    # fi
    # mv ${gA}_*.gfa *_*.log ${gfa_dir}/${gA}  
    # mv ${gA}_*_pav_table ${pav_dir}/${gA}
done

## Collect the files into directories. 
# Comment out if files already collected - see above.
mv *.gfa *.log ${gfa_dir}  
mv *_pav_table ${pav_dir}
echo
echo "Done. See graphs and PAV tables in directories GFA and PAV respectively."
