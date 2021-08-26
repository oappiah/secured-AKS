resource "azurerm_container_registry" "acr" {
  name                = "${var.prefix}acr"
  location                      = azurerm_resource_group.resourcegroup.location
  resource_group_name           = azurerm_resource_group.resourcegroup.name
  sku                 = "Basic"
}

resource "azurerm_kubernetes_cluster" "k8s" {
  depends_on = [
    azurerm_subnet_route_table_association.subnet3rt
  ]
  name                = "aks01"
  location            = azurerm_resource_group.resourcegroup.location
  resource_group_name = azurerm_resource_group.resourcegroup.name
  dns_prefix          = "aks01"
  private_cluster_enabled = true
  
  default_node_pool {
    name       = "default"
    node_count = 3
    vm_size    = "Standard_B2ms"
    enable_auto_scaling = true
    min_count = 3
    max_count = 5
    vnet_subnet_id = azurerm_subnet.subnet3.id
  }

  network_profile {
    network_plugin = "azure"
    docker_bridge_cidr = "172.17.0.1/16"
    dns_service_ip = "10.8.0.53"
    service_cidr = "10.8.0.0/16"
    load_balancer_sku = "Standard"
    outbound_type = "userDefinedRouting"
     
  }
  windows_profile {
    admin_password = var.password
    admin_username = var.username
  }

  identity {
    type = "SystemAssigned"
  }
}
resource "null_resource" "kubeconfig_jumphost" {
  depends_on = [
    azurerm_linux_virtual_machine.jumphost
  ]
  connection {
    type     = "ssh"
    host     = azurerm_public_ip.fgtpip.ip_address
    user     = "${var.username}"
    private_key = tls_private_key.demokey.private_key_pem
    port     = 8022
  }

  provisioner "file" {
    content      = azurerm_kubernetes_cluster.k8s.kube_config_raw
    destination = "/home/${var.username}/.kube/config"
  }
}

# https://github.com/Azure/AKS/issues/357#issuecomment-388297027
# Needed for the LB in custom vnet or else external SVC will be stuck in pending
resource "azurerm_role_assignment" "k8snetworkaccess" {
  scope              = azurerm_subnet.subnet3.id
  role_definition_name = "Network Contributor"
  principal_id       = azurerm_kubernetes_cluster.k8s.identity[0].principal_id
}