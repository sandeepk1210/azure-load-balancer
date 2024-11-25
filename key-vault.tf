# Random password
resource "random_password" "admin_password" {
  length           = 16
  special          = true
  override_special = "!@#$%&*()-_=+[]{}<>:?"
}

# Random string for unique Key Vault name
resource "random_string" "unique" {
  length  = 8
  special = false
  upper   = false
}

# Key Vault
resource "azurerm_key_vault" "kv" {
  name                        = "kv-${lower(random_string.unique.result)}"
  location                    = data.azurerm_resource_group.rg.location
  resource_group_name         = data.azurerm_resource_group.rg.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = true
  enabled_for_disk_encryption = true

  sku_name = "standard"

  # Existing access policy for the current client
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    # This permission type applies to secrets stored in Key Vault. 
    # Secrets typically contain sensitive information like passwords, connection strings, or API keys
    secret_permissions = ["Get", "Set", "Delete", "List", "Recover", "Backup", "Restore"]
    # This permission type applies to keys stored in Key Vault, 
    # which are used for cryptographic operations like encryption and decryption.
    key_permissions = ["Create", "Get", "WrapKey", "UnwrapKey", "GetRotationPolicy", "Delete", "List", "Recover", "Restore", "Update", "Backup"]
  }
}

# Store Admin Password in Key Vault
resource "azurerm_key_vault_secret" "admin_password" {
  name         = "vm-admin-password"
  value        = random_password.admin_password.result
  key_vault_id = azurerm_key_vault.kv.id
}

resource "azurerm_key_vault_key" "disk_encryption_key" {
  name         = "diskEncryptionKey"
  key_vault_id = azurerm_key_vault.kv.id
  key_type     = "RSA"
  key_size     = 2048
  key_opts     = ["decrypt", "encrypt", "verify", "wrapKey", "unwrapKey"]
}

# Grant Disk Encryption Set access to Key Vault
resource "azurerm_key_vault_access_policy" "des_policy" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_disk_encryption_set.disk_encryption_set.identity[0].principal_id

  key_permissions = ["Create", "Get", "WrapKey", "UnwrapKey", "GetRotationPolicy", "Delete", "List", "Recover", "Restore", "Update", "Backup"]
}
