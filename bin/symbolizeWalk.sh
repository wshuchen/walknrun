#!/bin/bash

## walknrun-symbolizeWalk.sh
# Extra a gene walk (ordered gene names) from a three-genome graph
# and represent the presence-absence variation in genomes with symbols.
# Symbols can be specifed. See default below.
# Count the symbols.

## Outputs: *_walk_summary, *_walk.

## Usage:
# ./symbolizeWalk.sh [gfa_file] [pav_table] [query_genome] [chromosome] <symbols>

gfa_file=$1       # A three-genome graph, A_B_C.gfa; can be chromosome gfa
pav_table=$2      # A_B_C_chr5_pav_table
query_genome=$3   # Genome to extract the walk, e.g., genome A
chrom=$4          # Chromosome name, e.g., chr1        
symbols=${5:-"- A B C d e f"}  # Default: -(all)=A,B,C, d=A,B, e=A,C, f=B,C

## Get the genome names from gfa file.
genome_names=$(grep -Po "^W\t.*" ${gfa_file} |\
             sed "s/^W\t//g; s/_.*//g" | awk '!a[$0]++')
genomes=($genome_names)    # (A B C)
symbols=($symbols)         # (- A B C d e f)
graph_prefix=$(echo ${genomes[@]} | sed "s/ /_/g")  # A_B_C

## EXtract the query gene walk (gene1>gene2>...<...>geneN) 
# and turn them into a list, one line for one gene.
# Walk of a genome/chromosome in *.gfa from miniprot (aligned to Azucena.fasta):
# W	Azucena_chr10	0	Azucena_chr10	*	*	<XP_015612840.1>...
# There may have duplicate gene names in the walk. Keep the duplicates.
grep -P "^W\t${query_genome}.*\t" ${gfa_file} | grep "${chrom}" |\
    sed "s/\(^W.*	\)\(.*\)\(	.*$\)/\2/g" |\
    tr "[><]" "\n" | sed '1d' \
    > tmp_${graph_prefix}_${chrom}_walk

## Use the walk to rearrange the rows of pav table. 
# Gene	genomeA#0	genomeB#0	genomeC#0
# geneA	        1	0	1
# geneB     	0	1	1
# geneC         0   1   0
# The gene names are sorted.
# The columns are in the order of genomes as appeared in the graph,
# i.e., in the given order of paf files for building the graph.

# Remove header and rows with all absences.
grep -vP "Gene|0\t0\t0" ${pav_table} > tmp_${graph_prefix}_${chrom}_pav_table

# Walk and rearrangement
while read line; do
    grep "$line" tmp_${graph_prefix}_${chrom}_pav_table \
    >> tmp_${graph_prefix}_${chrom}_pav_0 
done < tmp_${graph_prefix}_${chrom}_walk

## Rearrange column when the query genome is not the first one
# in the graph (colmn 2 in pav table).
# i.e., shift the column of query genome to column 2.
# Also rearrange the genome order accordingly.
# Genome order from the graph: genomes=(A B C)
# Original: Gene	genomeA#0	genomeB#0	genomeC#0
# If genomeB is query: Gene	genomeB#0	genomeA#0	genomeC#0
if [[ ${query_genome} = ${genomes[1]} ]]; then
    genomes=(${genomes[1]} ${genomes[0]} ${genomes[2]})
    awk -v OFS="\t" '{print $1, $3, $2, $4}' tmp_${graph_prefix}_${chrom}_pav_0 \
        > tmp_${graph_prefix}_${chrom}_pav
    rm tmp_${graph_prefix}_${chrom}_pav_0
# If genomeC is query: Gene	genomeC#0	genomeB#0	genomeA#0
elif [[ ${query_genome} = ${genomes[2]} ]]; then
    genomes=(${genomes[2]} ${genomes[1]} ${genomes[0]})
    awk -v OFS="\t" '{print $1, $4,  $3, $2}' tmp_${graph_prefix}_${chrom}_pav_0 \
        > tmp_${graph_prefix}_${chrom}_pav
    rm tmp_${graph_prefix}_${chrom}_pav_0
