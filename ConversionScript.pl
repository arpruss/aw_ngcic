#
# This converts the tab-delimited export of NI2008.
#

use Text::CSV;

$sacNotes = 1;
$gottliebNotes = 1;

open B, "Barnard.csv" or die;
$csv = Text::CSV->new;

while(<B>) {
    s/[\r\n]//g;
    $csv->parse($_);
    @line = $csv->fields;
    print "B$line[0]\t<b>Barnard $line[0]</b>: $line[7]";
    $line[3] = 0 if $line[3] eq "";
    print "<br>R.A.: $line[1]h $line[2]m $line[3]s";
    $line[4] =~ s/^([-+]) /$1/g;
    @dec = split(/ /, $line[4]);
    $dec[1] += 0;
    print "<br>Dec.: $dec[0]° $dec[1]'";
    print "<br>Apparent size: ".size($line[5]) if $line[5];
    print "<br>Opacity: $line[6]\n";
}
close B;

$oldSep = $/;
undef $/;
open GOT, "<GottliebNotes.txt" or die;
$notes = <GOT>;
while($notes =~ s/(NGC\s+0*([0-9]+[a-z]?).*?)\*\*//s) {
    $niceID = "NGC ".$2;
    $note = $1."\n";
    $note =~ s/[\r\n]+/<br>/sg;
    $Gottlieb{$niceID} = $note;
}
close GOT;
$/ = $oldSep;

open SAC, "SAC_DeepSky_Ver80_QCQ.TXT" or die;
$_=<SAC>;
s/[\r\n]//g;
@labels = GetLine($_);
$i = 0;
foreach (@labels) {
    $I{$_} = $i++;
}
while(<SAC>) {
    if (!/,/) {
        next;
    }
    s/[\r\n]//g;
    s/\s+/ /g;
    s/\b0([0-9])/$1/g;
    @line = GetLine($_);
    $c = line("OBJECT");
    $c =~ s/\s+/ /g;
    $c = uc($c);
    $m = line("MAG");
    $m =~ s/[^-.0-9]//g;
    $mag{$c} = $m if $m ne "";
    $s = line("SUBR");
    $s =~ s/[^-.0-9]//g;
    $surf{$c} = $s if $s ne "99.9" and $s ne "";
    $r = line("NOTES");
    $r =~ s/\s+$//;
    $r =~ s/;\s*/; /g;
    $remark{$c} = $r if $r ne "";
    $n = line("NGC DESCR");
    $n =~ s/;\s*/; /g;
    $n =~ s/;/; /g;
    $descr{$c} = $n if $n ne "";
}

open D, "<Distances.txt" or die;
while(<D>) {
    if(/(.*)\t(.*)/) {
        $dist{$1} = $2;
    }
}
close D;

$red = ($ARGV[0] eq "red");

@classes = ( "", "Galaxy", 
             "Nebula", # Galactic Nebula or Supernova Remnant
             "Planetary nebula", "Open cluster", "Globular cluster",
             "Part of galaxy (e.g. bright HII regions)",
             "Object already in the NGC- or IC",
             "IC-object already in the NGC", "Star(s)", "Not found" );

%types = ( "*Grp"=> "asterism", "*"=>"star", "*2"=>"double star", "*3"=>"triple star",
             "*4"=>"quadruple star", "PRG"=>"polar ring galaxy",
             "GxyP"=>"part of galaxy", "OCL"=>"open cluster",
             "GCL"=>"globular cluster", "DN"=>"dark nebula",
             "EN"=>"emission nebula", "RN"=>"reflection nebula",
             "PN"=>"planetary nebula", "SNR"=>"supernova remnant",
             "NF"=>"not found",
             "C"=>"compact galaxy",
             "D"=>"dwarf galaxy",
             "E"=>"elliptical galaxy",
             "I"=>"irregular galaxy",
             "P"=>"peculiar galaxy",
             "S"=>"spiral galaxy",
             "Sd"=>"spiral dwarf galaxy (Sd)",
             "SB"=>"spiral barred galaxy (SB)",
             "SR"=>"spiral ring galaxy (SR)",
             "SM"=>"spiral mixed galaxy (SM)"
              );

open CONST, "constellations.txt" or die;

while(<CONST>) {
    s/\s*[\r\n]+//;
    s/\s+/ /g;
    if(/^([^ ]+) (.*)/) {
        $const{uc($1)} = $2;
    }
}

close CONST;

$_=<STDIN>;
s/[\r\n]//g;
@headings = split /\t/;
for $i (0..(@headings-1)) {
   $a = $headings[$i];
   $$a = $i;
}

