output "HTTPS_FGT" {
    value = "https://${azurerm_public_ip.fgtpip.ip_address}"

}
output "FGT_SSH_ACCESS" {
    value = "ssh ${var.username}@${azurerm_public_ip.fgtpip.ip_address}"
}

output "COPY_FILE_TO_JUMPHOST" {
    value = "scp -P8022 -r files/jumphost_dir/ ${var.username}@${azurerm_public_ip.fgtpip.ip_address}: " 
}
output "JUMPBOX_SSH_ACCESS" {
    value = "ssh ${var.username}@${azurerm_public_ip.fgtpip.ip_address} -p8022"
}
