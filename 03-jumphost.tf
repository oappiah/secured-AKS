resource "azurerm_linux_virtual_machine" "jumphost" {
  depends_on = [
    azurerm_virtual_machine.fgtavm
  ]
  name                = "jumphost"
  resource_group_name = azurerm_resource_group.resourcegroup.name
  location            = var.location
  size                = "Standard_F2s_v2"
  admin_username      = var.username
  
  network_interface_ids = [
    azurerm_network_interface.jumphost.id,
  ]

  admin_ssh_key {
    username   =  var.username
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  custom_data = "${filebase64("files/jumphost-init.sh")}"
}

resource "azurerm_network_interface" "jumphost" {
  name                          = "jumphost-nic"
  location                      = azurerm_resource_group.resourcegroup.location
  resource_group_name           = azurerm_resource_group.resourcegroup.name
 
  ip_configuration {
    name                          = "interface1"
    subnet_id                     = azurerm_subnet.subnet4.id
    private_ip_address_allocation = "static"
    private_ip_address = "172.27.42.4"
  }
}

