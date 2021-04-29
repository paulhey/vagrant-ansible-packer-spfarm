param(
  [string]
  $Command = 'Enable-PSRemoting -Force -SkipNetworkProfileCheck',
  [string]
  $WorkingDirectory
)

$StartAction = @{
  Execute  = 'powershell'
  Argument = "-NoLogo -NonInteractive -NoProfile -Command `"& {$Command}`""
}

if ($WorkingDirectory){
  $StartAction['WorkingDirectory'] = $WorkingDirectory
}

$StartAtStartup = @{
  RandomDelay = (New-TimeSpan -Seconds 30)
  AtStartup   = $true
}

$StartAtLogon = @{
  AtLogOn     = $true
  User        = 'vagrant'
  RandomDelay = (New-TimeSpan -Seconds 30)
}

$StartRegistration = @{
  Description = 'Enable PS Remoting (WinRM) for Vagrant'
  Action      = New-ScheduledTaskAction @StartAction
  Trigger     = @(
    (New-ScheduledTaskTrigger @StartAtStartup)
    (New-ScheduledTaskTrigger @StartAtLogon)
  )
  Settings    = New-ScheduledTaskSettingsSet
  TaskName    = 'Enable PS Remoting (WinRM)'
  TaskPath    = '\'
  User        = 'vagrant'
  Password    = 'vagrant'
  RunLevel    = 'Highest'
}

Register-ScheduledTask @StartRegistration