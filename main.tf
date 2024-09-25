# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.90.0"
    }
  }

  required_version = ">= 0.14.9"
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "main" {
  name = "learn-tf-rg-eastus"
  location = "eastus"
}

resource "azurerm_virtual_network" "main" {
  name = "learn-tf-vnet"
  location = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name 
  address_space = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "main" {
  name = "learn-tf-subnet-eastus"
  virtual_network_name = azurerm_virtual_network.main.name 
  resource_group_name = azurerm_resource_group.main.name 
  address_prefixes = ["10.0.0.0/24"]
}

resource "azurerm_network_interface" "internal" {
  name = "learn-tf-nic-internal-eastus"
  location = azurerm_resource_group.main.location 
  resource_group_name = azurerm_resource_group.main.name 

  ip_configuration {
    name = "internal"
    subnet_id = azurerm_subnet.main.id 
    private_ip_address_allocation = "Dynamic" 
  }
}

resource "azurerm_windows_virtual_machine" "main" {
  name = "testvm"
  resource_group_name = azurerm_resource_group.main.name 
  location = azurerm_resource_group.main.location 
  size = "Standard_B1s" 
  admin_username = "user.admin" 
  admin_password = "123qweasd!@#QEAASD"

  network_interface_ids = [
    azurerm_network_interface.internal.id 
  ]
  
  os_disk {
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS" 
  }

  source_image_reference {
    publisher = "MicrosoftwindowsServer"
    offer = "WindowsServer"
    sku = "2016-Datacenter"
    version = "latest"
  }
 }

