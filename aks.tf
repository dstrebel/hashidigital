resource "azurerm_kubernetes_cluster" "privateaks" {
  name                    = "private-aks"
  location                = var.location
  kubernetes_version      = "1.16.9"
  resource_group_name     = var.kube_resource_group_name
  dns_prefix              = "private-aks"
  private_cluster_enabled = false

  default_node_pool {
    name           = "default"
    node_count     = var.nodepool_nodes_count
    vm_size        = var.nodepool_vm_size
    vnet_subnet_id = module.kube_network.subnet_ids["aks-subnet"]
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    docker_bridge_cidr = var.network_docker_bridge_cidr
    dns_service_ip     = var.network_dns_service_ip
    network_plugin     = "azure"
    outbound_type      = "userDefinedRouting"
    service_cidr       = var.network_service_cidr
  }

  depends_on = [module.routtable]
}

# https://github.com/Azure/AKS/issues/1557
resource "azurerm_role_assignment" "vmcontributor" {
  role_definition_name = "Virtual Machine Contributor"
  scope                = azurerm_resource_group.vnet.id
  principal_id         = azurerm_kubernetes_cluster.privateaks.identity[0].principal_id
}