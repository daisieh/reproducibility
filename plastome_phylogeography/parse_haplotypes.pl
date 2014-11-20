#!/usr/bin/env perl

use strict;
use FindBin;
use lib "$FindBin::Bin/..";
use Subfunctions qw(split_seq reverse_complement meld_matrices);
use Data::Dumper;
use XML::Writer;
use XML::Smart;
  use IO::File;

my $data_file = shift;
my $haplotypes = shift;
# my $kml_file = shift;

# my $parser = XML::LibXML->new();
# my $doc = XML::LibXML->load_xml( location => $kml_file );
# print $doc->toString();
my $populations = {};
my $samples_lookup = {};
open FH, "<", $data_file;
#
foreach my $line (<FH>) {
	if ($line =~ /^#/) {
		#comment line, skip.
		next;
	}
#
	#1file_id	2sample	3DNA_code	4species	5pop_code	6pop_name	7LONG	8LAT	9server	10path	11sorted
	my ($file_id, $sample, $dna_code, $species, $pop_code, $pop_name, $long, $lat, undef) = split (/\t/, $line, 9);
#
	if ($species =~ /PBAL|PTRI/) {
		$populations->{$species}->{$pop_code}->{$sample}->{"dna_code"} = $dna_code;
		$populations->{$species}->{$pop_code}->{$sample}->{"lat"} = $lat;
		$populations->{$species}->{$pop_code}->{$sample}->{"long"} = $long;
		$samples_lookup->{$sample} = $populations->{$species}->{$pop_code}->{$sample};
	}
}
#
close FH;
#
foreach my $species (keys %$populations) {
	foreach my $pop (keys %{$populations->{$species}}) {
		my $lat_sum = 0;
		my $long_sum = 0;
		my $count = 0;
		foreach my $sample (keys %{$populations->{$species}->{$pop}}) {
			$lat_sum += $populations->{$species}->{$pop}->{$sample}->{"lat"};
			$long_sum += $populations->{$species}->{$pop}->{$sample}->{"long"};
			$count++;
		}
		$populations->{$species}->{$pop}->{"lat"} = $lat_sum / $count;
		$populations->{$species}->{$pop}->{"long"} = $long_sum / $count;
	}
}

open FH, "<", $haplotypes;
foreach my $line (<FH>) {
	my ($sample, $hap) = split (/\t/,$line);
	chomp $hap;
	if (exists $samples_lookup->{$sample}) {
		$samples_lookup->{$sample}->{"haplotype"} = $hap;
	}
}
close FH;
foreach my $species (keys %$populations) {
	foreach my $pop (keys %{$populations->{$species}}) {
		if (!exists $populations->{$species}->{$pop}->{"haplotypes"}) {
			$populations->{$species}->{$pop}->{"haplotypes"}->{"A"} = 0;
			$populations->{$species}->{$pop}->{"haplotypes"}->{"A1"} = 0;
			$populations->{$species}->{$pop}->{"haplotypes"}->{"B"} = 0;
			$populations->{$species}->{$pop}->{"haplotypes"}->{"C"} = 0;
			$populations->{$species}->{$pop}->{"haplotypes"}->{"D"} = 0;
			$populations->{$species}->{$pop}->{"haplotypes"}->{"T"} = 0;
			$populations->{$species}->{$pop}->{"haplotypes"}->{"U"} = 0;
			$populations->{$species}->{$pop}->{"haplotypes"}->{"Aige"} = 0;
			$populations->{$species}->{$pop}->{"haplotypes"}->{"Het"} = 0;
			$populations->{$species}->{$pop}->{"haplotypes"}->{"Other"} = 0;
		}
		foreach my $sample (keys %{$populations->{$species}->{$pop}}) {
			if ($sample !~ /lat|long/) {
				my $hap = $populations->{$species}->{$pop}->{$sample}->{"haplotype"};
				$populations->{$species}->{$pop}->{"haplotypes"}->{$hap} += 1;
			}
		}
	}
}

print "pop\tspecies\tloc\tA\tA1\tB\tC\tD\tT\tU\n";
foreach my $species (keys %$populations) {
	foreach my $pop (keys %{$populations->{$species}}) {
		print "$pop\t$species\t";
		print "-$populations->{$species}->{$pop}->{long}, $populations->{$species}->{$pop}->{lat}\t";
		print $populations->{$species}->{$pop}->{"haplotypes"}->{"A"} . "\t";
		print $populations->{$species}->{$pop}->{"haplotypes"}->{"A1"} . "\t";
		print $populations->{$species}->{$pop}->{"haplotypes"}->{"B"} . "\t";
		print $populations->{$species}->{$pop}->{"haplotypes"}->{"C"} . "\t";
		print $populations->{$species}->{$pop}->{"haplotypes"}->{"D"} . "\t";
		print $populations->{$species}->{$pop}->{"haplotypes"}->{"T"} . "\t";
		print $populations->{$species}->{$pop}->{"haplotypes"}->{"U"} ;
		print "\n";
	}
}

# 	<Document>
# 		<name>balsamifera</name>
# 		<Placemark>
# 			<styleUrl>#icon-503-FFFFFF</styleUrl>
# 			<name>BOY</name>
# 			<ExtendedData>
# 				<Data name='D'>
# 					<value></value>
# 				</Data>
# 			</ExtendedData>
# 			<Point>
# 				<coordinates>-112.65,54.55,0.0</coordinates>
# 			</Point>
# 		</Placemark>

# my $kml_hash = {};
# $kml_hash->{"Document"}->{"name"} = "test doc";
# foreach my $species (keys %$populations) {
# 	my $popcount = 0;
# 	$kml_hash->{"Document"}->{"Placemark"} = ();
# 	foreach my $pop (keys %{$populations->{$species}}) {
# 		my $pop_data = {};
# 		$pop_data->{"name"} = $pop;
#
# 		$pop_data->{"Point"}->{"coordinates"} = "-$populations->{$species}->{$pop}->{long},$populations->{$species}->{$pop}->{lat},0.0";
# 		push @{$kml_hash->{"Document"}->{"Placemark"}}, $pop_data;
# 	}
# }
# print Dumper($kml_hash);
#
# my $xml = XML::Smart->new(q`<?xml version='1.0' encoding='UTF-8'?>
# <kml xmlns='http://www.opengis.net/kml/2.2'>
# </kml>`);
# my $count = 0;
# # foreach my $species (keys %$populations) {
# # 	$xml->{"kml"}->{$species}[$count++] = $populations->{$species};
# # 	foreach my $pop (keys %{$populations->{$species}}) {
# # 		$xml->{"kml"}->{"pop"} = $pop;
# # 	}
# # }
# $xml->{"kml"} = $kml_hash;
# $xml->save('output.kml') ;
# # print $xml->data();
