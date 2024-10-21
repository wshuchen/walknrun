#!/bin/bash

# xcheckGeneWalk
# Check a gene's presence in walk and alignment (paf).

# Output: a brief summary of the searching result.

# Usage:
# ./checkGeneWalk.sh [gene name] [gfa file] [pave table] ["paf files"]

gene_name=$1
gfa_file=$2
pav_file=$3
paf_files=$4    # The three alignment pafs

echo -e "\nThe gene ${gene_name} is present in:"
echo -e "\n- Walk:"
grep "${gene_name}" ${gfa_file} | grep -Po "^W\t.*_aln\t"

echo -e "\n- PAV table:"
grep -E "Gene|${gene_name}" ${pav_file} | sed "s/_aln#0//g" | column -t

echo -e "\n- Alignment:"
for paf in ${paf_files}; do
    grep "${gene_name}" ${paf} | cut -f1-12 | column -t
    grep "${gene_name}" ${paf} | cut -f1-12 |\
        awk '{printf "\tIdentity: %.1f%% | Fraction of protein aligned: %.1f%%\n", ($4-$3)/$2*100, $10/$11*100}'
done
echo
