#This creates a DWORD key in the registry that fixes the Outlook issue where it constantly asks for a password in the lower right toolbar.
#Make sure the user has saved their work before running this script as it will restart their computer.

New-ItemProperty -Path "HKCU:\Software\Microsoft\Office\16.0\Common\Identity" -Name DisableADALatopWAMOverride -PropertyType DWORD -Value 1 -Force

Restart-Computer
