#!/usr/bin/perl

############################################################
#SCRIPT TO EXTRACT TAXONOMY INFORMATION USING A TAXID LIST #                                    
#                                                          #
#Author: M.Pilar Cabezas Rodríguez                         #
#Created: December 2020                                    #
#                                                          #
############################################################

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
my $taxreport; #output file from the NCBI Taxonomy Browser
my $taxfile;   #dump file downloaded from NCBI
my $results;   #output file
my $help;
my @data;
my $taxid1;
my @taxID1;
my $taxid2;
my $taxonomy;
my %output;

#Set the variables to be used by the Getopt function
GetOptions(
	"input1|i=s"=>\$taxreport,
	"input2|t=s"=>\$taxfile,
	"output|o=s"=>\$results,
	"help"=>\$help
);

#If the two input files exist
if ($taxreport && $taxfile) {
	#Open the file containing the list of species name and their corresponding taxid
	#or print an error message if it is not possible
	open (LIST,"$taxreport") || die "Error: problem opening $taxreport\n";
	
	#Open the output file or print an error message if it is not possible
	open (OUT, ">>$results") || die "Error: problem opening $results\n";
	
	#Read the file line by line to the end of the file
	while (my $line=<LIST>) {
		#Remove newline
		chomp $line;
		
		#If the line starts with a digit character
		if ($line=~/^\d/) {
			#print "$line\n";
			
			#Split the line by one or more tab, followed by "|" and one or more tab,
			#and keep them on a list
			@data=split(/\t+\|\t+/,$line);
			
			#The taxid corresponds to the data kept on the fourth element of the list
			$taxid1=$data[3];
			#print "$taxid1\n";
			#print "$data[1]: $taxid1\n";
			
			#Push the taxid values onto a new list
			push(@taxID1,$taxid1);
		}
	}
	
	#Open the dump file downloaded from NCBI,or print an error message if it is not possible
	open (TAX,"$taxfile") || die "Error: problem opening $taxfile\n";
	
	#Read the file line by line to the end of the file
	while (my $linea=<TAX>) {
		#Remove newline
		chomp $linea;
		
		#Split the line by one or more tab, followed by "|" and one or no tab,
		#and keep them on a list
		my @taxinf=split(/\t+\|\t?/,$linea);
		
		#The first element of the previous list corresponds to the taxid
		$taxid2=$taxinf[0];
		#print "$taxid2\n";
		
		#Remining elements from the list correspond to the taxonomy
		#Join them into a new variable 
		$taxonomy=join(";",@taxinf[1..$#taxinf]);
		#print "$taxonomy\n";
		
		#Declare a hash containing the taxids as keys and the taxonomy as values
		$output{$taxid2}=$taxonomy;
		#print "$taxid2 - $taxonomy\n";
	}
	
	#For each taxid from the "taxID1" list
	for my $Taxid1 (@taxID1) {
		#For each taxid from the "output" hash
		foreach my $Taxid2 (keys %output) {
			#If the two taxids are equal
			if ($Taxid1 == $Taxid2) {
				#Print the taxid and the taxonomy (value of the output hash) in the output file
				print OUT "$Taxid1 - $output{$Taxid2}\n";
			}
		}
	} 
}

#If the input files do not exist, or parameters provided are wrong, the script provides a help
else {
	print STDERR "\nGetting help:\n
	$0 [--help]\n";
	
	print STDERR "\nNeeded parameters:\n
	[input1|i1] : tax_report file containing the list of species name and their corresponding taxid
	[input2|t] : rankedlineage_ArcBac.dmp file
	[results|o] : Output file name. It will contain the taxids for all reference genomes and their taxonomy\n";
	
	print STDERR "\nUsage example:\n
	perl $0 -input1|i tax_report.txt -input2|t rankedlineage_ArcBac.dmp -results|o Taxid_Taxonomy.txt\n\n";
}

#Close open files
close (LIST);
close (TAX);
close (OUT);
