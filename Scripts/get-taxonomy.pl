#!/usr/bin/perl

#####################################
#SCRIPT TO FORMAT THE TAXONOMY      #                                    
#                                   #
#Author: M.Pilar Cabezas Rodríguez  #
#Created: December 2020             #
#                                   #
#####################################

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
my $taxidtxnmfile; #File with the taxids and taxonomy associated
my $results;       #output file
my $help;
my $taxid;
my $taxonomy;
my %sp;

#Set the variables to be used by the Getopt function
GetOptions(
	"input1|i=s"=>\$taxidtxnmfile,
	"output|o=s"=>\$results,
	"help"=>\$help
);

#If the input file exist
if ($taxidtxnmfile) {
    #Open the file, or print an error message if it is not possible
	open (TAXN, "$taxidtxnmfile") || die "Error: problem opening $taxidtxnmfile\n";
	
	#Open the output file, or print an error message if it is not possible
	open (OUT, ">>$results") || die "Error: problem opening $results\n";
	
	#Read the file line by line to the end of the file
	while (<TAXN>) {
		#Remove newline
		chomp $_;
		
		#Get the taxids split from the taxonomy information
		($taxid,$taxonomy)=split(/\s-\s/,$_);
		#print "$taxid\n";
		#print "$taxonomy\n";
		
		#Split the taxonomy to extract each one of the categories
		(my $sp,my $white,my $Gen,my $Fam,my $Ord,my $Class,my $Phyl,my $white2,my $King)=split(/;/,$taxonomy);
		#print "$sp -- $white -- $Gen -- $Ord -- $Class -- $Phyl -- $white2 -- $King\n";
		
		#Format the taxonomy and print it in the output file
		print OUT "K__$King; P__$Phyl; C__$Class; O__$Ord; F__$Fam; G__$Gen; S__$sp\n";
	}
}

#If the input files do not exist, or parameters provided are wrong, the script provides a help
else {
	print STDERR "\nGetting help:\n
	$0 [--help]\n";
	
	print STDERR "\nNeeded parameters:\n
	[input1|i1] : File containing the taxids for all reference genomes and their taxonomy (Taxid_Taxonomy.txt)
	[results|o] : Output file name. It will contain the formatted taxonomy\n";
	
	print STDERR "\nUsage example:\n
	perl $0 -input1|i Taxid_Taxonomy.txt -results|o TaxonomyFile.txt\n\n";
}

#Close open files
close(TAXN);
close(OUT);
