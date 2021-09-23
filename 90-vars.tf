variable "location" {
  description = "Azure Region - example: westeurope, eastus2 ..."
  type = string
  default = "northeurope"
}

/// License part begin
variable "fgtsku" {
  default = "fortinet_fg-vm_payg_20190624"
  description = "PAYG (fortinet_fg-vm_payg_20190624) or BYOL (fortinet_fg-vm)"
}
variable "fgt_license_file" {
  default = ""
  description = "Keep empty if using PAYG"
}
/// License part end
variable "prefix" {
  description = "prefix to resources created"  
  type = string
  default = "demo999"
}

variable "username" {
  description = "username for all resources , admin is not allowed!"
  type = string
}

variable "password" {
    description = "Password for all resources, minimum 14 char, include numbers" 
    type = string
}
