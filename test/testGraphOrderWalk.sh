#!/bin/bash

## testGraphOrderWalk.sh
# Construct gene graphs of a chromosome with protein-genome alignment files
# of three genomes, give different order of files for construction, 
# extract the walks for a genome from the graphs, and examine the difference.

### Questions:
## 1: Given three protein-chromosome alignments, can we obtain the same 
# walk for each chromosome from a graph contruct regardless of the order of
# files for construction?
## 2: If not, what are the differences?

# i.e., given chromosome alignements, A_chr1.paf, B_chr1.paf, C_chr1.paf,
# can we obtain the same walk for A from A_B_C_chr1.gfa, B_A_C_chr1.gfa,
# or C_B_A_chr1.gfa?

# Usage testCombSepWalk.sh ["genomes"] [chrom]

genomes=$1  # e.g., "Azucena IR64 RD23", three genome names, quoted 
chrom=$2    # e.g., chr1, corresponding to the files in PAF directory

pangene_opts='-e 0.8 -l 0.8 -E'     # E - ignore single-exon genes
                                    # could exclude many genes
paf_dir=PAF                         # With paf alignment files
gfa_dir=GFA
pav_dir=PAV

[[ ! -d ${gfa_dir} ]] && mkdir ${gfa_dir}
[[ ! -d ${pav_dir} ]] && mkdir ${pav_dir}

echo
echo "Question:"
echo "Can we obtain the same gene walk for a chromosome from"
echo "a three-genome chromosome graph regardless of the order of files"
echo "given for construction?"
echo "i.e., same walk for A from A_B_C_chrN.gfa, B_A_C_chrN.gfa, and C_B_A_chrN.gfa?"

echo
echo "To find out, we first contruct the graph and generate pav table."
echo

## Construct the graph and generate pav tables.
function createGraphPav() 
{
    gs=($1)  # Three genome names
    ga=${gs[0]}
    gb=${gs[1]}
    gc=${gs[2]}
    graph_prefix=${ga}_${gb}_${gc} 
    echo "Constructing graph and generating PAV table for ${chrom} of $ga $gb $gc"
    pangene ${pangene_opts} \
        ${paf_dir}/${ga}_${chrom}.paf \
        ${paf_dir}/${gb}_${chrom}.paf \
        ${paf_dir}/${gc}_${chrom}.paf \
        > ${graph_prefix}_${chrom}.gfa \
        2> /dev/null
    pangene.js gfa2matrix ${graph_prefix}_${chrom}.gfa \
        > ${graph_prefix}_${chrom}_pav_table
}

genomes=(${genomes})
gA=${genomes[0]}
gB=${genomes[1]}
gC=${genomes[2]}

createGraphPav "$gA $gB $gC"
createGraphPav "$gB $gA $gC"
createGraphPav "$gC $gB $gA"

# Collect the files into directories.
mv *.gfa ${gfa_dir}  
mv *_pav_table ${pav_dir}

echo
echo "We then extract the gene walk of a chromosome of a genome, "
echo "in this case, ${genomes[0]} ${chrom}, from the three graphs."
echo ""

## Extrack and symbolize the walk.
for gn in ${gA}_${gB}_${gC} ${gB}_${gA}_${gC} ${gC}_${gB}_${gA}; do
    >&2 echo "Working on $gn"
    symbolizeWalk.sh GFA/${gn}_${chrom}.gfa \
                   PAV/${gn}_${chrom}_pav_table \
                   ${gA} ${chrom}
done > symbolize_log

## Check the results.
# First, the symbols.
ABC_walk=${gA}_${gB}_${gC}_${chrom}_${gA}_walk
BAC_walk=${gB}_${gA}_${gC}_${chrom}_${gA}_walk
CBA_walk=${gC}_${gB}_${gA}_${chrom}_${gA}_walk

echo "Length of the three walks:"
wc -l ${ABC_walk} ${BAC_walk} ${CBA_walk} | grep -v total

echo
echo "Compare the three walks, firstly looking at the symbolized representatives:"
echo
paste ${ABC_walk} ${BAC_walk} ${CBA_walk} |\
    awk '$2 != $4 || $2 != $6 || $4 != $6' \
      > tmp_walk_diff_check
if [[ $(cat tmp_walk_diff_check | wc -l) -gt 0 ]]; then
    echo "Diffence at site found:"
    cat tmp_walk_diff_check   
else
    echo "No diffence in symbolized walk steps found." 
fi
rm tmp_walk_diff_check

echo
echo "Then checking the genes, showing those difference in the same positions."
echo
paste ${ABC_walk} ${BAC_walk} ${CBA_walk} |\
    awk '$1 != $3 || $1 != $5 || $3 != $5'

echo
walk_length=$(cat ${ABC_walk} | wc -l)
n=$(paste ${ABC_walk} ${BAC_walk} ${CBA_walk} |\
    awk '$1 != $3 || $1 != $3 || $3 != $5' | wc -l)
pct=$(awk -v a=$n -v b=${walk_length} 'BEGIN {printf "%.1f%%", (a/b)*100}')
echo "The different genes at the same positions across three walks: $n ($pct)"

echo
echo "Pairwise comparison:"
echo
n=$(paste ${ABC_walk} ${BAC_walk} | awk '$1 != $3' | wc -l)
pct=$(awk -v a=$n -v b=${walk_length} 'BEGIN {printf "%.1f%%", (a/b)*100}')
echo "Between ${ABC_walk} and ${BAC_walk}: $n ($pct)"

n=$(paste ${ABC_walk} ${CBA_walk} | awk '$1 != $3' | wc -l)
pct=$(awk -v a=$n -v b=${walk_length} 'BEGIN {printf "%.1f%%", (a/b)*100}')
echo "Between ${ABC_walk} ${CBA_walk}: $n ($pct)"

n=$(paste ${BAC_walk} ${CBA_walk} | awk '$1 != $3' | wc -l)
pct=$(awk -v a=$n -v b=${walk_length} 'BEGIN {printf "%.1f%%", (a/b)*100}')
echo "Between ${BAC_walk} ${CBA_walk}: $n ($pct)"

echo
echo "Finally, where do the discrepencies locate in the walk?"
echo
echo "Let's look at the first walk compared to the second one"
echo "with X replacing a symbol where genes differ:"
echo
paste ${ABC_walk} ${BAC_walk} |\
    awk '{if ($1 != $3) {$2 = "X"} {print $2}}' |\
    tr "\n" "," | sed "s/,//g" | grep --color X
echo 

rm -rf GFA PAV *log *walk *summary
