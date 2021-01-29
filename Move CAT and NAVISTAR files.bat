:: This script creates a folder with today's date in MM-DD-YY format and moves the CATPV and CATDX EDI files into it. Then moves the newly created folder into the Perkins Not Processed Folder. This script must placed in the Z:\CatFTP\Inbox folder to work. ::
:: Also moves the NAVISTAR files into the Navisator folder ::

:: Create a new folder in MM-DD-YY format ::
MKDIR %date:~-10,2%"-"%date:~7,2%"-"%date:~-2,2%

:: Moves CATPV and CATDX files into newly created folder.::
MOVE /-Y CATDX*.edi "%date:~-10,2%"-"%date:~7,2%"-"%date:~-2,2%"
MOVE /-Y CATPV*.edi "%date:~-10,2%"-"%date:~7,2%"-"%date:~-2,2%"

:: Moves newly created folder with CATPV and CATDX files into Perkins Not Processed folder ::
MOVE /-Y "%date:~-10,2%"-"%date:~7,2%"-"%date:~-2,2%" "Perkins Not Processed"

:: Moves NAVISTAR files into the NAVISTAR folder ::
MOVE /-Y "Z:\SoftshareFTP\Inbox\NAVISTAR-862-862-*.edi" "Z:\SoftshareFTP\Inbox\Navistar 862"
