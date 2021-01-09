# MIMt_database
A new 16S rRNA database for microbial identification

## Introduction
MIMt is a new 16S rRNA database for archaea and bacteria’s identifications, consisting of 35284 sequences, all of them properly identified at species level. It contains less redundancy than the most used reference databases, namely Greengenes, RDP and SILVA, and despite its smaller size, it is the most complete and accurate in terms of taxonomic information, enabling higher assignation at lower taxonomic ranks and thus, significantly improving species-level identification. MIMt contains a total of 11 538 different species, 404 of them belonging to Archaea and 11 134 to Bacteria domains.

## Construction of MIMt database
### 1) Retrieve representative and reference genomes from NCBI and uncompress them
Download all representative and reference genomes belonging to archaea and bacteria from the NCBI FTP site via rsync. For instance, to download all representative genomes from all archaea species use the following command:

    rsync --progress --copy-links --times --verbose --exclude "\*_from_genomic.fna.gz" rsync://ftp.ncbi.nlm.nih.gov/genomes/refseq/archaea/\*/representative/\*/\*_genomic.fna.gz 

### 2) Create a file containing the list of all downloaded genomes 

    ls *.fna > List_Files.txt 

### 3) Use Infernal to infer all 16S rRNA sequences from all genome files
Use the Infernal program _cmscan_ to search and identify all 16S rRNAs present in all genomes retrieved from NCBI. You have to specify the covariance model (CM) database you want to use, which must be previously calibrated and compressed. The following command can be used:

     for file in *.fna;

     do
	
        cmscan --rfam --cut_ga --nohmmonly --tblout $file.tbl --fmt 2 CMdatabase.cm $file > $file.cmscan;

     done

### 4) Assign the complete taxonomy to each inferred 16S sequence by using Perl scripts 
- **get-spname.pl**

Execute this script to obtain the species’ name from  each genome retrieved in the step 1. In brief, this script uses the genome file (.fna) as input, extracts the header (first  line) and gets the species name by using the _split_ function. Use a shell script to execute it on all genomes sequentially. The output file ("SpNames.txt") contains the list with all species names from all genomes retrieved from NCBI.

- **Obtain the "tax_report.txt" file**

Upload the "SpNames.txt" file in the Taxonomy Browser of the NCBI database (https://www.ncbi.nlm.nih.gov/Taxonomy/TaxIdentifier/tax_identifier.cgi) to obtain the "tax_report.file". In this file, each taxon is identified with a stable and unique numerical identifier (the taxid), which is linked to its full taxonomic classification.

- **get-taxid_taxonomy.pl**

Execute this script to associate each taxid with their corresponding full taxonomic classification. This script requires two input files: 1) the "tax_report.txt" file, and 2) the “rankedlineage.dmp” file from NCBI (ftp://ftp.ncbi.nlm.nih.gov/pub/taxonomy/), which comprises the list of all taxid available at this database and their corresponding taxonomic hierarchy (species, genus, family, order, class, phylum, and kingdom). The performance of this script can be improved by using a reduced version of the dump file containing only the taxonomy information for archaeal and bacterial species. The script extracts the taxids from both input files, compares them, and if they are equal it associates the corresponding full taxonomic lineage. The output of this script is a space-delimited text file ("Taxid_Taxonomy.txt") which contains the taxid of all genomes followed by their complete taxonomy.

- **get-taxonomy.pl**

Used this script to format the taxonomy. It uses the "Taxid_Taxonomy.txt" file as input, removes the taxids, and adds the appropriate taxonomic rank prefixes. The output generated is the "TaxonomyFile.txt".

- **Obtain the "Filesfna_Taxnm.txt"**

To associate each taxonomy with its corresponding genome file, use the following command:

    paste List_Files.txt TaxonomyFile.txt > Filesfna_Taxnm.txt
    
### 5) Obtain the MIMt database 
Use the script _get-txnm_fastaseq.pl_ to gather all the information in the new database. This script needs three inputs: 1) the output files from Infernal (.tbl), 2) the genome files (.fna), and 3) the "Filesfna_Taxnm.txt" file. From the Infernal outputs, the script gets the exact coordinates for the 16S rRNAs present in each genome, extracts the corresponding FASTA sequences from the original genome file, and assigns their respective taxonomy using the Filesfna_Taxnm.txt file. Use a shell script to execute it on all files. The resultant output corresponds to the new reference 16S rRNA database, named as MIMt.
