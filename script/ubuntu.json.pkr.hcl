packer {
  required_plugins {
    virtualbox = {
      source  = "github.com/hashicorp/virtualbox"
      version = "~> 1"
    }
  }
}

variable "accelerator" {
  type    = string
}

variable "cpus" {
  type    = string
}

variable "disk_size" {
  type    = string
}

variable "headless" {
  type    = string
}

variable "host_ip" {
  type    = string
}

variable "http_directory" {
  type    = string
}

variable "iso_checksum" {
  type    = string
}

variable "iso_url" {
  type    = string
}

variable "keep_registered" {
 type     = string
}

variable "memory" {
  type    = string
}

variable "output_directory" {
  type    = string
}

variable "packer_images_output_dir" {
  type    = string
}

variable "skip_export" {
  type    = string
}

variable "ssh_password" {
  type    = string
}

variable "ssh_username" {
  type    = string
}

variable "vm_name" {
  type    = string
}

source "virtualbox-iso" "Forensic" {
  http_directory          = var.http_directory
  boot_wait               = "5s"
  boot_command = ["e<down><down><down><end>",
    " ip=dhcp cloud-config-url=http://${var.host_ip}:{{ .HTTPPort }}/autoinstall.yaml autoinstall",
    "<F10>"
  ]
  cpus                    = var.cpus
  disk_size               = var.disk_size
  format                  = "ova"
  gfx_controller          = "vmsvga"
  gfx_vram_size           = 16
  guest_os_type           = "Ubuntu_64"
  hard_drive_interface    = "sata"
  headless                = var.headless
  iso_checksum            = var.iso_checksum
  iso_url                 = var.iso_url
  keep_registered         = var.keep_registered
  memory                  = var.memory
  output_directory        = var.output_directory
  shutdown_command        = "echo 'Extinction packer' | sudo shutdown -P now"
  skip_export             = var.skip_export
  ssh_timeout             = "24h"
  ssh_username            = var.ssh_username
  ssh_password            = var.ssh_password
  virtualbox_version_file = ".vbox_version"
  vm_name                 = var.vm_name
}

build {
  sources = ["source.virtualbox-iso.Forensic"]
#  provisioner "file" {
#    destination = "/tmp/forensic.sh"
#	direction = "upload"
#	source = "./forensic.sh"
#  }

#  provisioner "shell" {
#    inline = ["sudo bash -x /tmp/forensic.sh"]
#  }
  
    provisioner "shell" {
    script           = "./forensic.sh"
    valid_exit_codes = [0, 2]
  }

}
