terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
    }
  }
}

provider "azurerm" {

  subscription_id = "e1746ee6-9f0b-456a-a201-d22521e844d2"
  client_id       = "fe690209-8490-4136-bfbd-49fefc6dae69"
  client_secret   = ".1Vr6C_j~Zk_eM0x6z0Nh-B9_hrcoa_MJf"
  tenant_id       = "128ddc97-a8cb-424f-9681-e32cde80bb8c"

  features {}
}

#Use resource group
data "azurerm_resource_group" "rg" {
  name = "petclinicjmeter"
 
}

#Create resource group
# resource "azurerm_resource_group" "rg" {
#   name     = "petclinicjmeter"
#   location = "westeurope"
# }



#Create virtual network
resource "azurerm_virtual_network" "terraformnetwork" {
    name                = "Vnet"
    address_space       = ["10.0.0.0/16"]
    location            = "westeurope"
    resource_group_name = data.azurerm_resource_group.rg.name

    tags = {
        environment = "Terraform Demo"
    }
}

#Use existing subnet
# data "azurerm_subnet" "subnet" {
#   name                 = "mySubnet"
#   virtual_network_name = "myVnet"
#   resource_group_name  = "petclinicjmeter"
# }

#Create subnet 
resource "azurerm_subnet" "terraformsubnet" {
    name                 = "Subnet"
    resource_group_name  = data.azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.terraformnetwork.name
    address_prefixes       = ["10.0.2.0/24"]
}

#Use existing IP address
data "azurerm_public_ip" "test" {
  name                = "pubip"
  resource_group_name = "petclinicjmeter"

  timeouts {
        read = "5m"
  }
}




#Create network security group
resource "azurerm_network_security_group" "terraformnsg" {
    name                = "NetworkSecurityGroup"
    location            = "westeurope"
    resource_group_name = data.azurerm_resource_group.rg.name

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

#Create inbound rule for docker container
resource "azurerm_network_security_rule" "docker" {
    name                        = "docker"
    priority                    = 1011
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "*"
    destination_port_range      = "8086"
    source_address_prefix       = "*"
    destination_address_prefix  = "*"
    resource_group_name         = data.azurerm_resource_group.rg.name
    network_security_group_name = azurerm_network_security_group.terraformnsg.name
}

#Create virtual network interface
resource "azurerm_network_interface" "terraformnic" {
    name                        = "NIC"
    location                    = "westeurope"
    resource_group_name         = data.azurerm_resource_group.rg.name

    ip_configuration {
        name                          = "NicConfiguration"
        subnet_id                     = azurerm_subnet.terraformsubnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = data.azurerm_public_ip.test.id
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

#Create storage account
resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = data.azurerm_resource_group.rg.name
    }

    byte_length = 8
}

resource "azurerm_storage_account" "storageaccount" {
    name                        = "diag${random_id.randomId.hex}"
    resource_group_name         = data.azurerm_resource_group.rg.name
    location                    = "westeurope"
    account_replication_type    = "LRS"
    account_tier                = "Standard"

    tags = {
        environment = "Terraform Demo"
    }
}

#Create Virtual Machine
resource "azurerm_linux_virtual_machine" "terraformvm" {
    name                  = "devserver"
    location              = "westeurope"
    resource_group_name   = data.azurerm_resource_group.rg.name
    network_interface_ids = [azurerm_network_interface.terraformnic.id]
    size                  = "Standard_DS1_v2"
    admin_username        = "azureuser"
    disable_password_authentication = true
    

    admin_ssh_key {
        username   = "azureuser"
        public_key = file("/var/lib/jenkins/.ssh/jenkins.pub")
    }

    os_disk {
        name              = "OsDisk"
        caching           = "ReadWrite"
        storage_account_type = "Premium_LRS"
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }
    

    boot_diagnostics {
        storage_account_uri = azurerm_storage_account.storageaccount.primary_blob_endpoint
    }

    tags = {
        environment = "Terraform Demo"
    }

    provisioner "file" {
        source      = "/var/lib/jenkins/workspace/jmeterProvisioning/ansible/main.yml"
        destination = "/home/azureuser/main.yml"
        connection {
            type     = "ssh"
            user     = "azureuser"
            host = data.azurerm_public_ip.test.ip_address
            private_key = "${file("/var/lib/jenkins/.ssh/jenkins")}"
            agent = false
            timeout = "400s"
        }
    }

    provisioner "remote-exec" {
        inline = [
            "sudo apt install software-properties-common",
            "sudo apt-add-repository --yes --update ppa:ansible/ansible",
            "sudo apt -y install ansible",
        ]

        connection {
            type        = "ssh"
            user        = "azureuser"
            host = data.azurerm_public_ip.test.ip_address
            private_key = "${file("/var/lib/jenkins/.ssh/jenkins")}"
        }
    }

    provisioner "remote-exec" {
        inline = [
            "ansible-playbook main.yml"
        ]

        connection {
            type        = "ssh"
            user        = "azureuser"
            host = data.azurerm_public_ip.test.ip_address
            private_key = "${file("/var/lib/jenkins/.ssh/jenkins")}"
        }
    }

    # provisioner "local-exec" {
    #     command = "ansible-playbook -u azureuser -i ${file("/home/joelle/.ssh/id_rsa.pub")} --private-key ${file("~/.ssh/id_rsa")} main.yml" 
    # }
}