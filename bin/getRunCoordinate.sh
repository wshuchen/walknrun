#!/bin/bash

## walknrun-getRunCoordinate.sh
# Extract protein genome alignment position from paf files 
# generated with miniprot.

## Output: table with genes and positions; NA where not info found.

## Usage:
# ./getPafCoordinate.sh [run_file] ["paf_files"] <paf_filter>

run_file=$1                 # File with gene and symbol processed from walk
paf_files=$2                # list of paf files in quotation marks     
paf_filter=${3:-"0.8 0.8"}  # pangene flag values

# pangene flag -e (identity) and -l (aligned length) values for paf
# when contructing graph.
el=($(echo "$paf_filter"))
e=${el[0]}
l=${el[1]}

## Get the gene names.
run_name=$(basename ${run_file})
cut -f1 ${run_file} | sort -u > tmp_${run_name}_genes
if [[ $(cat tmp_${run_name}_genes | wc -l) = 1 ]]; then  # In case of false run
    echo "${run_name} has single gene run. Stop processing."
    rm tmp_${run_name}_genes
    exit
fi

## Extract the coordinates
# Create an array for temporary file names.
names=()
for paf in ${paf_files}; do
    name=$(basename "$paf" .paf)
    names+=("$name")

    # Search gene name in paf file. 
    # If found and the quality met, print out the coordinate.
    # All else, print "NA". 
    # Having genome name but not position in the result 
    # indicates alignment found but quality not met.
    while read gene; do
        if [[ $(grep "$gene" $paf) ]]; then
            grep "$gene" $paf |\
            awk -v OFS="\t" -v e=$e -v l=$l -v g="$gene" \
            '{if (($4-$3)/$2 >= l && $10/$11 >= e) {print g, $6, $8, $9} 
            else {print g, $6, "NA", "NA"}}' >> tmp_${name}_pos
        else
            echo -e "$gene\tNA\tNA\tNA" >> tmp_${name}_pos    
        fi
    done < tmp_${run_name}_genes
done 

## Join the tables. Work with three files or less.
# Coordinates for the first genome will be repeated
# if there are multiple matches with others.
awk '$3 != "NA"' tmp_${names[0]}_pos |\
    if [[ ${#names[@]} = 1 ]]; then
        awk '{print $0}' > ${run_name}_pos
    elif [[ ${#names[@]} = 2 ]]; then
        join - "tmp_${names[1]}_pos" > ${run_name}_pos
    elif [[ ${#names[@]} = 3 ]]; then
        join - "tmp_${names[1]}_pos" |\
        join - "tmp_${names[2]}_pos" > ${run_name}_pos
    else
        echo "More than three paf files given. See tmp_* files for results."
        echo "Please process them as needed."
    fi 
    
## Print summary info.
echo
echo -n "${run_file} - number of genes: "
cat tmp_${run_name}_genes | wc -l
echo "Genes found on chromosomes:"
for i in tmp_${names[0]}_pos tmp_${names[1]}_pos tmp_${names[2]}_pos; do
    awk '$3 != "NA"' "$i" | cut -f2,3 | sort -u | cut -f1 | sort -V | uniq -c
done
rm tmp_${run_name}_genes tmp*_pos
