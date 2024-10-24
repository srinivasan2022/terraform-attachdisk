resource_group = "DiskRG"
location = "West Europe"

virtual_network = {
    DiskVNet = {
    name = "DiskVNet"
    address_space = "10.0.0.0/16"
  }
}
subnet = {
  "subnet1" = {
    name = "disk_subnet"
    address_prefixes = "10.0.1.0/24"
    #zone = "1"
  
},
"AzureBastionSubnet" = {
    name = "AzureBastionSubnet"
    address_prefixes = "10.0.2.0/24"
}
}
publicip_name = "Mypublicip"
bastionhost_name = "Mybastionhost"
nsg_name = "data-nsg"

disk1 = {
  "disk1"={
    name = "disk1"
    zone                = "1" 
  create_option         = "Empty"
  storage_account_type  = "Premium_LRS"
  disk_size_gb          = 16
  network_access_policy = "AllowAll"
  },
  "disk2" = {
    name = "disk2"
    zone                = "1" 
  create_option         = "Empty"
  storage_account_type  = "Premium_LRS"
  disk_size_gb          = 16
  network_access_policy = "AllowAll"
  }
}