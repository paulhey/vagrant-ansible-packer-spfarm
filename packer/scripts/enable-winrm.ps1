# Disable UAC
Set-ItemProperty -Path 'registry::HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System' -Name 'EnableLUA' -Value 0

# Enable WinRM in Firewall for any remote address
Enable-NetFirewallRule -DisplayGroup 'Windows Remote Management'
Get-NetFirewallRule -DisplayGroup 'Windows Remote Management' |
  Get-NetFirewallAddressFilter |
  Set-NetFirewallAddressFilter -RemoteAddress Any

# Enable-PSRemoting -Force -SkipNetworkProfileCheck
# Set-NetFirewallRule -Name 'WINRM-HTTP-In-TCP' -RemoteAddress Any
# Set-ExecutionPolicy RemoteSigned
# winrm set winrm/config/service/auth @{Basic=\"\"true\"\"}
# winrm set winrm/config/service @{AllowUnencrypted=\"\"true\"\"}
# winrm quickconfig -q
# sc config WinRM start= auto
# winrm get winrm/config/service\"

winrm quickconfig -q
winrm quickconfig -transport:http
winrm set winrm/config '@{MaxTimeoutms="1800000"}'
winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="800"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/service/auth '@{CredSSP="true"}'
winrm set winrm/config/client/auth '@{Basic="true"}'
winrm set winrm/config/client/auth '@{CredSSP="true"}'
winrm set winrm/config/listener?Address=*+Transport=HTTP '@{Port="5985"}'
netsh advfirewall firewall set rule group="Windows Remote Administration" new enable=yes
netsh advfirewall firewall set rule name="Windows Remote Management (HTTP-In)" new enable=yes action=allow
Set-Service winrm -startuptype 'auto'