# First genome is query
else
    mv tmp_${graph_prefix}_${chrom}_pav_0 tmp_${graph_prefix}_${chrom}_pav
fi

## Generate the symbolized walk file.
# Default
# symbols:  (genomes: A, B, C)
# All:      111      -
# A:        100      A
# B:        010      B
# C:        001      C
# A, B:     110      d
# A, C:     101      e
# B, C      011      f

# Turn the walk into symbols.
# Use multiple sed commands for clarity.
cut -f2- tmp_${graph_prefix}_${chrom}_pav |\
    sed "s/\t//g" | sed "s/111/-/g" |\
    sed "s/100/${symbols[1]}/g; s/010/${symbols[2]}/g" |\
    sed "s/001/${symbols[3]}/g; s/110/${symbols[4]}/g" |\
    sed "s/101/${symbols[5]}/g; s/011/${symbols[6]}/g" \
    > tmp_${graph_prefix}_${chrom}_symbols

# Combine gene names with symbols into one file.
paste tmp_${graph_prefix}_${chrom}_walk tmp_${graph_prefix}_${chrom}_symbols \
    > ${graph_prefix}_${chrom}_${query_genome}_walk

## Write the symbolized walk in one line for display.
cut -f2 ${graph_prefix}_${chrom}_${query_genome}_walk |\
    tr "\n" "," | sed "s/,//g; s/$/\n/" \
    > ${graph_prefix}_${chrom}_${query_genome}_walk_summary

## Count the symbols.
echo "Symbols: (presence(1) or absence(0) as in PAV table)
    All:                          111  -
    ${genomes[0]}:                100  ${symbols[1]}
    ${genomes[1]}:                010  ${symbols[2]}
    ${genomes[2]}:                001  ${symbols[3]}
    ${genomes[0]},${genomes[1]}:  110  ${symbols[4]}
    ${genomes[0]},${genomes[2]}:  101  ${symbols[5]}
    ${genomes[1]},${genomes[2]}:  011  ${symbols[6]}" \
    > tmp_${graph_prefix}_${chrom}_symspec
echo >> ${graph_prefix}_${chrom}_${query_genome}_walk_summary
cat tmp_${graph_prefix}_${chrom}_symspec | column -t \
    >> ${graph_prefix}_${chrom}_${query_genome}_walk_summary

# Total length
n=$(cat ${graph_prefix}_${chrom}_${query_genome}_walk | wc -l)
echo -e "\nWalk length = $n" \
    >> ${graph_prefix}_${chrom}_${query_genome}_walk_summary

# Count with translation of the symbols back to genome names.
echo -e "\nGene count and presence:" \
    >> ${graph_prefix}_${chrom}_${query_genome}_walk_summary
cut -f2 ${graph_prefix}_${chrom}_${query_genome}_walk |\
    sort | uniq -c | sort -k2V |\
    sed "s/ ${symbols[1]}$/ ${symbols[1]} = ${genomes[0]}/" |\
    sed "s/ ${symbols[2]}$/ ${symbols[2]} = ${genomes[1]}/" |\
    sed "s/ ${symbols[3]}$/ ${symbols[3]} = ${genomes[2]}/" |\
    sed "s/ ${symbols[4]}$/ ${symbols[4]} = ${genomes[0]},${genomes[1]}/" |\
    sed "s/ ${symbols[5]}$/ ${symbols[5]} = ${genomes[0]},${genomes[2]}/" |\
    sed "s/ ${symbols[6]}$/ ${symbols[6]} = ${genomes[1]},${genomes[2]}/" |\
    sed "s/ -$/ - = ${genomes[0]},${genomes[1]},${genomes[2]}/" \
    >> ${graph_prefix}_${chrom}_${query_genome}_walk_summary

## Display the result.
echo -e "\nThe symbolized gene walk of ${query_genome} ${chrom}: \n"
cat ${graph_prefix}_${chrom}_${query_genome}_walk_summary
echo

## Clean up.
rm tmp_${graph_prefix}_${chrom}_* 
