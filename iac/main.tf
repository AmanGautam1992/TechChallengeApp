resource "azurerm_resource_group" "rg" {
  name     = var.namerg
  location = var.locationrg
}

resource "azurerm_postgresql_server" "techchallengepgserver" {
  name                         = var.pgsqlservername
  location                     = azurerm_resource_group.rg.location
  resource_group_name          = azurerm_resource_group.rg.name
  sku_name                     = "B_Gen5_2"
  storage_mb                   = 5120
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  auto_grow_enabled            = true

  administrator_login          = var.psql_admin_username
  administrator_login_password = var.psql_admin_password
  version                      = "9.5"
  ssl_enforcement_enabled      = true
}
resource "azurerm_postgresql_database" "techchallengepgdb" {
  name                = var.pgsqlservername
  resource_group_name = var.namerg
  server_name         = azurerm_postgresql_server.techchallengepgserver.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}

resource "azurerm_postgresql_firewall_rule" "techchallengepgdbrule" {
  name                = var.pgsqldbfwrule
  resource_group_name = var.namerg
  server_name         = azurerm_postgresql_server.techchallengepgserver.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0" // add ip address range required to be whitelisted 
}

resource "azurerm_container_registry" "techchallengeacr" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = false
}

resource "azurerm_role_assignment" "role_acrpull" {
  scope                            = azurerm_container_registry.techchallengeacr.id
  role_definition_name             = "AcrPull"
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity.0.object_id
  skip_service_principal_aad_check = true
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  kubernetes_version  = var.kubernetes_version
  location            = var.locationrg
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = var.cluster_name

  default_node_pool {
    name                = "system"
    node_count          = var.system_node_count
    vm_size             = "Standard_DS2_v2"
    type                = "VirtualMachineScaleSets"
    availability_zones  = [1, 2, 3]
    enable_auto_scaling = false

  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    load_balancer_sku = "Standard"
    network_plugin    = "kubenet" # CNI
  }
}

