# Public IP for Load Balancer
resource "azurerm_public_ip" "app_lb_public_ip" {
  name                = "app-lb-public-ip"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# resource "azurerm_public_ip" "app_lb_public_ip" {
#   name                = "app-lb-public-ip"
#   location            = data.azurerm_resource_group.rg.location
#   resource_group_name = data.azurerm_resource_group.rg.name
#   allocation_method   = "Dynamic"
#   sku                 = "Standard"
# }


# resource "azurerm_public_ip" "app_lb_public_ip" {
#   name                = "app-lb-public-ip"
#   location            = data.azurerm_resource_group.rg.location
#   resource_group_name = data.azurerm_resource_group.rg.name
#   allocation_method   = "Static"
#   sku                 = "Basic"
# }

# resource "azurerm_public_ip" "app_lb_public_ip" {
#   name                = "app-lb-public-ip"
#   location            = data.azurerm_resource_group.rg.location
#   resource_group_name = data.azurerm_resource_group.rg.name
#   allocation_method   = "Dynamic"
#   sku                 = "Basic"
# }

# Load Balancer
resource "azurerm_lb" "app_lb" {
  name                = "app-lb"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  sku                 = "Standard" # Options Standard & Gateway

  # A frontend IP configuration is an IP address used for inbound and/or outbound communication
  # as defined within load balancing, inbound NAT, and outbound rules.
  frontend_ip_configuration {
    name                 = "appFrontEnd"
    public_ip_address_id = azurerm_public_ip.app_lb_public_ip.id
  }
}

# Load Balancer Backend Address Pool
resource "azurerm_lb_backend_address_pool" "app_backend_pool" {
  name            = "appBackendPool"
  loadbalancer_id = azurerm_lb.app_lb.id
}

# Associate NIC with Load Balancer Backend Pool
resource "azurerm_network_interface_backend_address_pool_association" "nic_lb_association" {
  count                   = var.vm_count
  ip_configuration_name   = "internal"
  network_interface_id    = azurerm_network_interface.nic[count.index].id
  backend_address_pool_id = azurerm_lb_backend_address_pool.app_backend_pool.id
}

# Load Balancer Health Probe
resource "azurerm_lb_probe" "app_health_probe" {
  name                = "appHealthProbe"
  loadbalancer_id     = azurerm_lb.app_lb.id
  protocol            = "Tcp"
  port                = 80
  interval_in_seconds = 5
  number_of_probes    = 2
}

# Load Balancer Rule
resource "azurerm_lb_rule" "app_lb_rule" {
  name                           = "appLoadBalancingRule"
  loadbalancer_id                = azurerm_lb.app_lb.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "appFrontEnd"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.app_backend_pool.id]
  probe_id                       = azurerm_lb_probe.app_health_probe.id
}
