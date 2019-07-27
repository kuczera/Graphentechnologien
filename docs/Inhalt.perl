#!/usr/bin/perl -w
# Normiert eine vorgegebene Liste von Kurztiteln
#
#
 $out = "@ARGV.out";


undef $/;
open (QUELLE, "<@ARGV");
$gesamt = <QUELLE>;
open (AUSGABE, ">$out");

$gesamt =~ s/Inhalt/\n/gs;
#\n\{:\.no\_toc\}\n\* Will be replaced with the ToC, excluding the "Contents" header\n{:toc}\n
$gesamt =~ s/\n[ ]+/\n/gs;

print AUSGABE ("$gesamt");

close (QUELLE);
close (AUSGABE);
