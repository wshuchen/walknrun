#!/bin/bash

## walknrun-getGeneRun.sh
# Retrieve continous gene group (run) from a symbolized walk.
# Specify the length (number of genes; default to 5) to retrieve all the runs
# longer than the length (default) from a chromosome, 
# or also specify a rank number to keep only top ones.

## Output: run file(s) named *_runN.

## Usage:
# ./getGeneRun.sh [symbol_file] [symbol] [length] [rank]

symbol_file=$1    # The file with genes in column 1 and symbols in column 2
symbol=$2
length=${3:-5}    # Number of genes. Default = 5
rank=${4:-0}      # Number of runs (1: longest, 2: 1 and second longest, etc)
                  # Default = 0 (keep all)

## Helper in case of error of command line argument.
d="^[0-9]+$"
if [[ ! $length =~ $d ]]; then
  echo "The length is: $length."
  echo "Error: the length ($length) is NOT a number."
  exit
fi

# Graph prefix
out_prefix=$(echo ${symbol_file} | sed "s/.*\///g; s/\..*//")

## Extract runs.
# Print out the symbol with line numbers.
awk '{print $0, NR}' ${symbol_file} | grep "${symbol}" -A1 |\
  # Replace the line number without symbol with "-".
  awk -v s="${symbol}" '{if ($2=="-" || $2 != s){$3="-"}{print $0}}' |\
  # Get the line number column and turn it into one line,
  # with boundaries of gene groups (runs) marked by "-".
  tr " " "\t" | cut -f3 | tr "\n" "," |\
  # Separate the line into runs and delelte single numbers.
  sed "s/-,/\n/g" | grep -vE "^[[0-9]{1,4},$|-" | sed "s/,$//g" |\
  # Save the start and end of a line (start and end of continuous rows).
  # Sort reversely according to the number of genes.
  # Remove entries with only two genes.
  awk -F, -v OFS="\t" '{print $1, $NF, $NF-$1+1}' |\
    sort -k3nr | awk '$3 > 2' > tmp_${out_prefix}_${symbol}_idx
  # keep all if rank is not specified.
  if (( $rank > 0 )); then
    head -n $rank tmp_${out_prefix}_${symbol}_idx > ${out_prefix}_${symbol}_idx
    rm tmp_${out_prefix}_${symbol}_idx
  else
    mv tmp_${out_prefix}_${symbol}_idx ${out_prefix}_${symbol}_idx
  fi 
  
# Finally, print out the rows with gene runs longer than the specified length.
R=1
while read start end size; do
  if (( $size >= $length )); then
    sed -n "$start,$end{p}" ${symbol_file} \
      > ${out_prefix}_${symbol}${length}_run"$R"
    (( R += 1 ))
  fi
done < ${out_prefix}_${symbol}_idx
rm ${out_prefix}_${symbol}_idx
