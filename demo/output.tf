# In the module where you define the load balancer backend pool
output "backend_pool_id" {
  value = azurerm_lb_backend_address_pool.backend_pool.id
}
