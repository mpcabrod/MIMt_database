#!/usr/bin/perl

#########################################################
#SCRIPT TO EXTRACT 16 rRNA SEQUENCES FROM GENOME FILES  #
#      AND ASSIGN THEIR CORRESPONDING TAXONOMY          #
#                 (INFERNAL output)                     #              
#                                                       #
#Author: M.Pilar Cabezas Rodríguez                      #
#Created: December 2020                                 #
#                                                       #
#########################################################

#Check Getopt::Long module version. Use this module if the installed version is >= 2.5, otherwise it ask for installing it
BEGIN {
	use Getopt::Long;
	die "You have an *old* version of Getopt::Long, please ",
	    "update it asap!!\n"
	    unless Getopt::Long->VERSION >= 2.5;
}

#Set the modules to be used
use strict;
use warnings;

#Set the main variables
my $file;       #output file from Infernal programm (.tbl)
my $reference;  #genome file (.fna)
my $fnatxm;     #file containing the genome files names and their corresponding taxonomy
my $results;    #output file
my $help;
my $fna;
my $taxonomy;
my %info;
my @data;
my @organism;
my $ID;
my $seq;
my %gen;
my $columns;
my $length;
my $reverse;
my $rna;
my %output;

#Set the variables to be used by the Getopt function
GetOptions(
	"input|i=s"=>\$file,
	"reference|r=s"=>\$reference,
	"txnmfile|t=s"=>\$fnatxm,
	"results|o=s"=>\$results,
	"help"=>\$help
);

