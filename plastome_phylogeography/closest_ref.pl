#!/usr/bin/perl

my $infile = shift;

open FH, "<", $infile or die "couldn't open $infile";

my $line = readline FH;
chomp $line;
my @names = split(/\t/,$line);
shift @names;

foreach $line (<FH>) {
	chomp $line;
	my @samples = split(/\t/,$line);
	my $sampname = shift @samples;
	my $min_name = $names[0];
	my $min = $samples[0];
	for (my $i=1;$i<@samples;$i++) {
		if ($samples[$i] < $min) {
			$min_name = $names[$i];
			$min = $samples[$i];
		}
	}
	print "$sampname\t$min_name\t$min\n";
}

