terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg_tpvm" {
  name     = "rg-tp-vm"
  location = "France Central"
}
resource "azurerm_virtual_network" "vnet_tp" {
  name                = "vnet-tp"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg_tpvm.location
  resource_group_name = azurerm_resource_group.rg_tpvm.name
}

resource "azurerm_subnet" "subnet_tp" {
  name                 = "subnet-tp"
  resource_group_name  = azurerm_resource_group.rg_tpvm.name
  virtual_network_name = azurerm_virtual_network.vnet_tp.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "nic_vm1" {
  name                = "nic-vm1"
  location            = azurerm_resource_group.rg_tpvm.location
  resource_group_name = azurerm_resource_group.rg_tpvm.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet_tp.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "nic_vm2" {
  name                = "nic-vm2"
  location            = azurerm_resource_group.rg_tpvm.location
  resource_group_name = azurerm_resource_group.rg_tpvm.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet_tp.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "vm1" {
  name                = "vm-tp-1"
  resource_group_name = azurerm_resource_group.rg_tpvm.name
  location            = azurerm_resource_group.rg_tpvm.location
  size                = "Standard_B1s"   # petite VM pour coût minimal
  admin_username      = "azureuser"
  network_interface_ids = [azurerm_network_interface.nic_vm1.id]
  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

resource "azurerm_linux_virtual_machine" "vm2" {
  name                = "vm-tp-2"
  resource_group_name = azurerm_resource_group.rg_tpvm.name
  location            = azurerm_resource_group.rg_tpvm.location
  size                = "Standard_B1s"
  admin_username      = "azureuser"
  network_interface_ids = [azurerm_network_interface.nic_vm2.id]
  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}