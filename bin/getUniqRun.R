#!/usr/bin/env Rscript

# getUniqRun.R
# Extract runs of a genome that are distinct from a specified portion
# (fraction) of three-combination of tested genomes.
# Output: Rows of the original file satisfied the conditions.

# Usage: (also see below)
# < Rcript > getUniqRun.R [-f run_length_file] < -p portion > < -g genome >, or
# < Rcript > getUniqRun.R [run_length_file] < portion > < genome > 

# If argparser package is not available,
# comment this part out and uncomment the postional argument part
# Add command line options.
# The argparser gets the first letter of the name of an argument as its flag.
library(argparser, quietly=TRUE)
p = arg_parser("Extract unique runs for a genome.")
p = add_argument(p, "--file", type = "character", 
                help = "Six-column run length file")
p = add_argument(p, "--portion", type = "numeric", default = 1,
                help = "Portion of genome combinations")
p = add_argument(p, "--genome", type = "character", default = "all",
                help = "Only result for the specified genome")
p = add_argument(p, "--keep", type = "numeric", default = 0,
                help = "Only print first line for a run")

argv <- parse_args(p)
run_length_file = argv$file
portion         = argv$portion
genome          = argv$genome
keep            = argv$keep

# # Set positional arguments.
# args = commandArgs(trailingOnly = TRUE)
# run_length_file = args[1]                          # six-column run length file
# portion = ifelse(length(args) >= 2, args[2], 1.0)  # 1.0 for all (default), or
#                                                    # portion (e.g., 0.8)
# genome = ifelse(length(args) >= 3, args[3], "all") # Result for a genome only 

# Sample lines of a run_length_file:
# ARC  Azucena  BALAM  chr2   A5  5
# ARC  Azucena  BALAM  chr9   A5  5
# ARC  Azucena  BALAM  chr11  A5  6

df = read.table(run_length_file)
colnames(df) = c("genomeA", "genomeB", "genomeC", "chr", "run", "rank", "length")

# Group by query genome (genomeA), chromosome, and length, 
# and then count the number of distinct length.
length_count = aggregate(as.factor(df$length), 
                    list(df$genomeA, df$chr, df$length), length)
colnames(length_count) = c("genomeA", "chr", "length", "count")

# A function to print only the first row for each run if specified.
# Good for a run across all genomes.
# Col1 and col2 two are the colmns for grouping.
keepFirstRow = function(df, col1, col2) {
    out_df = data.frame()
    for (i in unique(df[, col1])) {
        for (j in unique(df[df[, col1]==i, col2])) {
            one_df = df[df[, col1]==i & df[, col2]==j,][1,] # first row
            out_df = rbind(out_df, one_df)  # Combine all selected rows
        } 
    }
    return(out_df)
}

# Get the runs of certain lengthes that aren't found
# in a portion of other genomes.
n_genome = length(unique(df$genomeA))
n_comb = (n_genome - 1) * (n_genome - 2) / 2    # All three-genome combinations
#portion = as.numeric(portion)
uniq_runs = length_count[length_count$count >= as.integer(n_comb * portion), ]
if (nrow(uniq_runs) > 0) {
    # Merge the two data frames to get the original entries.
    # Rearrange the column to be the same as original ones. Drop count.
    uniq_df = merge(uniq_runs, df, by = c("genomeA", "chr", "length"))
    uniq_df = uniq_df[colnames(df)]    
} else {
    message("No eligible run found.")
}
# Only output result for a genome if specified.
if (genome != "all") {
    uniq_df = uniq_df[uniq_df$genomeA == genome, ]
    if (nrow(uniq_df[uniq_df$genomeA == genome, ]) < 1) {
    message(paste("No eligible run found for the genome:", genome))
    }   
}
# Only keep first row if specified.
if (keep != 0) {
    uniq_df = keepFirstRow(uniq_df, "genomeA", "length")
}

# Print the result to stdout.
if (nrow(uniq_df) > 0) {
    print(format(uniq_df, justify = "left"), row.names = FALSE)
} 
