# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.65"
    }
  }

}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "az700"
  location = "eastus"
}

# Create a virtual network
resource "azurerm_virtual_network" "vnet0" {
    name                = "vnet0"
    address_space       = ["10.0.0.0/16"]
    location            = "eastus"
    resource_group_name = azurerm_resource_group.rg.name
}
# Create web subnet
resource "azurerm_subnet" "frontend-vnet0" {
  name                 = "frontend"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet0.name
  address_prefixes     = ["10.0.0.0/24"]
}
# Create backend subnet 
resource "azurerm_subnet" "backend-vnet0" {
  name                 = "backend"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet0.name
  address_prefixes     = ["10.0.1.0/24"]
}
# Create a virtual network
resource "azurerm_virtual_network" "vnet1" {
    name                = "vnet1"
    address_space       = ["10.1.0.0/16"]
    location            = "eastus"
    resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "frontend-vnet1" {
  name                 = "frontend"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefixes     = ["10.1.0.0/24"]
}
# Create backend subnet 
resource "azurerm_subnet" "backend-vnet1" {
  name                 = "backend"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefixes     = ["10.1.1.0/24"]
}
resource "azurerm_network_security_group" "frontend-nsg" {
  name                = "frontend-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}
resource "azurerm_network_security_rule" "rule0" {
    name                       = "myIP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    resource_group_name        = azurerm_resource_group.rg.name
    network_security_group_name = azurerm_network_security_group.frontend-nsg.name
  }

resource "azurerm_subnet_network_security_group_association" "nsgadd0" {
  subnet_id                 = azurerm_subnet.frontend-vnet0.id
  network_security_group_id = azurerm_network_security_group.frontend-nsg.id
}

resource "azurerm_subnet_network_security_group_association" "nsgadd1" {
  subnet_id                 = azurerm_subnet.frontend-vnet1.id
  network_security_group_id = azurerm_network_security_group.frontend-nsg.id
}
resource "azurerm_virtual_network_peering" "peering01" {
  name                      = "peer0to1"
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = azurerm_virtual_network.vnet0.name
  remote_virtual_network_id = azurerm_virtual_network.vnet1.id
}

resource "azurerm_virtual_network_peering" "peering10" {
  name                      = "peer1to0"
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = azurerm_virtual_network.vnet1.name
  remote_virtual_network_id = azurerm_virtual_network.vnet0.id
}

resource "azurerm_dns_zone" "public-zone" {
  name                = "techcademy.ca"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone" "private-zone" {
  name                = "private.techcademy.ca"
  resource_group_name = azurerm_resource_group.rg.name
}

