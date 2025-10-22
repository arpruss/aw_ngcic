for $m (1..110) {
    $d = GetDistance($m);
    print "M $m\t$d\n" if $d ne "";
}
sub GetDistance {
    my $m = shift;
    $url = sprintf "http://www.messier.obspm.fr/m/m%03d.html", $m;
    my $_ = `wget -O - $url`;
    if ( /Distance\<\/th\>\s*\n\s*\<td[^>]*\>([0-9]+[^<]*)/ ) {
        return $1;
    }
    else {
        return "";
    }
}
