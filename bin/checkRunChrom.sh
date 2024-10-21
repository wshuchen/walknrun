#!/bin/bash

## walknrun-checkRunChrom.sh
# Obtain chromosome info for a run from paf alignment.

## Output: a table of genomes, chromosome, and run length

## Usage:
# ./checkRunChrom [run_pos_file] [length_limit]

run_pos_file=$1          # File with run coordinates of all three genomes
length_limit=${2:-"0.8"} # Minimum length of a target run as a fraction of the query
                         # See blow of other condition (L2, L3 besides L1)

## Query genome position, with full run length. Discard any duplicate.
# Example line of the run_pos_file:
# XP_015634433.1 RD23_chr11 9406809 9409001 ARC_chr4 380171 382615 LIMA_chr4 320558 323397
run=$(basename ${run_pos_file})
cut -d" " -f2,3 ${run_pos_file} | sort -u |\
    cut -d" " -f1 | uniq -c | tr -s " " |\
    sort -Vr | head -1 > ${run}_q

## Two target genome postions.
# Remove any empty result.
# keep maximum three longest ones for further processing.
cut -d" " -f5,6 ${run_pos_file} | grep -v "NA" |\
    sort -u | cut -d" " -f1 | uniq -c |\
    tr -s " " | sort -Vr | head -3 \
    > ${run}_t1
cut -d" " -f8,9 ${run_pos_file} | grep -v "NA" |\
    sort -u | cut -d" " -f1 | uniq -c |\
    tr -s " " | sort -Vr | head -3 \
    > ${run}_t2

## get the run length and run info for printing.
q_length=$(awk '{print $1}' ${run}_q)
run_info=$(echo "${run_pos_file}" | cut -d"_" -f7,8 | tr "_" " ")

## Set condition of length for target to keep:
# If one piece in target: longer than 80% query or as specified;
# If two pieces: the second (small one) should > 20% query;
# IF three pieces: the third should > 10% query.
L1=$(awk -v ql=${q_length} -v t=${length_limit} 'BEGIN {printf "%d", t * ql}')
L2=$(awk -v ql=${q_length} 'BEGIN {printf "%d", 0.2 * ql}')
L3=$(awk -v ql=${q_length} 'BEGIN {printf "%d", 0.1 * ql}')

## Print out the lines that meet the length condition.
for i in 1 2; do
    lengths=($(awk '{print $1}' ${run}_t${i}))
    if [[ ${#lengths[@]} -lt 1 ]]; then
        echo "Run not found in target genome: ${run}_t${i}"
        break
    else
        if [[ ${lengths[2]} && ${lengths[2]} -gt $L3 ]]; then
            mv ${run}_t${i} ${run}_t${i}_L3
        else 
            if [[ ${lengths[1]} && ${lengths[1]} -gt $L2 ]]; then
                head -2 ${run}_t${i} > ${run}_t${i}_L2
            else 
                if [[ ${lengths[0]} -gt $L1 ]]; then
                    head -1 ${run}_t${i} > ${run}_t${i}_L1
                else
                    echo -n "Run not found in target genome: "
                    echo "${run}_t${i}"
                fi
            fi
        fi
    fi
done

## Dupicate the query line for output if their are pieces.
if [[ -f ${run}_t1_L3 ]] || [[ -f ${run}_t2_L3 ]]; then
    cat <(head -1 ${run}_q) <(head -1 ${run}_q) <(head -1 ${run}_q) \
    > ${run}_q_L3
else
    if [[ -f ${run}_t1_L2 ]] || [[ -f ${run}_t2_L2 ]]; then
        cat <(head -1 ${run}_q) <(head -1 ${run}_q) > ${run}_q_L2
    else
        if [[ ! -f ${run}_q_L2 ]] || [[ ! -f ${run}_q_L3 ]]; then
            mv ${run}_q ${run}_q_L1
        fi
    fi
fi

## Print result to stdout.
paste ${run}_*_L* | tr -s " " | tr "_" " " |\
    awk -v r="${run_info}" -v OFS="\t" \
        '{print $2, $3, $1, $5, $6, $4, $8, $9, $7, r}'

rm ${run}_*
