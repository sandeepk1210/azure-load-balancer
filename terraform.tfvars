resource_group_name = "Regroup_1inAjvNIXMMZZUCtl6lJc"

#Network
vnet_name           = "application-vnet"
default_subnet_name = "default"
address_space       = ["10.0.0.0/16"]
default_subnet_cidr = "10.0.0.0/24"

#VM
vm_count       = 2 # Identity how many VMs to be created
admin_username = "adminuser"
vm_size        = "Standard_B2s"
