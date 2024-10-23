resource "azurerm_virtual_machine_data_disk_attachment" "disk_attachment" {
  managed_disk_id    = var.manage_disk_id
  virtual_machine_id = var.virtual_machine_id
  lun                = var.lun
  caching            = var.caching
}
