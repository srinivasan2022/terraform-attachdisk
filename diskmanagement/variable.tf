variable "resource_group" {
    type = string
    description  = "this is resource groyp name"
  
}

variable "location" {
  type = string
  description = "this is location"
}

variable "virtual_network" {

type = map(object({
  name = string
  address_space = string
})) 
}

variable "subnet" {
  type = map(object({
    name = string
    address_prefixes = string
    #zone = string
  }))
}

variable "nsg_name" {
  type = string
}

variable "publicip_name" {
  type = string
}

variable "bastionhost_name" {
  type = string
}

variable "disk1" {
  type = map(object({
  name                = string
  zone                = number
  create_option         = string
  storage_account_type  = string
  disk_size_gb          = number
   network_access_policy = string
  }))
}