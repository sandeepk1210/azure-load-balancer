# Windows Virtual Machines
resource "azurerm_windows_virtual_machine" "vm" {
  count               = var.vm_count
  name                = "vms-${count.index + 1}"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = azurerm_key_vault_secret.admin_password.value
  network_interface_ids = [
    azurerm_network_interface.nic[count.index].id
  ]

  os_disk {
    caching                = "ReadWrite"
    storage_account_type   = "Standard_LRS"
    disk_encryption_set_id = azurerm_disk_encryption_set.disk_encryption_set.id
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  # Explicit dependency on the Key Vault
  depends_on = [
    azurerm_key_vault.kv
  ]
}

# Disk Encryption Set
resource "azurerm_disk_encryption_set" "disk_encryption_set" {
  name                = "disk-encryption-set-${random_string.unique.result}"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location

  key_vault_key_id = azurerm_key_vault_key.disk_encryption_key.id

  identity {
    type = "SystemAssigned"
  }

  # Explicit dependency on the Key Vault
  depends_on = [
    azurerm_key_vault.kv
  ]
}

# Custom Script Extension to install IIS and create Default.html
resource "azurerm_virtual_machine_extension" "iis_extension" {
  count                = var.vm_count
  name                 = "iis-extension-${count.index + 1}"
  virtual_machine_id   = azurerm_windows_virtual_machine.vm[count.index].id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  protected_settings = jsonencode({
    commandToExecute = "powershell -command \"Install-WindowsFeature -name Web-Server; New-Item -Path 'C:\\inetpub\\wwwroot\\Default.html' -ItemType File -Force; Add-Content -Path 'C:\\inetpub\\wwwroot\\Default.html' -Value '<html><body><h1>Hello from VM ${(count.index + 1)}</h1></body></html>'\""
  })
}

# Network Interface
resource "azurerm_network_interface" "nic" {
  count               = var.vm_count
  name                = "vm-nic-${count.index + 1}"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.default_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Network Security Group
resource "azurerm_network_security_group" "nsg" {
  name                = "vm-nsg"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  security_rule {
    name                       = "allow-http"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-rdp"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}


# Associate the NSG with each NIC
resource "azurerm_network_interface_security_group_association" "nic_nsg_assoc" {
  count                     = var.vm_count
  network_interface_id      = azurerm_network_interface.nic[count.index].id
  network_security_group_id = azurerm_network_security_group.nsg.id
}
