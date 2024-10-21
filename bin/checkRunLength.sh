#!/bin/bash

## walknrun-checkRunlength.sh
# Call walknrun-locateRun.sh to check run lungth 
# across multiple three-genome combinations in a list.

## Outputs: run files saved in *_run* directory, a log file of summary,
# and counts of run length printed to stdout.
# The log file will be empty if run with sbatch (slurm).
# The info will be written to job *.txt file instead.

## Usage:
# checkRunLength.sh ["genome_list"] [symbol] [chrom_num] [length] < rank >

genome_list=$1  # List of three genome combination (i.e., "ARC LX NB")
symbol=$2
chrom_num=$3
length=$4
rank=${5:-0}    # 0 for all runs; other number to keep the {1..number} longest

## Make a directory for the output
# gn: genome number
gn=$(cat ${genome_list} | cut -d" " -f1 | sort -u | wc -l)
if [[ $rank = 0 ]]; then
    out_dir="${gn}genome-${symbol}${length}-run-all"
else
    out_dir="${gn}genome-${symbol}${length}-run${rank}s"
fi

if ! [[ -d ${out_dir} && ${out_dir}-pos ]]; then
    mkdir ${out_dir} ${out_dir}-pos
fi

## Extract the runs. 
while read genomes; do
    name=$(echo "$genomes" | sed "s/ /_/g")
    echo
    >&2 echo "Working on $name walks" 
    locateRun "$genomes" ${chrom_num} ${symbol} ${length} ${rank} 
    # Save the run files
    mv ${name}_*_run* ${out_dir}
done < ${genome_list} > ${gn}genome_${symbol}${length}_run${rank}_log

if ls *_run0_log > /dev/null; then
    rename "run0" "run_all" *_run0_log
fi
mv ${out_dir}/*_pos ${out_dir}-pos
