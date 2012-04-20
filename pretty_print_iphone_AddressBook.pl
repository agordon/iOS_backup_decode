#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dump qw/dump/;
use DBI;

=pod
This script reads an AddressBook SQLite database (as extracted by libmobiledecive)
and lists the content of the contacts

The AddresBook database is this file:
   31bb7ba8914766d4ba40d6dfb6113c8b614be442

Common workflow is:
   # Backup your device
   idevicebackup2 backup OUTPUT_DIRECTORY
   ./pretty_print_iphone_AddressBook.pl OUTPUT_DIRECTORY/31bb7ba8914766d4ba40d6dfb6113c8b614be442
=cut

=pod
   iPhone Address Book database decode
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

##
## Open the SMS and Addressbook databases
##
my %address_book;

my $iphone_Address_db =  shift or die "Error: missing Address Book SQLite database file (e.g. 31bb7ba8914766d4ba40d6dfb6113c8b614be442)\n";

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
	ABPerson.ROWID = ABMultiValue.record_id
order by
	ABPerson.First,
	ABPerson.Last
";

my $sth = $dbh->prepare($AddressBook_sql);
$sth->execute;
while ( my $ref = $sth->fetchrow_arrayref() ) {
	my ($first, $last, $value ) = @$ref ;

	$first = "" unless $first;
	$last  = "" unless $last;

	print join("\t", $first, $last, $value),"\n";

}
