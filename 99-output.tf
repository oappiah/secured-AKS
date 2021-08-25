output "HTTPS_FGT" {
    value = "https://${azurerm_public_ip.fgtpip.ip_address}"

}
output "FGT_SSH_ACCESS" {
    value = "ssh ${var.username}@${azurerm_public_ip.fgtpip.ip_address}"
}
output "JUMPBOX_SSH_ACCESS" {
    value = "ssh ${var.username}@${azurerm_public_ip.fgtpip.ip_address} -p8022"
}

output "Next_step" {
    value = "Text on how to run ansible ... ansible-playbook -i files/inventory files/post.yaml"
}
