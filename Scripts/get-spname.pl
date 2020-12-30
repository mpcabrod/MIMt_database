#!/usr/bin/perl

####################################################
#SCRIPT TO EXTRACT SPECIES NAME FROM A GENOME FILE #                                    
#                                                  #
#Author: M.Pilar Cabezas Rodríguez                 #
#Created: December 2020                            #
#                                                  #
####################################################

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
my $file;    #genome file
my $results; #output file
my $help;

#Set the variables to be used by the Getopt function  
GetOptions(
	"input|i=s"=>\$file,     
	"output|o=s"=>\$results,   
	"help"=>\$help
);

#If the input file exists
if ($file) {
	#Open the output file or print an error message if it is not possible
	open (OUT, ">>$results") || die "Error: problem opening $results\n";
	
	#Extract the first line (header) of the input file
	my $line=`head -1 $file`;
	
	#Remove newline
	chomp $line;
	#print "$line\n"; 
    
	#Get the identifier and species name split from the remaining information 
	my ($IDsp,$other)=split(/,/,$line);
	#print "$IDsp\n";
	
	#Get the identifier split from the species name 
	my ($ID,$spname)=split(/>\w+\.\d+\s/,$IDsp);
	#print "$spname\n";
	
	#Remove "extra" information from species name
	$spname=~s/DNA|complete genome|chromosome.*|strain.*|isolate.*|[sS]caffold.*|ctg.*//g;
	
	#Print the species name in the output file
	print OUT "$spname\n";
}

#If the input file does not exist, or parameters provided are wrong, the script provides a help
else {
	print STDERR "\nGetting help:\n
	$0 [--help]\n";
	
	print STDERR "\nNeeded parameters:\n
	[input|i] : Genome file (.fna)
	[output|o] : Output file name. It will contain the species names\n";
	
	print STDERR "\nUsage example:\n
	perl $0 -input|i input.fna -output|o SpNames.txt\n\n";
}

#Close open files
close(OUT);