while(<STDIN>) {
    s/[\r\n]//g;
    @l = split /\t/;
    if (!@l) {
        next;
    }

    if ( "" eq $l[$RH] ) {
        next;
    }

    if ( $l[$N] eq "N" ) {
        $id = "NGC";
        $niceID = "NGC ";
    }
    else {
        $id = "IC";
        $niceID = "IC ";
    }

    $id .= $l[$NI].$l[$A];
    $niceID .= $l[$NI].$l[$A];
    if ( $l[$C] ne "" ) {
       $id .= "-$l[$C]";
       $niceID .= "-$l[$C]";
    }

    print $id."\t";

    print "<red>" if $red;

    print "<b>$niceID</b>: ".$classes[$l[$S]]." in ".$const{$l[$CON]};
    @xref = ();
    $distance = $dist{$niceID};
    push @xref, "PGC $l[$PGC]" if $l[$PGC];
    push @xref, $l[$ID1] if $l[$ID1];
    push @xref, $l[$ID2] if $l[$ID2];
    push @xref, $l[$ID3] if $l[$ID3];
    if ( @xref ) {
        print "<br>Other catalogs: ";
        for $i (0..(@xref-1)) {
            if ($i) {
                print ", ";
            }
            print $xref[$i];
            $distance = $dist{$xref[$i]} if !defined($distance);
        }
    }
    print "<br>Type: ".type($l[$TYP],$l[$S]) if $l[$TYP] ne "";
    print "<br>R.A.: $l[$RH]h $l[$RM]m $l[$RS]s";
    print "<br>Dec.: $l[$V]$l[$DG]° $l[$DM]' $l[$DS]''";
    if ($l[$VMAG] ne "")  {
        print "<br>Visual magnitude: $l[$VMAG]";
    }
    elsif (defined($mag{$niceID})) {
        print "<br>Visual magnitude: $mag{$niceID} [SAC]";
    }
    print "<br>Blue magnitude: $l[$BMAG]" if $l[$BMAG] ne "";
    if ($l[$SB] ne "") {
        print "<br>Surface brightness: $l[$SB] mag/arcmin^2";
    }
    elsif(defined($surf{$niceID})) {
        print "<br>Surface brightness: $subr{$niceID} mag/arcmin^2 [SAC]";
    }
    if ($l[$X] ne "") {
        if ($l[$Y] eq "") {
            print "<br>Apparent size: ".size($l[$X]);
        }
        else {
            print "<br>Apparent size: ".size($l[$X])."x".size($l[$Y]);
        }
    }
    print "<br>Position angle: $l[$PA] deg." if $l[$PA] ne "";
    $l[$REM] =~ s/^\"//;
    $l[$REM] =~ s/\"$//;
    print "<br>Distance: $distance." if defined($distance);
    print "<br>Remarks: $l[$REM]" if $l[$REM] ne "";
    print "<br>Description: $descr{$niceID}" if defined($descr{$niceID});
    print "<br>SAC Remarks: $remark{$niceID}" if defined($remark{$niceID});
    print "<br>Gottlieb Notes: $Gottlieb{$niceID}" if defined($Gottlieb{$niceID});
    print "</red>" if $red;
    print "\n";
    for (@xref) {
        if (/\bM ([0-9]+)/ ) {
            print "M$1\t";
            print "<red>" if $red;
            print "See <a href=\"#$id\">$niceID</a>.";
            print "<red>" if $red;
            print "\n";
        }
    }
}


sub size {
    my $x = shift;

    if ( $x < 1 ) {
        $x *= 60;
        return $x.'"';
    }
    else {
        return $x."'";
    }
}


sub type {
    my $t = shift;
    my $c = shift;

    my @t = split(/\+/, $t);

    for my $i (0..(@t-1)) {
        my $query = ( $t[$i] =~ s/\?$// );

        if ( $t[$i] eq "Ring" ) {
            $t[$i] = "ring galaxy";
        }
        elsif ( $t[$i] =~ /^R(.*)/ and $classes[$c] eq "Galaxy" ) {
            $t[$i] = "ring galaxy";
            if ($1 ne "") {
                $t[$i] .= " $1";
            }
        }
        elsif ( $types{$t[$i]} ) {
            $t[$i] = $types{$t[$i]};
        }
        elsif ( $t[$i] =~ /^\*([0-9]+)$/ ) {
            $t[$i] = "$1-tuple star";
        }
        
        $t[$i] .= "?" if $query;
    }

    my $out;

    for my $i (0..(@t-1)) {
        if ( $i ) {
            $out .= "+";
        }
        $out .= $t[$i];
    }

    return $out;
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

