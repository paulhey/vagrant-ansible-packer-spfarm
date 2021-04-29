Import-Module ServerManager
Import-Module ActiveDirectory

$Users = Import-Csv -Delimiter ';' -Path 'c:\tmp\import_create_ad_sample_users.csv'
foreach ($User in $Users) {
  $NewUser = @{
    Title                = $User.Title
    City                 = $User.City
    State                = $User.State
    OfficePhone          = $User.Phone
    Name                 = $User.SamAccountName
    SamAccountName       = $User.SamAccountName
    UserPrincipalName    = ('{0}@{1}' -f $User.SamAccountName, 'sposcar.local')
    DisplayName          = ('{0} {1}' -f $User.FirstName, $User.LastName)
    GivenName            = $User.FirstName
    Surname              = $User.LastName
    AccountPassword      = (ConvertTo-SecureString $User.password -AsPlainText -Force)
    PasswordNeverExpires = $true
    Enabled              = $true
    Path                 = 'CN=Users,DC=sposcar,DC=local'
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


  #Set-ADUser $SAM -Replace @{thumbnailPhoto=([byte[]](Get-Content $UserPhoto -Encoding byte))}
}
