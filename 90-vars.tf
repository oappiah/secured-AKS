variable "location" {
  description = "Azure Region - example: westeurope, eastus2 ..."
  type = string
  default = "northeurope"
}

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
