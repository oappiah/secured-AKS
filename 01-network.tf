resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}-VNET"
  address_space       = ["172.27.40.0/22"]
  location            = azurerm_resource_group.resourcegroup.location
  resource_group_name = azurerm_resource_group.resourcegroup.name
}

resource "azurerm_subnet" "subnet1" {
  name                 = "${var.prefix}-ExternalSubnet"
  resource_group_name  = azurerm_resource_group.resourcegroup.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["172.27.40.0/26"]
}

resource "azurerm_subnet" "subnet2" {
  name                 = "${var.prefix}-InternalSubnet"
  resource_group_name  = azurerm_resource_group.resourcegroup.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["172.27.40.64/26"]
}

resource "azurerm_subnet" "subnet3" {
  name                 = "${var.prefix}-ProtectedSubnet"
  enforce_private_link_endpoint_network_policies = true
  resource_group_name  = azurerm_resource_group.resourcegroup.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["172.27.41.0/24"]
}

resource "azurerm_subnet" "subnet4" {
  name                 = "${var.prefix}-JUMPNET"
  resource_group_name  = azurerm_resource_group.resourcegroup.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["172.27.42.0/24"]
}

resource "azurerm_route_table" "protectedroute" {
  name                = "${var.prefix}-RT-PROTECTED"
  location            = var.location
  resource_group_name = azurerm_resource_group.resourcegroup.name

  route {
    address_prefix = "0.0.0.0/0"
    name = "Default"
    next_hop_in_ip_address = "172.27.40.68"
    next_hop_type = "VirtualAppliance"
  }
  
  route {
    address_prefix = "172.27.40.0/22"
    name = "VirtualNetwork"
    next_hop_in_ip_address = "172.27.40.68"
    next_hop_type = "VirtualAppliance"
  }
  route {
    address_prefix = "172.27.41.0/24"
    name = "Subnet"
    next_hop_type = "vnetlocal"
  }
}
resource "azurerm_route_table" "jumproute" {
  name                = "${var.prefix}-RT-JUMP"
  location            = var.location
  resource_group_name = azurerm_resource_group.resourcegroup.name
  
  route {
    address_prefix = "0.0.0.0/0"
    name = "Default"
    next_hop_in_ip_address = "172.27.40.68"
    next_hop_type = "VirtualAppliance"
  }
  route {
    address_prefix = "172.27.40.0/22"
    name = "VirtualNetwork"
    next_hop_in_ip_address = "172.27.40.68"
    next_hop_type = "VirtualAppliance"
  }
  route {
    address_prefix = "172.27.42.0/24"
    name = "Subnet"
    next_hop_type = "vnetlocal"
  }
}


resource "azurerm_subnet_route_table_association" "subnet3rt" {
  subnet_id      = azurerm_subnet.subnet3.id
  route_table_id = azurerm_route_table.protectedroute.id
}

resource "azurerm_subnet_route_table_association" "subnet4rt" {
  subnet_id      = azurerm_subnet.subnet4.id
  route_table_id = azurerm_route_table.jumproute.id
}


resource "azurerm_network_security_group" "fgtnsg" {
  name                = "${var.prefix}-FGT-NSG"
  location            = var.location
  resource_group_name = azurerm_resource_group.resourcegroup.name
}

resource "azurerm_network_interface_security_group_association" "fgtint" {
  network_interface_id      = azurerm_network_interface.fgt-INT.id
  network_security_group_id = azurerm_network_security_group.fgtnsg.id
}

resource "azurerm_network_interface_security_group_association" "fgtext" {
  network_interface_id      = azurerm_network_interface.fgt-EXT.id
  network_security_group_id = azurerm_network_security_group.fgtnsg.id
}

resource "azurerm_network_security_rule" "fgtnsgallowallout" {
  name                        = "AllowAllOutbound"
  resource_group_name         = azurerm_resource_group.resourcegroup.name
  network_security_group_name = azurerm_network_security_group.fgtnsg.name
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}

resource "azurerm_network_security_rule" "fgtnsgallowallin" {
  name                        = "AllowAllInbound"
  resource_group_name         = azurerm_resource_group.resourcegroup.name
  network_security_group_name = azurerm_network_security_group.fgtnsg.name
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}

resource "azurerm_public_ip" "fgtpip" {
  name                = "${var.prefix}-FGT-PIP"
  location            = var.location
  resource_group_name = azurerm_resource_group.resourcegroup.name
  allocation_method   = "Static"
  sku                 = "Standard"
}   