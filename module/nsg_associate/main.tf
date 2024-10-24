resource "azurerm_subnet_network_security_group_association" "ag_subnet_nsg_associate" {
   
  
  network_security_group_id = var.nsg_id 
  subnet_id = var.subnetid_nsg
}