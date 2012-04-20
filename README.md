iOS_backup_decode
=================

Collection of scripts to decode an iOS backup (from libmobiledevice).

The libMobileDevice ( http://www.libimobiledevice.org/ ) library, with the associated utilities (idevicebackup, ideviceinstaller, etc.)
enables backing up an iOS device to a local directory.
Each file/database on the iOS device has a unique ID.
Soem of the files are standard SQLite databases, and these perl scripts reads the database files and dump some of the information in a friendly, readable format.

Current handled databases:
 AddressBook ( 31bb7ba8914766d4ba40d6dfb6113c8b614be442 )
 SMS database ( 3d0d7e5fb2ce288813306e4d4636395e047a3d28 ).

Other databases which can be similary processed:
  Notes ( ca3bc056d4da0bbf88b5fb3be254f3b7147e639c )
  Safari Bookmarks (  d1f062e2da26192a6625d968274bfda8d07821e4 )
  Call History ( 2b2b0084a1bc3a5ac8c27afdf14afb42c61a19ca )

To manually explore a database file, either:
  1.  install the sqlitebrowser program (GUI), and run:
      $ sqlitebrowser [FILE]

  2.  install the sqlite3 program (command-line interface, like "mysql" or "psql") and run:
      $ sqlite3 [FILE]


To backup an iOS device, install 'libmobiledevice' and associated utilities, and run:
  $ idevicebackup backup [OUTPUT-DIRECTORY]

The files in [OUTPUT-DIRECTORY] can be deciphered using the excellent `parse_mbdb.py` script (included in this package).
I found the file on stack-exchange, here: http://stackoverflow.com/questions/3085153/how-to-parse-the-manifest-mbdb-file-in-an-ios-4-0-itunes-backup

After backing up your device, run:
  $ cd [OUTPUT-DIRECTORY]
  $ python parse_mbdb.py > manifest.txt

  # or, to sort the files by their associated program:
  $ python parse_mbdb.py | sort -t')' -k2,2V > manifest.txt


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
