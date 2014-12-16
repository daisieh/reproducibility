#!/usr/bin/env perl

use strict;
use FindBin;
use Data::Dumper;

my $data_file = shift;
my $haplotypes = shift;
my $populations = {};
my $samples_lookup = {};
open FH, "<", $data_file;

foreach my $line (<FH>) {
	if ($line =~ /^#/) {
		#comment line, skip.
		next;
	}
# 	1file_id	2sample	3DNA_code	4species	5pop	6pop_name	7LONG	8LAT	9server	10path	11sorted

	my ($file_id, $sample, $dna_code, $species, $pop_code, $pop_name, $long, $lat, undef) = split (/\t/, $line, 9);

	if ($species =~ /PBAL|PTRI/) {
		$populations->{$species}->{$pop_code}->{$file_id}->{"lat"} = $lat;
		$populations->{$species}->{$pop_code}->{$file_id}->{"long"} = $long;
		$samples_lookup->{$file_id} = $populations->{$species}->{$pop_code}->{$file_id};
	}
}

close FH;

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
		$populations->{$species}->{$pop}->{"total"} = 0;
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
			$populations->{$species}->{$pop}->{"haplotypes"}->{"T1"} = 0;
			$populations->{$species}->{$pop}->{"haplotypes"}->{"T2"} = 0;
			$populations->{$species}->{$pop}->{"haplotypes"}->{"T3"} = 0;
			$populations->{$species}->{$pop}->{"haplotypes"}->{"PG"} = 0;
			$populations->{$species}->{$pop}->{"haplotypes"}->{"B1"} = 0;
			$populations->{$species}->{$pop}->{"haplotypes"}->{"B2"} = 0;
			$populations->{$species}->{$pop}->{"haplotypes"}->{"B3"} = 0;
		}
		foreach my $sample (keys %{$populations->{$species}->{$pop}}) {
			if ($sample !~ /lat|long|total/) {
				my $hap = $populations->{$species}->{$pop}->{$sample}->{"haplotype"};
				$populations->{$species}->{$pop}->{"haplotypes"}->{$hap} += 1;
				if ($hap ne "") {
					$populations->{$species}->{$pop}->{"total"} += 1;
				}
			}
		}
	}
}
# print Dumper ($populations);
my @haps = ("T1","T2","T3","PG","B1","B2","B3");
print "popu\tspecies\tlong\tlat\t" . join("\t", @haps) . "\ttotal\n";
foreach my $species (keys %$populations) {
	foreach my $pop (keys %{$populations->{$species}}) {
		if ($populations->{$species}->{$pop}->{"total"} > 0) {
			my $total = $populations->{$species}->{$pop}->{"total"};
			print "$pop\t$species\t";
			print "-$populations->{$species}->{$pop}->{long}\t$populations->{$species}->{$pop}->{lat}\t";
			foreach my $h (@haps) {
				my $t = $populations->{$species}->{$pop}->{"haplotypes"}->{$h} / $total;
				if ($t =~ /(\d\.\d\d).*/) {
					$t = $1;
				}
				if ($t == 0) {
					$t = 0.000001;
				}
				print "$t\t";
			}

			print "$total\n";
		}
	}
}
