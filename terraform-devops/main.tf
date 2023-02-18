terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.43.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "devops" {
  name     = "devops"
  location = "westeurope"
  tags = {
    enviroment = "devops"
  }
}

resource "azurerm_container_registry" "agentpool" {
  name                = "agentpool"
  resource_group_name = azurerm_resource_group.devops.name
  location            = azurerm_resource_group.devops.location
  sku                 = "Premium"
}

resource "azurerm_container_registry_agent_pool" "devops" {
  name                    = "devops"
  resource_group_name     = azurerm_resource_group.devops.name
  location                = azurerm_resource_group.devops.location
  container_registry_name = azurerm_container_registry.agentpool.name
}

resource "azurerm_virtual_network" "devops" {
  name = "devops-network"
  resource_group_name = azurerm_resource_group.devops.name
  location = azurerm_resource_group.devops.location
  address_space = [ "10.123.0.0/16" ]

  tags = {
    "enviroment" = "devops"
  }
}

resource "azurerm_subnet" "sub" {
  name                 = "sub"
  resource_group_name  = azurerm_resource_group.devops.name
  virtual_network_name = azurerm_virtual_network.devops.name
  address_prefixes     = ["10.0.2.0/16"]
}

resource "azurerm_network_interface" "devops" {
  name                = "devops"
  location            = azurerm_resource_group.devops.location
  resource_group_name = azurerm_resource_group.devops.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.sub.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "devops" {
  name                  = "devops"
  location              = azurerm_resource_group.devops.location
  resource_group_name   = azurerm_resource_group.devops.name
  network_interface_ids = [azurerm_network_interface.devops.id]
  vm_size               = "Standard_DS1_v2"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "staging"
  }
}

resource "azurerm_virtual_machine" "vm2" {
  name                  = "vm2"
  location              = azurerm_resource_group.devops.location
  resource_group_name   = azurerm_resource_group.devops.name
  network_interface_ids = [azurerm_network_interface.vm2.id]
  vm_size               = "Standard_DS1_v2"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "vm2"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
}

resource "azurerm_network_interface" "vm2" {
  name                = "vm2-nic"
  location            = azurerm_resource_group.devops.location
  resource_group_name = azurerm_resource_group.devops.name

  ip_configuration {
    name                          = "vm2-configuration"
    subnet_id                     = azurerm_subnet.sub.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_container_registry" "my_registry" {
  name                     = "myregistry"
  resource_group_name      = azurerm_resource_group.devops.name
  location                 = azurerm_resource_group.devops.location
  sku                      = "Premium"
  admin_enabled            = true
#   georeplication_locations = ["northeurope", "westeurope"]
  tags = {
    environment = "production"
  }
}

