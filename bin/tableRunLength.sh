#!/bin/bash

# walknrun-tableRunLength.sh

# Output: a table of run length for all run files.

# Usage:
# ./tableRunLength.sh [run_dir]

run_dir=$1  # Dir with run file, e.g., IRBB7_ARC_RD23_chr4_IRBB7_walk_A5_run1

wc -l ${run_dir}/* | grep -v "total" |\
    awk '{print $2, $1}' | sed "s/.*\///g; s/_/ /g" |\
    cut -d" " -f1-4,7,8,9 | tr " " "\t" \
