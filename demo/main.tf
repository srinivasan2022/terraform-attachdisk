terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }
  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = var.virtual_network.name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = var.virtual_network.address_space
}

# Subnets
resource "azurerm_subnet" "subnet" {
  for_each            = var.subnets
  name                = each.key
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes    = [each.value.address_prefix]
}

# Network Security Groups
resource "azurerm_network_security_group" "nsg" {
  for_each            = var.nsgs
  name                = each.value.name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Network Security Rules
resource "azurerm_network_security_rule" "nsg_rule" {
  for_each                    = var.nsg_rules
  name                        = each.value.name
  priority                    = each.value.priority
  direction                   = each.value.direction
  access                      = each.value.access
  protocol                    = each.value.protocol
  source_port_range           = each.value.source_port_range
  destination_port_range      = each.value.destination_port_range
  source_address_prefix       = each.value.source_address_prefix
  destination_address_prefix  = each.value.destination_address_prefix
  network_security_group_name = azurerm_network_security_group.nsg[each.value.network_security_group].name
  resource_group_name         = azurerm_resource_group.rg.name
}

# Network Interfaces and VMs
resource "azurerm_network_interface" "nic" {
  for_each            = var.vm_configuration
  name                = "nic-${each.key}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ipconfig-${each.key}"
    subnet_id                     = azurerm_subnet.subnet["subnet-main"].id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "vm" {
  for_each            = var.vm_configuration
  name                = each.key
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_DS1_v2"
  admin_username      = each.value.admin_username
  admin_password      = each.value.admin_password
  network_interface_ids = [azurerm_network_interface.nic[each.key].id]

  os_disk {
    caching                = "ReadWrite"
    storage_account_type   = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}


# Load Balancer
resource "azurerm_lb" "lb" {
  name                = var.load_balancer.name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = var.load_balancer.sku

  frontend_ip_configuration {
    name                 = "example-frontend"
    public_ip_address_id = azurerm_public_ip.lb_public_ip.id
  }
}

resource "azurerm_public_ip" "lb_public_ip" {
  name                = var.public_ip.name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = var.public_ip.allocation_method
  sku                 = var.public_ip.sku
}

resource "azurerm_lb_backend_address_pool" "backend_pool" {
  name                = var.backend_pool_name
  loadbalancer_id     = azurerm_lb.lb.id
}


resource "azurerm_windows_virtual_machine_scale_set" "vmss" {
  for_each            = var.vmss_config
  name                = each.key
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = each.value.sku
  instances           = each.value.instances
  admin_username      = each.value.admin_username
  admin_password      = each.value.admin_password
  upgrade_mode        = "Manual"

  network_interface {
    name                          = "nic-${each.key}"
    primary                       = true
    network_security_group_id     = each.value.network_security_group_id
    ip_configuration {
      name                                   = "ipconfig"
      subnet_id                              = each.value.subnet_id
      load_balancer_backend_address_pool_ids = [each.value.load_balancer_backend_pool]
      primary                                = true
    }
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}
