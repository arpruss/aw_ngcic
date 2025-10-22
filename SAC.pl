#
# This converts the tab-delimited export of NI2008.
#

$red = ($ARGV[0] eq "red");

open CONST, "constellations.txt" or die;

while(<CONST>) {
    s/\s*[\r\n]+//;
    s/\s+/ /g;
    if(/^([^ ]+) (.*)/) {
        $const{uc($1)} = $2;
    }
}

close CONST;

open D, "<Distances.txt" or die;
while(<D>) {
    if(/(.*)\t(.*)/) {
        $dist{$1} = $2;
    }
}
close D;

$_=<STDIN>;
s/[\r\n]//g;
@labels = GetLine($_);
$i = 0;
foreach (@labels) {
    $I{$_} = $i++;
}

while(<STDIN>) {
    if (!/,/) {
        next;
    }
    s/[\r\n]//g;
    s/\s+/ /g;
    s/\b0([0-9])/$1/g;
    @line = GetLine($_);
    $c = line("OBJECT");
    if ($c =~ /[0-9]/) {
        $c =~ s/\s+//g;
        $c = uc($c);
    }
    else {
        $c =~ s/\s+/ /g;
    }

    print "$c\t";

    print "<b>$c</b>: ".line("TYPE");
    print " (".line("CLASS").")" if line("CLASS") ne "";
    print " in ".$const{line("CON")};
    print "<br><b>R.A.:</b> ".line("RA") if line("RA") ne "";
    print "<br><b>Dec.:</b> ".line("DEC") if line("RA") ne "";
    print "<br><b>Magnitude:</b> ".line("MAG") if line("MAG") ne "99.9";
    print "<br><b>Surface brightness:</b> ".line("SUBR") if line("SUBR") ne "99.9";
    if (line("SIZE_MAX") ne "") {
        print "<br><b>Size:</b> ". line("SIZE_MAX");

        if (line("SIZE_MIN") ne "") {
            print " x ".line("SIZE_MIN");
        }
    }
    print "<br><b>Number of stars:</b> ".line("NSTS") if line("NSTS") ne "";
    print "<br><b>Star magnitude:</b> ".line("BRSTR") if line("BRSTR") ne "";
    print "<br><b>Other catalogs:</b> ".line("BCHM") if line("BCHM") ne "";
    $d = line("NGC DESCR");
    $d =~ s/;\s*/; /g;
    print "<br><b>Dreyer code:</b> ".$d if $d ne "";
    $n = line("NOTES");
    $n =~ s/;\s*/; /g;
    print "<br><b>Notes:</b> $n" if $n ne "";
    print "</red>" if $red;
    print "\n";
}


sub line {
    my $ind = shift;
    return $line[$I{$ind}];
}

sub GetLine {
    my $l = shift;
    $l =~ s/[\r\n]//g;
    $l =~ s/ +\"/\"/g;
    $l =~ s/^\"//;
    $l =~ s/\"$//;
    return split /\",\"/, $l;
}

