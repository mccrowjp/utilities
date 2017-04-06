use Time::HiRes qw(gettimeofday);

sub drawprogress($$$) {
    my $d=shift;
    my $t=shift;
    my $st=shift;
    my $ct=gettimeofday();
    my $p=int(1000*$d/$t)/10;
    my $n=int($p/5);
    my $es=-1;
    my $i;
    
    if($d>$t) {
	    $d=$t;
    }

    if($d>0) {
        if($d==$t) {
            # total time taken
            $es = int($ct-$st);
        } else {
            # estimated time remaining
    	    $es = int(($ct-$st)*(($t-$d)/$d));
        }
    }

    print STDERR "\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b";
    print STDERR "[";
    for($i=0;$i<$n;$i++) {
	    print STDERR "*";
    }
    for($i=0;$i<20-$n;$i++) {
    	print STDERR ".";
    }
    printf STDERR "] %d/%d %.1f\% ",$d,$t,$p;

    if($es > 0) {
        if($es > 7200) {
            print STDERR int($es/3600)."hr.";
        } elsif($es > 120) {
            print STDERR int($es/60)."min.";
        } else {
            print STDERR int($es)."sec.";
        }
    }
    print STDERR "      ";
  
}

sub eraseprogress() {
    print STDERR "\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b";
    print STDERR "                                                                               ";
    print STDERR "\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b";
}

1;
