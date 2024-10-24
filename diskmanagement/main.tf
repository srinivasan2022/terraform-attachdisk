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

module "networksecuritygroup" {
  source  = "Azure/avm-res-network-networksecuritygroup/azurerm"
  version = "0.2.0"
  
  name = var.nsg_name
  location = var.location
  resource_group_name = module.rg.name
  security_rules = local.nsg_rules
  depends_on = [ module.rg , module.subnet]
}

module "nsg_associate" {
  source = "../module/nsg_associate"
  nsg_id = module.networksecuritygroup.resource_id
  subnetid_nsg = module.subnet["subnet1"].resource_id
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
    public_ip_address_id = module.publicipaddress.public_ip_id
  }
  ip_connect_enabled     = true
  scale_units            = 4
  shareable_link_enabled = true
  tunneling_enabled      = true
  kerberos_enabled       = true

  depends_on = [ module.subnet,module.publicipaddress ]
}

module "testvm" {

  source = "Azure/avm-res-compute-virtualmachine/azurerm"
  version = "0.15.1"

  admin_username                     = "azureuser"
  admin_password                     = "P@ssword1234"
  disable_password_authentication    = false
  encryption_at_host_enabled         = false
  generate_admin_password_or_ssh_key = false
  location                           = var.location
  name                               = "VM"
  resource_group_name                = module.rg.name
  os_type                            = "Linux"
  sku_size                           = "Standard_D2s_v3"
  zone                               = "1"

  network_interfaces = {
    network_interface_1 = {
      name = "Nic"
      ip_configurations = {
        ip_configuration_1 = {
          name                          = "Nic-ipconfig1"
          private_ip_subnet_resource_id =module.subnet["subnet1"].resource_id
        }
      }
    }
  }

  os_disk = {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }
custom_data = filebase64("cloud-init.yml")
depends_on = [ module.rg,module.subnet ]
}

module "disk1" {
source  = "Azure/avm-res-compute-disk/azurerm"
  version = "0.2.2"
  for_each = var.disk1
  location            = var.location
  resource_group_name = module.rg.name
  name = each.value.name
  zone                = each.value.zone
  create_option         = each.value.create_option
  storage_account_type  = each.value.storage_account_type
  disk_size_gb          = each.value.disk_size_gb
  network_access_policy = each.value.network_access_policy
  depends_on = [ module.rg ]
}


module "attach-disk1" {
  source = "../module/attachdisk"
 
  manage_disk_id = module.disk1["disk1"].resource_id
  virtual_machine_id = module.testvm.resource_id
  lun = 0
  caching =  "ReadWrite"
  depends_on = [ module.disk1,module.testvm ]
}

module "attach-disk2" {
  source = "../module/attachdisk"
 
  manage_disk_id = module.disk1["disk2"].resource_id
  virtual_machine_id = module.testvm.resource_id
  lun = 1
  caching =  "ReadWrite"
  depends_on = [ module.disk1,module.testvm ]
}