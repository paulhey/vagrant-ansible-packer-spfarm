[CmdletBinding()]
param (
  [Parameter(Mandatory)]
  [string]
  $BoxFilePath,
  # Version
  [Parameter()]
  [string]
  $Version = '0.2.1'
)

$BoxFile = if (Test-Path -Path $BoxFilePath -PathType Leaf){
  Get-ChildItem -Path $BoxFilePath
} else {
  throw "Path not Found: [$BoxFilePath]"
}

$BoxFileHash = Get-FileHash -Path $BoxFilePath -Algorithm SHA256

<# JSON format
{
  'name': 'sp2016_farm_base_windows_2016_virtualbox',
  'description': 'This box contains Windows Server 2016 Standard',
  'versions': [
  {
    'version': '0.1.0',
    'providers': [
    {
      'name': 'virtualbox',
      'url': '/home/paulhey/Projects/vagrant-ansible-packer-spfarm/packer/sp2016_farm_base_windows_2016_virtualbox.box',
      'checksum_type': 'sha256',
      'checksum': 'F30FB193705E2630A90FAD7097602BBBE9CDD9A2B8F6F5698B59CEEE486E0A2D'
    }
    ]
  }
  ]
}
#>

$BoxJson = [PSCustomObject]@{
  name        = $BoxFile.BaseName
  description = 'This box contains Windows Server 2016 Standard'
  versions    = @(
    [ordered]@{
      version   = $Version
      providers = @(
        [ordered]@{
          name          = 'virtualbox'
          url           = $BoxFile.FullName
          checksum_type = $BoxFileHash.Algorithm.ToLower()
          checksum      = $BoxFileHash.Hash.ToLower()
        })
    })
} | ConvertTo-Json -Depth 15

$BoxJsonFile = @{
  FilePath    = ( '{0}/{1}.json' -f $BoxFile.Directory, $BoxFile.BaseName )
  InputObject = $BoxJson
  Encoding    = 'utf8'
  Force       = $true
}

Out-File @BoxJsonFile
