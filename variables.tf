variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

# Network
variable "vnet_name" {
  type        = string
  description = "Name of the virtual network"
}

variable "default_subnet_name" {
  type        = string
  description = "Name of the default subnet"
}

variable "address_space" {
  type        = list(string)
  description = "Address space for the virtual network"
}

variable "default_subnet_cidr" {
  type        = string
  description = "CIDR block for the default subnet"
}

# VM
variable "vm_count" {
  type        = number
  description = "The number of virtual machines to create"
}

variable "vm_size" {
  type        = string
  description = "The size of the virtual machines"
}

variable "admin_username" {
  type        = string
  description = "Admin username for the virtual machines"
}
