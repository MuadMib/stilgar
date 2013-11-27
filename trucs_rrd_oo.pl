#!/usr/bin/perl

use strict;

use RRDTool::OO;
use DateTime;
use Getopt::Long;
use vars qw($opt_h $opt_f);

Getopt::Long::Configure('bundling');
GetOptions
	("h"	=> \$opt_h, "help"	=> \$opt_h,
	 "f=f"	=> \$opt_f, "fichier=s"	=> \$opt_f,
);

if ($opt_h) {
	print "$0 -f|--fichier RRD_FILE\n";
}

$opt_f = shift unless ($opt_f);
my $fichier=$opt_f;

my $nunc = DateTime->from_epoch(epoch => time());
my $first = DateTime->from_epoch(epoch => time() - 4320*60);

my $rrd = RRDTool::OO->new(file => $fichier);
$rrd->create(
	step		=> 60,
	start		=> $first->epoch()-1,
	data_source	=> {
		name		=> "Exemple",
		type		=> "GAUGE"},
	archive		=> {rows	=> 4320},
	hwpredict	=> {
		rows	=> 4320,
		seasonal_period		=> 60,
		alpha    		=> 0.1,
		beta      		=> 0.0035,
		gamma    		=> 0.1,
		threshold		=> 2,
		window_length		=> 3}
);

my $inc;

for ($inc=$first->clone(); $inc <= $nunc; $inc->add(minutes =>1)) {
	if ($inc->epoch() <= 1352370000 || $inc->epoch() >= 1352375000) {
		$rrd->update(
			time	=> $inc->epoch(),
			value	=> $inc->strftime("%M")
		);
	} else {
		$rrd->update(
			time	=> $inc->epoch(),
			value	=> 40
		);
	}
}

#my $fimg=$fichier;
#$fimg=~s/rrd$/png/;
#$rrd->graph(
#	image			=> $fimg,
#	vertical_label		=> 'Test',
#	start			=> $first->epoch()+5040*60,
#	end			=> $nunc->epoch(),
#	draw			=> {
#		type			=> 'area',
#		color			=> '00FF00',
#		cfunc			=> 'MAX',
#		dsname			=> 'Exemple'},
#	draw			=> {
#		type			=> 'line',
#		color			=> '000000',
#		cfunc			=> 'MAX',
#		dsname			=> 'Exemple'},
#	draw			=> {
#		name			=> 'tick',
#		cfunc			=> 'FAILURES',
#		dsname			=> 'Exemple'},
#	tick			=> {
#		draw			=> 'tick',
##		stack			=> 1,
#		color			=> '#0000FF'},
#	draw			=> {
#		type			=> 'area',
#		color			=> '0000FF',
#		cfunc			=> 'FAILURES',
#		dsname			=> 'Exemple'},
#	draw			=> {
#		type			=> 'hidden',
#		cfunc			=> 'HWPREDICT',
#		name			=> 'pred1'},
#	draw			=> {
#		type			=> 'hidden',
#		cfunc			=> 'DEVPREDICT',
#		name			=> 'dev1'},
#	draw			=> {
#		type			=> 'line',
#		cdef			=> 'pred1,dev1,2,*,+',
#		color			=> 'ff0000'},
#	draw			=> {
#		type			=> 'line',
#		cdef			=> 'pred1,dev1,2,*,-',
#		color			=> 'ff0000'}
#	);
#
