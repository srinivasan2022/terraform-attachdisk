location = "East US"

resource_group_name = "rg-network"

virtual_network = {
  name          = "vnet-main"
  address_space = ["10.0.0.0/16"]
}

subnets = {
  "subnet-main" = {
    address_prefix = "10.0.1.0/24"
  }
}

nsgs = {
  "nsg_vmss1" = {
    name = "nsg-vmss1"
  },
  "nsg_vmss2" = {
    name = "nsg-vmss2"
  }
}






vm_configuration = {
  "vm1" = {
    admin_username = "adminuser"
    admin_password = "Password1234!"
    instance_count = 2
  },
  "vm2" = {
    admin_username = "adminuser"
    admin_password = "Password1234!"
    instance_count = 2
  }
}
load_balancer = {
  name = "lb-main"
  sku  = "Standard"
}

public_ip = {
  name              = "lb-public-ip"
  allocation_method = "Static"
  sku               = "Standard"
}

backend_pool_name = "lb-backend-pool"

nsg_rules = {
  "allow_vm1_to_vmss1" = {
    name                    = "allow-from-vm1-to-vmss1"
    priority                = 100
    direction               = "Inbound"
    access                  = "Allow"
    protocol                = "Tcp"
    source_port_range       = "*"
    destination_port_range  = "*"
    source_address_prefix   = "10.0.1.4" # IP of VM1
    destination_address_prefix = "*"
    network_security_group   = "nsg_vmss1"
  },
  "deny_vm2_to_vmss1" = {
    name                    = "deny-from-vm2-to-vmss1"
    priority                = 200
    direction               = "Inbound"
    access                  = "Deny"
    protocol                = "Tcp"
    source_port_range       = "*"
    destination_port_range  = "*"
    source_address_prefix   = "10.0.1.5" # IP of VM2
    destination_address_prefix = "*"
    network_security_group   = "nsg_vmss1"
  },
  "allow_vm2_to_vmss2" = {
    name                    = "allow-from-vm2-to-vmss2"
    priority                = 100
    direction               = "Inbound"
    access                  = "Allow"
    protocol                = "Tcp"
    source_port_range       = "*"
    destination_port_range  = "*"
    source_address_prefix   = "10.0.1.5" # IP of VM2
    destination_address_prefix = "*"
    network_security_group   = "nsg_vmss2"
  },
  "deny_vm1_to_vmss2" = {
    name                    = "deny-from-vm1-to-vmss2"
    priority                = 200
    direction               = "Inbound"
    access                  = "Deny"
    protocol                = "Tcp"
    source_port_range       = "*"
    destination_port_range  = "*"
    source_address_prefix   = "10.0.1.4" # IP of VM1
    destination_address_prefix = "*"
    network_security_group   = "nsg_vmss2"
  }
}

vmss_config = {
  vmss1 = {
    sku                        = "Standard_DS1_v2"
    instances                  = 2
    admin_username             = "adminuser"
    admin_password             = "Password1234!"
    network_security_group_id  = "nsg_vmss1_id"     
    subnet_id                  = "subnet_id"       
    load_balancer_backend_pool = "backend_pool_id"  
  },
  vmss2 = {
    sku                        = "Standard_DS1_v2"
    instances                  = 2
    admin_username             = "adminuser"
    admin_password             = "Password1234!"
    network_security_group_id  = "nsg_vmss2_id"     
    subnet_id                  = "subnet_id"        
    load_balancer_backend_pool = "backend_pool_id"  
  }
}


