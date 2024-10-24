locals {

     nsg_rules = {

    "rule01" = {

      name                       = "rules"

      access                     = "Allow"

      destination_address_prefix = "*"

      destination_port_ranges    = ["22","443","80"]

      direction                  = "Inbound"

      priority                   = 100

      protocol                   = "Tcp"

      source_address_prefix      = "*"

      source_port_range          = "*"

    }

  }

}
 