#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dump qw/dump/;
use DBI;

=pod

This script (tries) to print a usable list of SMSs, cross-referencing it with the iPhone's Address book.


The AddresBook database is this file:
   31bb7ba8914766d4ba40d6dfb6113c8b614be442
The SMS database is this file:
   3d0d7e5fb2ce288813306e4d4636395e047a3d28

Common workflow is:
   # Backup your device
   idevicebackup2 backup OUTPUT_DIRECTORY
   # ./pretty_print_iphone_SMS.pl [ADDRESS-BOOK-FILE] [SMS-FILE]
   ./pretty_print_iphone_SMS.pl OUTPUT_DIRECTORY/31bb7ba8914766d4ba40d6dfb6113c8b614be442 OUTPUT_DIRECTORY/3d0d7e5fb2ce288813306e4d4636395e047a3d28

=cut

=pod
   iPhone SMS database printer
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

sub show_help()
{
	print<<EOF;

iPhone SMS database printer
Copyright (C) 2012  A. Gordon (assafgordon at gmail dot com)
License: AGPLv3

Usage: pretty_print_iphone_SMS.pl [ADDRESS-BOOK-FILE] [SMS-FILE]

The AddresBook database is this file:
   31bb7ba8914766d4ba40d6dfb6113c8b614be442
The SMS database is this file:
   3d0d7e5fb2ce288813306e4d4636395e047a3d28

Common workflow is:
   # Backup your device
   idevicebackup2 backup OUTPUT_DIRECTORY
   # ./pretty_print_iphone_SMS.pl [ADDRESS-BOOK-FILE] [SMS-FILE]
   ./pretty_print_iphone_SMS.pl OUTPUT_DIRECTORY/31bb7ba8914766d4ba40d6dfb6113c8b614be442 OUTPUT_DIRECTORY/3d0d7e5fb2ce288813306e4d4636395e047a3d28

EOF
	exit(1);
}

my $iphone_Address_db = shift or show_help();
my $iphone_SMS_db = shift or show_help();


##
## Open the SMS and Addressbook databases
##
my %address_book;

my $dbh = DBI->connect("dbi:SQLite:dbname=$iphone_Address_db");
my $AddressBook_sql = "
Select
	ABPerson.First,
	ABPerson.Last,
	ABMultiValue.value
from
	ABPerson,
	ABMultiValue
where
	ABPerson.ROWID = ABMultiValue.record_id";

my $sth = $dbh->prepare($AddressBook_sql);
$sth->execute;
while ( my $ref = $sth->fetchrow_arrayref() ) {
	my ($first, $last, $value ) = @$ref ;

	$first //= "";
	$last //= "";

	next unless $value =~ /^[\+\-\(\) 0-9]+$/;

	my $normalized_phone = $value;
	$normalized_phone =~ s/[\(\)\- ]+//g;

	if (length($normalized_phone)==10 && $normalized_phone !~ /^\+/) {
		$normalized_phone = "+1" . $normalized_phone;
	}

	$address_book{$normalized_phone} = "$first $last";
}

##DEBUG
##print dump(\%address_book),"\n";


##
## Open the SMS database
##

$dbh = DBI->connect("dbi:SQLite:dbname=$iphone_SMS_db");
$sth = $dbh->prepare("select address,date,flags,text from message order by date" );
$sth->execute;

while ( my $ref = $sth->fetchrow_arrayref() ) {
	my ($address, $date, $flags, $text) = @$ref;
	my  ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($date);

	$address //= "";
	$text //= "";

	my $human_date = sprintf("%02d:%02d %02d/%02d/%04d", $hour, $min, $mday, $mon+1, $year+1900 );
	my $human_name = $address_book{$address} // "";

	my $quoted_text = $text // "";
	$quoted_text =~ s/\r/ \\r /gs;
	$quoted_text =~ s/\n/ \\n /gs;

	print join("\t", $human_date, $human_name, $address, (($flags==3)?"sent":"received"), $quoted_text),"\n";
}
