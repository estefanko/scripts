New-ItemProperty -Path "HKCU:\Software\Microsoft\Office\16.0\Common\Identity" -Name DisableADALatopWAMOverride -PropertyType DWORD -Value 1 -Force
