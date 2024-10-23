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

variable "publicip_name" {
  type = string
}

variable "bastionhost_name" {
  type = string
}