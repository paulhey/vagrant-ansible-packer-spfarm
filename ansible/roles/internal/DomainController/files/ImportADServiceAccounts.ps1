Import-Module ServerManager
Import-Module ActiveDirectory

$Users = Import-Csv -Delimiter ';' -Path 'c:\tmp\import_create_ad_users.csv'
ForEach ($User in $Users) {
  $NewUser = @{
    Name                 = $User.Name
    SamAccountName       = $User.Name
    UserPrincipalName    = ('{0}@{1}' -f $User.Name, 'sposcar.local')
    DisplayName          = ('{0} {1}' -f $User.FirstName, 'Service')
    GivenName            = $User.FirstName
    Surname              = 'Service'
    AccountPassword      = (ConvertTo-SecureString $User.password -AsPlainText -Force)
    PasswordNeverExpires = $true
    Enabled              = $true
    Path                 = 'CN=Managed Service Accounts,DC=sposcar,DC=local'
  }
  # Check to see if the user already exists:
  $Exists = try {
    Get-AdUser $NewUser['SamAccountName']
  } catch {
    $false
  }
  if ($Exists){
    Write-Host "User $($Exists.SamAccountName) already exists"
    continue
  } else {
    New-ADUser @NewUser
  }

  #New-ADServiceAccount -Name $Detailedname -SamAccountName $SAM -UserPrincipalName $SAM -DisplayName $Detailedname -GivenName $user.firstname -Surname $user.name -AccountPassword (ConvertTo-SecureString $Password -AsPlainText -Force) -Enabled $true -Path $OU
  #New-ADServiceAccount -Name $Detailedname -Path $ou -AccountPassword (ConvertTo-SecureString $Password -AsPlainText -Force) -Enabled $true
}
