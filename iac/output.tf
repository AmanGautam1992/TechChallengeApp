output "pgsql_server" {
  value = azurerm_postgresql_server.techchallengepgserver.name
}

output "pgsql_db" {
  value = azurerm_postgresql_database.techchallengepgdb.name
}

output "aks_id" {
  value = azurerm_kubernetes_cluster.aks.id
}

output "aks_fqdn" {
  value = azurerm_kubernetes_cluster.aks.fqdn
}

output "aks_node_rg" {
  value = azurerm_kubernetes_cluster.aks.node_resource_group
}

output "acr_id" {
  value = azurerm_container_registry.techchallengeacr.id
}

output "acr_login_server" {
  value = azurerm_container_registry.techchallengeacr.login_server
}