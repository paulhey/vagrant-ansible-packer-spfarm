Try {
  # Set power config
  $HighPerf = Get-CimInstance -Namespace root/CIMV2/power -ClassName Win32_PowerPlan | Where-Object ElementName -EQ 'High performance'
  Invoke-CimMethod -InputObject $HighPerf -MethodName Activate
} Catch {
  Write-Warning -Message 'Unable to set power plan to high performance'
}