#If the three input files exist
if ($fnatxm && $reference && $file) {
	#Open the file containing the genome files names and their corresponding taxonomy,
	#or print an error message if it is not possible
	open (TXNM, "$fnatxm") || die "Error: problem opening $fnatxm\n";
	
	#Read the file line by line to the end of the file
	while (my $linea=<TXNM>) {
		#Remove newline
		chomp $linea;
		
		#Split the name of the genome file from the taxonomy
		($fna, $taxonomy)=split(/\t/,$linea);
		#print "$fna ---- $taxonomy\n";
		
		#Declare a hash containing the name of the genome file as keys and their taxonomy as values
		$info{$fna}=$taxonomy;
		#print "$fna -- $info{$fna}\n";
	}
	
	#Open the genome file, or print an error message if it is not possible
	open (FASTA, "$reference") || die "Error: problem opening $reference\n";
	
	#Read the file line by line to the end of the file
	while (my $linea=<FASTA>) {
		#Remove newline
		chomp $linea;
		#If the line begin with a ">" (header of FASTA file)
		if ($linea=~/^>/) {
			#print "$linea\n";
			
			#Split the ">" character from the organism information, and keep them on a list
			@data=split(/>/,$linea);
			#The second column contains the organism information
			#print "$data[1]\n";
			
			#Split to extract the identifier from the organism information
			@organism=split(/\s/,$data[1]);
			
			#The first element of the list contains the identifier
			$ID=$organism[0];
			#print "$ID\n";
			
			#Declare an empty variable to keep the sequences
			$seq="";
		}
		
		#All lines that does not begin with ">" character, correspond to the sequences
		else {
			#Concatenate the sequences in the variable "seq"
			$seq.=$linea;
			#print "$linea\n"; 
			
			#Declare a hash containing the identifiers as keys and their sequence as values
			$gen{$ID}=$seq;
		}
	}
	
	#Open the output file from Infernal, or print an error message if it is not possible
	open (TBL,"$file") || die "Error:problem opening $file\n";
	
	#Open the output file or print an error message if it is not possible
	open (OUT,">>$results") || die "Error:problem opening $results\n";
	
	#Read the file line by line to the end of the file
	while (my $linea=<TBL>) {
		#Remove newline
		chomp $linea;
		
		#Continue only if the line does not begin with "#" (which corresponds with lines containing the 16S information)
		next if ($linea=~/^#/);
		#print "$linea\n";
		
		#Split the different columns, which are separated by one or more spaces
		my @columns=split(/\s+/,$linea);
		 
		#The fourth element of the list contains the identifier	
		my $identifier=$columns[3];
		#The tenth element of the list contains the start position of the 16S sequence
		my $start=$columns[9];
		#The eleventh element of the list contains the end position of the 16S sequence
		my $end=$columns[10];
		#The twelfth element of the list indicates if the 16S is located in the forward(+) or reverse(-) strand
		my $strand=$columns[11];
		#The nineteenth element of the list indicates whether(!) or not(?) the 16S found achieves the inclusion threshold
		my $sign=$columns[18];
		#print "$identifier---$start,$strand,$end,$sign\n";
			
		#If the sign is "!" (i.e., the 16S found achieves the inclusion threshold)
		if ($sign eq "!") {
			#If it is located in the reverse strand
			if ($strand eq "-") {
				#Sequence length is equal to the start position (higher value) minus the end position (lower value), plus 1
				$length=$start-$end+1;
				
				#Extract the sequence corresponding to 16S rRNA by substring from the genome sequence, 
				#the length of the 16S sequence, starting from a position before to the end of the sequence
				$reverse=substr $gen{$identifier}, $end-1, $length;
				
				#Replace DNA bases with their equivalent complementary in the RNA
				$reverse=~ tr/ACGTacgt/UGCAugca/;
				
				#Return the sequence in the opposite order (it corresponds with the RNA sequence)
				$rna=reverse($reverse);
				
				#Declare a hash containing the identifier and end positions as keys, and the start position 
				#and RNA sequence as values
				$output{$identifier}{$end}="$start\n$rna";
				#print "$identifier -- $end-$output{$identifier}{$end}\n"
			}
			
			#If the 16S sequence found is located in the forward strand
			else {
				#Sequence length is equal to the end position (higher value) minus the start position (lower value), plus 1
				$length=$end-$start+1;
				
				#Extract the sequence corresponding to 16S rRNA by substring from the genome sequence, 
				#the length of the 16S sequence, starting from a position before to the begin of the sequence
				$rna = substr $gen{$identifier}, $start-1, $length;
				
				#Replace the T DNA base with its equivalent in the RNA (U)
				$rna =~ tr/Tt/Uu/;
				
				#Declare a hash containing the identifier and start positions as keys, and the end position 
				#and RNA sequence as values
				$output{$identifier}{$start}="$end\n$rna";
				#print "$identifier -- $start-$output{$identifier}{$start}\n"
			}
		}
		#If the sign is "?" (i.e., the 16S found does not achieve the inclusion threshold),
		#skip this line
		else { 
			next;
		}
	}	
	
	#For each genome file name from the "info" hash
	foreach my $file (keys %info) {
		#If the name is equal to the genome file downloaded from NCBI
		if ($file eq $reference) {
			#For each identifier from the "output" hash (sorted in ascending order)
			foreach my $id (sort {$a cmp $b} keys %output) {
				#print "$id\n";
				#For each start position of the sequence (sorted)
				foreach my $start (sort keys %{$output{$id}}) {
					#Print the identifier followed by its taxonomic information, the start and end position
					#of the 16S rRNA gene in the next line, and its sequence in the following line
					print OUT ">$id -- $info{$file}\nStart-End: $start-$output{$id}{$start}\n";
				}
			}
		}
	}
}

#If the input files do not exist, or parameters provided are wrong, the script provides a help
else {
	print STDERR "\nGetting help:\n
	$0 [--help]\n";
	
	print STDERR "\nNeeded parameters:\n
	[input|i] : Output file from Infernal programm (.tbl)
	[reference|r] : Genome file (.fna)
	[txnmfile|t] : File containing the genome files names and their corresponding taxonomy (Filesfna_Taxnm.txt)
	[results|o] : Output file name. It will correspond to the new 16S rRNA reference database\n";
	
	print STDERR "\nUsage example:\n
	perl $0 -input|i input.tbl -reference|r reference.fna -txnmfile|t Filesfna_Taxnm.txt -results|o MIMt_Infernal.fna\n\n";
}

#Close open files
close (TXNM);
close (FASTA);
close (TBL);
close (OUT);
