#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dump qw/dump/;
use DBI;

=pod
This script reads an SQLite database (as extracted by libmobiledecive)
and lists the content of the SMSs.

The SMS database is this file:
   3d0d7e5fb2ce288813306e4d4636395e047a3d28

Common workflow is:
   # Backup your device
   idevicebackup2 backup OUTPUT_DIRECTORY
   ./decode_iphone_SMS_db.pl OUTPUT_DIRECTORY/3d0d7e5fb2ce288813306e4d4636395e047a3d28
=cut

=pod
   iPhone SMS database decode
   Copyright (C) 2012  A. Gordon (assafgordon at gmail dot com)

   LICENSE: AGPLv3

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU Affero General Public License as
   published by the Free Software Foundation, either version 3 of the
   License, or (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU Affero General Public License for more details.

   You should have received a copy of the GNU Affero General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.
=cut

my $iphone_SMS_db = shift or die "Error: missing SQLite database file of iPhone SMSs\n";
die "Error: can't find file '$iphone_SMS_db'\n" unless -r $iphone_SMS_db;
my $dbh = DBI->connect("dbi:SQLite:dbname=$iphone_SMS_db");

my $sth = $dbh->prepare("select address,date,flags,text from message order by date" );
$sth->execute;

while ( my $ref = $sth->fetchrow_arrayref() ) {
	my ($address, $date, $flags, $text) = @$ref;
	my  ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($date);

#	print "\n";
	my $human_date = sprintf("%02d:%02d %02d/%02d/%04d", $hour, $min, $mday, $mon+1, $year+1900 );
#	print dump($ref),"\n";

	print join("\t", $human_date, $address, (($flags==3)?"sent":"received"), $text),"\n";
}
