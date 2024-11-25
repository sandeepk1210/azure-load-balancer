#Outputs the static public IP address assigned to the Load Balancer
output "public_ip_address" {
  description = "Public IP address of the Load Balancer"
  value       = azurerm_public_ip.app_lb_public_ip.ip_address
}

#Exports the ID of the Load Balancer for use in downstream resources or debugging.
output "load_balancer_id" {
  description = "The ID of the Load Balancer"
  value       = azurerm_lb.app_lb.id
}

# Output the Backend Pool ID
output "backend_pool_id" {
  description = "The ID of the Load Balancer Backend Pool."
  value       = azurerm_lb_backend_address_pool.app_backend_pool.id
}

# Output the names of the Virtual Machines
output "vm_names" {
  description = "The names of the created Virtual Machines."
  value       = azurerm_windows_virtual_machine.vm[*].name
}

# Output the Private IPs of the Virtual Machines
output "vm_private_ips" {
  description = "The private IP addresses of the Virtual Machines."
  value       = azurerm_network_interface.nic[*].ip_configuration[0].private_ip_address
}
