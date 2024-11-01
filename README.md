## Scripts for comparison of genome assemblies based on gene graph    
  
This is a collection of mostly shell scripts written for comparion of genome assemblies of the same species based on gene graph. As a whole, the program uses [_miniprot_](https://github.com/lh3/miniprot) to align proteins to genomes and then uses [_pangene_](https://github.com/lh3/pangene) to construct gene graph and generate gene presence-absence variation (PAV) table. Sebsequently, the program extracts gene walk for a query genome, <u>rearranges</u> the PAV table according to the walk, and then uses letters to represent gene presence-absence status. These steps provide a simple view of gene walk at chromosome level, with clear illustration of common and uniq genes. Additionally, the program can extract continous gene group (run) and their alignment for further processing, for example, locating a run across chrommosomes and genomes. The program can be scaled up for comparion of multiple genomes with scripts to summarize the results.

### Major feature

Using letters to represent presence-absence variation provides a simple and clear view of the walk with respect to PAV.

### Dependencies  

The program uses [_miniprot_](https://github.com/lh3/miniprot), [_pangene_](https://github.com/lh3/pangene), and [_seqkit_](https://bioinf.shenwei.me/seqkit/). Precompiled binaries can be download from the authors' sites. 

### Usage  

Clone the repository and then export the path to bin.

Users should carefully read the scripts and modify them accordingly to serve their needs. Note that scripts to generate and process files after alignments are written specifically for three genomes as a group and the first genome as query genome. Also note that some scripts set default values for options in alignment, graph construction, and run processing.   

### Files  
bin - This directory contains all the scripts. If a user is to run the getPangene.sh in the test directory, the bin will also contain pangene.  

test - This directory contains genome sequences (partial chromosomes of three rice cultivars), protein sequences, and scripts to run the program from alignment to walk extraction. 

### Functionality of the scripts  

_getAssemblySeq.sh_ - extract chromosome sequences and insert "genome_chrN" before ">"  
_list3Genome.sh_ - make a list of combined names of three genomes 
_alignProt.sh_ - run miniprot to align proteins to genomes  
_makeGraphPav.sh_ - run pangene to construct gene graph and generate PAV table  
_symbolizeWalk.sh_ - extract gene walk, <u>rearrange</u>, symbolize, and summarize PAV table  
_symbolizeWalkChroms.sh_ - call symbolizeWalk.sh to process all chromosome graphs  
_getGeneRun.sh_ - extract continuous gene group (run) from symbolized walk   
_getRunCoordinate.sh_ - extract run coordinates from alignment file  
_locateRun.sh_ - call getGeneRun.sh and getRunCoordinate.sh to process runs of all chromosomes   
_checkRunLength.sh_ - call locateRun.sh to process a list of genomes  
_checkRunChrom.sh_ - summarize the result of locateRun.sh for run chromosome info  
_getUniqRun.R_ - summarize the run chromosome info for uniq run of a genome in multiple genome comparison 
_checkGeneWalk.sh_ - check the presence of a gene in alignment, graph and PAV table  
_tableRunLength.sh_ - simple summary of run length from run coordinate file

### Test  
The test will run the scripts from alignment to walk extraction.
See other scripts for further processing.

Usrs can either download pangene binariies and make the path available, or run getPangene.sh.

```{bash}
cd test
./getPangene.sh
./testWalknRun.sh
```
The test script would take less then two minutes to finish the job.  

The directory alos includes a script to look at the difference of walks extracted from graphs contructed with different order of the same alignment files. See the README for detail.

### Acknowledgments

These scrpts were written for a project concieved and supervised by Professor [Volker Brendel](https://github.com/vpbrendel).


