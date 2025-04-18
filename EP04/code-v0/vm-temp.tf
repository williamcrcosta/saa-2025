resource "azurerm_public_ip" "vm-client-pip" {
  name                = "vm-client-pip"
  resource_group_name = data.azurerm_resource_group.rg-local.name
  location            = var.location
  domain_name_label   = "vm-client-saa"
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.tags
}

resource "azurerm_network_interface" "vm-client-nic" {
  name                = "vm-client-nic"
  resource_group_name = data.azurerm_resource_group.rg-local.name
  location            = var.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.sub-fw.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.1.1.5"
    public_ip_address_id          = azurerm_public_ip.vm-client-pip.id
  }

  tags = local.tags
}

resource "azurerm_windows_virtual_machine" "vm-client" {
  name                = "vm-client"
  resource_group_name = data.azurerm_resource_group.rg-local.name
  location            = var.location
  size                = "Standard_B2s"
  admin_username      = "" // Substitua pelo nome de usuário desejado
  admin_password      = "" // Substitua pela senha desejada
  network_interface_ids = [
    azurerm_network_interface.vm-client-nic.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
    disk_size_gb         = 128
    //managed              = true
    name = "OSDisk-vm-client"
  }
  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "Windows-11"
    sku       = "win11-24h2-pro"
    version   = "latest"
  }

  tags = local.tags

  provision_vm_agent = true

  timezone                          = "E. South America Standard Time"
  vtpm_enabled                      = true
  secure_boot_enabled               = true
  vm_agent_platform_updates_enabled = true
}

resource "azurerm_virtual_machine_extension" "DisableFW-vm-client" {
  name                       = "DisableFW-vm-client"
  virtual_machine_id         = azurerm_windows_virtual_machine.vm-client.id
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.9"
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
  {
    "commandToExecute": "powershell netsh advfirewall set allprofiles state off"
  }
SETTINGS
}

resource "azurerm_dev_test_global_vm_shutdown_schedule" "shutdown-schedule-vm-client" {
  virtual_machine_id    = azurerm_windows_virtual_machine.vm-client.id
  location              = var.location
  enabled               = true
  daily_recurrence_time = "1900"
  timezone              = "E. South America Standard Time"
  notification_settings {
    enabled = true
    email   = "" # Substitua pelo seu e-mail
  }
}