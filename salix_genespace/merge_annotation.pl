

my $anno_file = shift;
my $diff_file = shift;
my $outfile = shift;

unless (-e $diff_file) {
	print "File $diff_file does not exist.\n";
	return 0;
}

open ANNO_FH, "<", "$anno_file";
open DIFF_FH, "<", "$diff_file";
open OUT_FH, ">", "$outfile";

my $line = readline DIFF_FH;
my $annotation = readline ANNO_FH;
while (1) {
	# break if any of these files are done.
	if (!(defined $annotation)) { last; }
	if (!(defined $line)) { last; }

	$line =~ /^(.*?)\t(.*)$/;
	my $curr_gene = $1;
	my $diff_rest = $2;
	$annotation =~ /^(.*?)\t(.*)$/;
	my $anno_gene = $1;
	my $anno_rest = $2;

	# we're looking at curr_gene.

	if (($anno_gene cmp $curr_gene) < 0) {
		# if the anno_gene is less than curr_gene, move to the next anno_gene.
		$annotation = readline ANNO_FH;
		next;
	}
	if ($anno_gene eq $curr_gene) {
		# if the anno_gene is equal to curr_gene, print it out, advance to the next curr_gene.
		print "$anno_gene\t$diff_rest\t$anno_rest\n";

# 		my @bits = split (/\t/,$annotation);
# 		print "$curr_gene, $bits[10]\n";

		$line = readline DIFF_FH;
		$annotation = readline ANNO_FH;
		next;
	}
}

close DIFF_FH;
close ANNO_FH;
close OUT_FH;
