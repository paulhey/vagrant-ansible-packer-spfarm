
variable "Autounattend_virtualbox" {
  type    = string
  default = "answer_files/2016/Autounattend.xml"
}

variable "artifact_name" {
  type    = string
  default = "Windows-2016"
}

variable "boot_wait" {
  type    = string
  default = "5m"
}

variable "communicator" {
  type    = string
  default = "winrm"
}

variable "cpu_cores" {
  type    = string
  default = "2"
}

variable "disk_size" {
  type    = string
  default = "51200"
}

variable "guest_os_type_parallels" {
  type    = string
  default = "win-2016"
}

variable "guest_os_type_virtualbox" {
  type    = string
  default = "Windows2016_64"
}

variable "guest_os_type_vmware" {
  type    = string
  default = "windows9srv-64"
}

variable "iso_checksum" {
  type    = string
  default = "3bb1c60417e9aeb3f4ce0eb02189c0c84a1c6691"
}

variable "iso_checksum_type" {
  type    = string
  default = "sha1"
}

variable "iso_url" {
  type    = string
  default = "http://care.dlservice.microsoft.com/dl/download/1/6/F/16FA20E6-4662-482A-920B-1A45CF5AAE3C/14393.0.160715-1616.RS1_RELEASE_SERVER_EVAL_X64FRE_EN-US.ISO"
}

variable "memory_size" {
  type    = string
  default = "4096"
}

variable "shutdown_command" {
  type    = string
  default = "A:/shutdown-packer.bat"
}

variable "shutdown_timeout" {
  type    = string
  default = "30m"
}

variable "winrm_insecure" {
  type    = string
  default = "true"
}

variable "winrm_password" {
  type    = string
  default = "vagrant"
}

variable "winrm_timeout" {
  type    = string
  default = "6h"
}

variable "winrm_use_ssl" {
  type    = string
  default = "false"
}

variable "winrm_username" {
  type    = string
  default = "vagrant"
}

source "virtualbox-iso" "windows_server_2016" {
  boot_wait    = "${var.boot_wait}"
  communicator = "${var.communicator}"
  disk_size    = "${var.disk_size}"
  floppy_files = [
    "${var.Autounattend_virtualbox}",
    "floppy/WindowsPowershell.lnk",
    "floppy/PinTo10.exe",
    "scripts/disable-screensaver.ps1",
    "scripts/disable-winrm.ps1",
    "scripts/enable-winrm.ps1",
    "unattend.xml",
    "scripts/shutdown-Packer.bat",
    "scripts/oracle-cert.cer"
  ]
  guest_additions_mode = "attach"
  guest_os_type        = "${var.guest_os_type_virtualbox}"
  iso_checksum         = "${var.iso_checksum_type}:${var.iso_checksum}"
  iso_url              = "${var.iso_url}"
  output_directory     = "packer_tmp-${var.artifact_name}-virtualbox"
  shutdown_command     = "${var.shutdown_command}"
  shutdown_timeout     = "${var.shutdown_timeout}"
  vboxmanage = [
    ["modifyvm", "{{ .Name }}", "--cpus", "${var.cpu_cores}"],
    ["modifyvm", "{{ .Name }}", "--memory", "${var.memory_size}"],
    ["modifyvm", "{{ .Name }}", "--vram", "128"],
    # ["modifyvm", "{{ .Name }}", "--cpuexecutioncap", "95"],
    ["modifyvm", "{{ .Name }}", "--clipboard", "bidirectional"]
  ]
  vm_name        = "tmp-${var.artifact_name}"
  winrm_insecure = "${var.winrm_insecure}"
  winrm_password = "${var.winrm_password}"
  winrm_timeout  = "${var.winrm_timeout}"
  winrm_use_ssl  = "${var.winrm_use_ssl}"
  winrm_username = "${var.winrm_username}"
  headless       = true
}

build {
  sources = ["source.virtualbox-iso.windows_server_2016"]

  provisioner "windows-shell" {
    execute_command = "{{ .Vars }} cmd /c \"{{ .Path }}\""
    scripts         = ["scripts/vm-guest-tools.bat"]
  }

  provisioner "ansible" {
    playbook_file = "./windows_2016.yml"
    user          = "vagrant"
    use_proxy     = false
    extra_arguments = [
      "-e", "ansible_winrm_server_cert_validation=ignore",
      "-e", "ansible_winrm_scheme=http",
      "-e", "ansible_shell_type=powershell",
      "-e", "ansible_shell_executable=None",
      "-v"
    ]
  }

  provisioner "windows-restart" {
  }

  provisioner "powershell" {
    script = "scripts/reset-winrm.ps1"
  }

  post-processor "vagrant" {
    keep_input_artifact  = false
    output               = "sp2016_farm_base_windows_2016_{{ .Provider }}.box"
    vagrantfile_template = "vagrantfile-windows_2016.template"
  }
}
