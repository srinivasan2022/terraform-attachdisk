#create resource group
module "rg" {
  source  = "Azure/avm-res-resources-resourcegroup/azurerm"
  version = "0.1.0"
  name = var.resource_group
  location = var.location
}

#create virtual network
module "virtualnetwork" {
  source = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "0.4.0"
  for_each = var.virtual_network
  address_space      = [each.value.address_space]
  location            = var.location
  name                = each.key
  resource_group_name = module.rg.name
  
  depends_on = [ module.rg ]
}

module "subnet" {
  source = "Azure/avm-res-network-virtualnetwork/azurerm//modules/subnet"

  virtual_network = {
    resource_id = module.virtualnetwork["DiskVNet"].resource_id
  }
   for_each = var.subnet
  name             = each.value.name
  address_prefixes =  [each.value.address_prefixes]
  depends_on = [module.virtualnetwork]

}

module "publicipaddress" {
  source  = "Azure/avm-res-network-publicipaddress/azurerm"
  version = "0.1.2"
  resource_group_name = module.rg.name
  name                = var.publicip_name
  location            = var.location
  depends_on = [ module.rg ]
}


module "azure_bastion" {
   source  = "Azure/avm-res-network-bastionhost/azurerm"
  version = "0.3.0"

 
  name                = var.bastionhost_name
  resource_group_name = module.rg.name
  location            = var.location
  copy_paste_enabled  = true
  file_copy_enabled   = false
  sku                 = "Standard"
  ip_configuration = {
    name                 = "my-ipconfig"
    subnet_id            = module.subnet["AzureBastionSubnet"].resource_id
    public_ip_address_id = azurerm_public_ip.example.id
  }
  ip_connect_enabled     = true
  scale_units            = 4
  shareable_link_enabled = true
  tunneling_enabled      = true
  kerberos_enabled       = true

  
}

module "testvm" {

  source = "Azure/avm-res-compute-virtualmachine/azurerm"
  version = "0.15.1"

  location            = var.location
  resource_group_name = module.rg.name
  os_type             = "Linux"
  name                = "VM1"
  sku_size            = "Standard_DS1_v2"
  zone                = "1"

  

  source_image_reference = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  network_interfaces = {
    network_interface_1 = {
      name = "nic"
      ip_configurations = {
        ip_configuration_1 = {
          name                          = "nic-ipconfig1"
          private_ip_subnet_resource_id = module.subnet["subnet1"].resource_id
        }
      }
    }
  }


depends_on = [ module.rg,module.subnet ]
 
}