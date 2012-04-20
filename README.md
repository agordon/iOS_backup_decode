iOS_backup_decode
=================

Collection of scripts to decode an iOS backup (from libmobiledevice).

The libMobileDevice ( http://www.libimobiledevice.org/ ) library, with the associated utilities (idevicebackup, ideviceinstaller, etc.)
enables backing up an iOS device to a local directory.
Each file/database on the iOS device has a unique ID.
Soem of the files are standard SQLite databases, and these perl scripts reads the database files and dump some of the information in a friendly, readable format.

Current handled databases:
* AddressBook ( `31bb7ba8914766d4ba40d6dfb6113c8b614be442` )
* SMS database ( `3d0d7e5fb2ce288813306e4d4636395e047a3d28` )

Other databases which can be similary processed:
*  Notes ( `ca3bc056d4da0bbf88b5fb3be254f3b7147e639c` )
*  Safari Bookmarks (  `d1f062e2da26192a6625d968274bfda8d07821e4` )
*  Call History ( `2b2b0084a1bc3a5ac8c27afdf14afb42c61a19ca` )


Common workflow
===============

Backup your device
------------------

To backup an iOS device, install 'libmobiledevice' and associated utilities, and run:

    $ idevicebackup backup [BACKUP-DIRECTORY]
    
The directory will contain cryptic file names, such as:

    $ cd [BACKUP-DIRECTORY]
    $ ls
    fffa6225a88a50c7c48f04a3c8d58249a542bc85
    fff9fb13864a943dc7f3a5287a1163c3562da13c
    ffef48d7a403b6279276c7ca72ee48e7cebd454d
    ffec779ec78cdb982afb1cffeabd6408f225ec66
    ffea5ab4cbbeb59027e8893391920279b944391b
    ffe7d52c5a966918a9a86b2cbc6a25d948cc7557


Deciphering directory content
-----------------------------

The files in backup directory can be deciphered using the excellent `parse_mbdb.py` script (included in this package).
I found the file on stack-exchange, here: http://stackoverflow.com/questions/3085153/how-to-parse-the-manifest-mbdb-file-in-an-ios-4-0-itunes-backup

After backing up your device, run:

    $ cd [BACKUP-DIRECTORY]
    $ python parse_mbdb.py > manifest.txt

or, to sort the files by their associated program

    $ cd [BACKUP-DIRECTORY]
    $ python parse_mbdb.py | sort -t')' -k2,2V > manifest.txt


Manually explore a database file
--------------------------------

Quickly find all backed-up files which are SQLite3 databases:

    $ cd [BACKUP-DIRECTORY]
    $ file * | grep -i sqlite
    027cbce3ae649b49bfda37ebce598f567191df45: SQLite 3.x database
    02ab955e766685f80fc7c4c1b989a1b15129b4fd: SQLite 3.x database
    03261835a5da31173ebd1584fe9536520c624eb0: SQLite 3.x database
    04667ef88d54eba03a29147b0c22e1c908e70e3e: SQLite 3.x database

Use either `sqlitebrowser` (GUI) or `sqlite3` (command-line) programs to view the database file:

    $ sqlitebrowser [FILE]
    $ sqlite3 [FILE]




Using these scripts to pretty-print information
-----------------------------------------------

**List (some) information from the address book** (The address book DB schema is actually quite complicated, this script extracts the minimum amount of information. some missing fields may cause "use of uninitialized values" warnings.)

    $ cd [BACKUP-DIRECTORY]
    $ pretty_print_iphone_AddressBook.pl 31bb7ba8914766d4ba40d6dfb6113c8b614be442 > AddressBook.txt
    
**list SMSs, without cross-referecing the addressbook** (this should always work)

    $ decode_iphone_SMS_db.pl 3d0d7e5fb2ce288813306e4d4636395e047a3d28 > sms.txt
    
**List SMSs, trying to cross-reference with the address book** (Some missing fields may cause "use of uninitialized values" warnings)

    $ pretty_print_iphone_SMS.pl 31bb7ba8914766d4ba40d6dfb6113c8b614be442  3d0d7e5fb2ce288813306e4d4636395e047a3d28 > SMS2.txt
    


LICENSE
=======

LICENSE: AGPLv3
Copyright (C) 2012  A. Gordon (assafgordon at gmail dot com)

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.
