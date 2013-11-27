#!/usr/bin/perl

use strict;

#Extract des rrtools
#        /* Bestfit line by linear least squares method */
#
#        int       cnt = 0;
#        double    SUMx, SUMy, SUMxy, SUMxx, SUMyy, slope, y_intercept, correl;
#
#        SUMx = 0;
#        SUMy = 0;
#        SUMxy = 0;
#        SUMxx = 0;
#        SUMyy = 0;
#        for (step = 0; step < steps; step++) {
#            if (finite(data[step * src->ds_cnt])) {
#                cnt++;
#                SUMx += step;
#                SUMxx += step * step;
#                SUMxy += step * data[step * src->ds_cnt];
#                SUMy += data[step * src->ds_cnt];
#                SUMyy += data[step * src->ds_cnt] * data[step * src->ds_cnt];
#            };
#        }
#
#        slope = (SUMx * SUMy - cnt * SUMxy) / (SUMx * SUMx - cnt * SUMxx);
#        y_intercept = (SUMy - slope * SUMx) / cnt;
#        correl =
#            (SUMxy -
#             (SUMx * SUMy) / cnt) /
#            sqrt((SUMxx -
#                  (SUMx * SUMx) / cnt) * (SUMyy - (SUMy * SUMy) / cnt));

my $iter;
my $value;
my $noise;

my $slope=0; my $y_intercept=0; my $correl;
my @data;
my $maxvals=10000;
my $maxiters=50;

my $temps=0;
my $seuil=50000;

sub carres {
	my ($tps,$nbiters,@datatmp)=@_;

	my $step=0;
	my $slope=0; my $y_intercept=0; my $correl=0;
	my $cnt=0; my $SUMx=0; my $SUMy=0; my $SUMxy=0; my $SUMxx=0; my $SUMyy=0;
	for ($step=0;$step<$nbiters;$step++) {
# Too lazy to test NaN or not ...
#	if(finite($datatmp[$step*($tps)])) {
		$cnt++;
		$SUMx+=$tps+$step;
		$SUMxx+=($tps+$step)*($tps+$step);
		$SUMxy+=($tps+$step)*$datatmp[$step];
		$SUMy+=$datatmp[$step];
		$SUMyy+=$datatmp[$step]*$datatmp[$step];
#	}
#print "For : ".$step." ".$SUMx." ".$SUMxx." ".$SUMxy." ".$SUMy." ".$SUMyy." ".$cnt."\n";
	}
	$slope=($SUMx*$SUMy-$cnt*$SUMxy)/($SUMx*$SUMx-$cnt*$SUMxx);
	$y_intercept=($SUMy-$slope*$SUMx)/$cnt;
# put a bad abs for sqrt
	if($cnt!=0){
		if(($SUMxx-$SUMx*$SUMx/$cnt)*($SUMyy-$SUMy*$SUMy/$cnt)>0) {
			$correl=($SUMxy-$SUMx*$SUMy/$cnt)/sqrt(($SUMxx-$SUMx*$SUMx/$cnt)*($SUMyy-$SUMy*$SUMy/$cnt));
		}
	} else {
		$correl=0;
	}
#	print "carres : ".($tps+$nbiters)." ".($slope*($tps+$nbiters)+$y_intercept)." ".$slope." ".$y_intercept." ".$correl."\n";
	return($slope,$y_intercept,$correl);
}

for ($iter=0;$iter<200;$iter++) {
#	$noise=rand($iter/200.00);
#	$data[$iter]=($iter+$noise);
#	$noise=sin($iter)*$iter/200.00;
	$data[$iter]=100-200*exp(-((($iter+2)/200)*(($iter+2)/200)));
}

for ($iter=200;$iter<$maxvals;$iter++) {
	(my $slope,my $y_intercept,my $correl)=carres(($iter-$maxiters),$maxiters,@data[$iter-$maxiters..$iter-1]);
	$data[$iter]=$slope*($iter)+$y_intercept;
	if($data[$iter]>$seuil) {
		$temps=$iter;
		last;
	}
}

print "Temps de convergence : ".$temps."\n";
#for ($iter=0;$iter<200;$iter++) {
for ($iter=0;$iter<$temps;$iter++) {
	print $data[$iter]."\n";
}
