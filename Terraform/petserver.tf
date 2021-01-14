terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
    }
  }
}

provider "azurerm" {
  features {}
}

#Create resource group
resource "azurerm_resource_group" "rg" {
  name     = "petclinic"
  location = "westeurope"
  tags = {
      environment = "Terraform Demo"
  }
}

#Create virtual network
resource "azurerm_virtual_network" "terraformnetwork" {
    name                = "myVnet"
    address_space       = ["10.0.0.0/16"]
    location            = "westeurope"
    resource_group_name = azurerm_resource_group.rg.name

    tags = {
        environment = "Terraform Demo"
    }
}

#Create subnet 
resource "azurerm_subnet" "terraformsubnet" {
    name                 = "mySubnet"
    resource_group_name  = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.terraformnetwork.name
    address_prefixes       = ["10.0.2.0/24"]
}

#Create public IP address
resource "azurerm_public_ip" "terraformpublicip" {
    name                         = "myPublicIP"
    location                     = "westeurope"
    resource_group_name          = azurerm_resource_group.rg.name
    allocation_method            = "Dynamic"

    tags = {
        environment = "Terraform Demo"
    }
}

#Create network security group
resource "azurerm_network_security_group" "terraformnsg" {
    name                = "myNetworkSecurityGroup"
    location            = "westeurope"
    resource_group_name = azurerm_resource_group.rg.name

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags = {
        environment = "Terraform Demo"
    }
}

#Create virtual network interface
resource "azurerm_network_interface" "terraformnic" {
    name                        = "myNIC"
    location                    = "westeurope"
    resource_group_name         = azurerm_resource_group.rg.name

    ip_configuration {
        name                          = "NicConfiguration"
        subnet_id                     = azurerm_subnet.terraformsubnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.terraformpublicip.id
    }

    tags = {
        environment = "Terraform Demo"
    }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "nisg" {
    network_interface_id      = azurerm_network_interface.terraformnic.id
    network_security_group_id = azurerm_network_security_group.terraformnsg.id
}