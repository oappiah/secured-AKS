resource "azurerm_virtual_machine" "fgtavm" {
  name                         = "${var.prefix}-VM-FGT"
  location                     = azurerm_resource_group.resourcegroup.location
  resource_group_name          = azurerm_resource_group.resourcegroup.name
  network_interface_ids        = [azurerm_network_interface.fgt-EXT.id,azurerm_network_interface.fgt-INT.id]
  vm_size                         = "Standard_F2"
  
  
  identity {
    type = "SystemAssigned"
  }
  
  primary_network_interface_id = azurerm_network_interface.fgt-EXT.id
  
  plan {
    publisher = "fortinet"
    product   = "fortinet_fortigate-vm_v5"
    name      = "fortinet_fg-vm_payg_20190624"
  }
  
   storage_image_reference {
    publisher = "fortinet"
    offer     = "fortinet_fortigate-vm_v5"
    sku       = "fortinet_fg-vm_payg_20190624"
    version   = "latest"
  }

   storage_os_disk {
    name              = "FGT-OSDISK"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_data_disk {
    name              = "FGT-VM-DATADISK"
    managed_disk_type = "Standard_LRS"
    create_option     = "Empty"
    lun               = 0
    disk_size_gb      = "10"
  }

  os_profile {
    computer_name  = "FGT"
    admin_username = var.username
    admin_password = var.password
    custom_data    = data.template_file.fgt_custom_data.rendered
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

resource "azurerm_role_assignment" "sdn-connector" {
  scope = azurerm_resource_group.resourcegroup.id
  role_definition_name = "Reader"
  principal_id = azurerm_virtual_machine.fgtavm.identity[0].principal_id
}
resource "azurerm_role_assignment" "sdn-aks-permisson" {
 scope = azurerm_resource_group.resourcegroup.id
  role_definition_name = "Azure Kubernetes Service Cluster Admin Role"
  principal_id = azurerm_virtual_machine.fgtavm.identity[0].principal_id
}

data "template_file" "fgt_custom_data" {
  template = file("${path.module}/customdata.tpl")

  vars = {
    fgt_username = var.username
    auto_password = random_password.autouser_password.result
  }
}
resource "azurerm_network_interface" "fgt-EXT" {
  name                          = "${var.prefix}-VM-FGT-EXT"
  location                      = azurerm_resource_group.resourcegroup.location
  resource_group_name           = azurerm_resource_group.resourcegroup.name
  enable_ip_forwarding          = true

  ip_configuration {
    name                          = "interface1"
    subnet_id                     = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "static"
    private_ip_address = "172.27.40.4"
    public_ip_address_id = azurerm_public_ip.fgtpip.id
  }
}

resource "azurerm_network_interface" "fgt-INT" {
  name                          = "${var.prefix}-VM-FGT-INT"
  location                      = azurerm_resource_group.resourcegroup.location
  resource_group_name           = azurerm_resource_group.resourcegroup.name
  enable_ip_forwarding          = true

  ip_configuration {
    name                          = "interface2"
    subnet_id                     = azurerm_subnet.subnet2.id
    private_ip_address_allocation = "static"
    private_ip_address = "172.27.40.68"
  }
}

resource "random_password" "autouser_password" {
  length           = 30
  special          = false
  override_special = "_%@"
}
