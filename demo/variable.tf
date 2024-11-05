variable "location" {
  description = "The location for resources"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "virtual_network" {
  description = "Virtual Network configuration"
  type = object({
    name          = string
    address_space = list(string)
  })
}

variable "subnets" {
  description = "Subnets to be created within the virtual network"
  type = map(object({
    address_prefix = string
  }))
}

variable "nsgs" {
  description = "Network Security Groups configuration"
  type = map(object({
    name = string
  }))
}

variable "load_balancer" {
  description = "Load balancer configuration"
  type = object({
    name                = string
    sku                 = string
  })
}

variable "public_ip" {
  description = "Public IP configuration for the load balancer"
  type = object({
    name              = string
    allocation_method = string
    sku               = string
  })
}

variable "backend_pool_name" {
  description = "Name of the load balancer backend address pool"
  type        = string
}

variable "nsg_rules" {
  description = "Network Security Rules configuration"
  type = map(object({
    name                    = string
    priority                = number
    direction               = string
    access                  = string
    protocol                = string
    source_port_range       = string
    destination_port_range  = string
    source_address_prefix   = string
    destination_address_prefix = string
    network_security_group   = string
  }))
}



variable "vm_configuration" {
  description = "Configuration for Virtual Machines"
  type = map(object({
    admin_username = string
    admin_password = string
    instance_count = number
  }))
}
variable "vmss_config" {
  type = map(object({
    sku                        = string
    instances                  = number
    admin_username             = string
    admin_password             = string
    network_security_group_id  = string
    subnet_id                  = string
    load_balancer_backend_pool = string
  }))
  description = "Configuration map for VM Scale Sets"
}




