### The genome directory

This directory contains partial sequences of chromosome 1, chromosome 2, and chromosome 3 of three rice cultivars Azucena, IR64 and RD23. The sequences have been processed for test purpose.  

The protain sequences are rice reference proteins aligned to the above chromosome sequences.

Link to the assemblies:

Azucena  
https://www.ncbi.nlm.nih.gov/datasets/genome/GCA_009830595.1/

IR64  
https://www.ncbi.nlm.nih.gov/datasets/genome/GCA_009914875.1/  

RD23  
https://www.ncbi.nlm.nih.gov/datasets/genome/GCA_001514335.2/  


### The testGraphOrderWalk.sh script

This script looks at difference of chromosome walks for a genome from graphs constructed with different order of the same alignment files. 

To run the script:

1. Create a new directory;
2. Copy the script to the directory;
3. Create a PAF directory;
4. Copy three chromosome paf files, A_chrN.paf, B_chrN.paf, and C_chrN.paf, to PAF;
5. Run the script as below:  
    ./testGraphOrderWalk.sh "A B C" chrN
6. Change the genome order (e.g., "B A C") or other paf files for more results.
7. The script removes files it creates. Comment out the last command to keep the files if needed.

