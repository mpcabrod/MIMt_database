# MIMt_database
A new 16S rRNA database for microbial identification

## Introduction
MIMt is a new 16S rRNA database for archaea and bacteria’s identifications, consisting of 35284 sequences, all of them properly identified at species level. It contains less redundancy than the most used reference databases, namely Greengenes, RDP and SILVA, and despite its smaller size, it is the most complete and accurate in terms of taxonomic information, enabling higher assignation at lower taxonomic ranks and thus, significantly improving species-level identification.

## Construction of MIMt database
### 1) Retrieve representative and reference genomes from NCBI and uncompress them
Download all representative and reference genomes belonging to archaea and bacteria from the NCBI FTP site via rsync. For instance, to download all representative genomes from all archaea species use the following command:

    rsync --progress --copy-links --times --verbose --exclude "\*_from_genomic.fna.gz" rsync://ftp.ncbi.nlm.nih.gov/genomes/refseq/archaea/\*/representative/\*/\*_genomic.fna.gz 

### 2) Create a file containing the list of all downloaded genomes 

ls \*.fna > List_Files.txt 

### 3) Use Infernal to infer all 16S rRNA sequences from all genome files
Use the Infernal program _cmscan_ to search and identify all 16S rRNAs present in all genomes retrieved from NCBI. You have to specify the covariance model (CM) database you want to use, which must be previously calibrated and compressed. The following command can be used:

     for file in *.fna;

     do
	
        cmscan --rfam --cut_ga --nohmmonly --tblout $file.tbl --fmt 2 CMdatabase.cm $file > $file.cmscan;

     done

### 4) 
