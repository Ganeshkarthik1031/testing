provider "azurerm" {
  features {}
subscription_id = "a287fb88-6a13-4164-bde1-ae0244dcd56e"
client_id = "450c5e9d-448e-4925-9f81-50cd0bc48174"
tenant_id = "10a0ccb3-c57f-463b-a44b-fac48a5f6f74"
}

resource "azurerm_resource_group" "example" {
  name     = "CDPInterns-2326888-Persistent-RG"
  location = "Central US"
}

resource "azurerm_virtual_network" "main" {
  name                = "ak-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}
 
resource "azurerm_network_interface" "main" {
  name                = "my-nic"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
 
  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
}
 
resource "azurerm_virtual_machine" "main" {
  name                  = "my-vm"
  location              = azurerm_resource_group.example.location
  resource_group_name   = azurerm_resource_group.example.name
  network_interface_ids = [azurerm_network_interface.main.id]
  vm_size               = "Standard_B1s"
 
  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
 
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
 
  os_profile {
    computer_name  = "my-vm"
    admin_username = "adminuser"
    admin_password = "P@ssw0rd123!"
  }
 
  os_profile_linux_config {
    disable_password_authentication = false
  }
 
  tags = {
    environment = "dev"
  }
}
