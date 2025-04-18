data "azurerm_resource_group" "rg-local" {
  name = "rg-local"
}

# Cria um IP publico para a VM
resource "azurerm_public_ip" "vm-fw-pip" {
  name                = "vm-fw-pip"
  resource_group_name = data.azurerm_resource_group.rg-local.name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.tags
  domain_name_label   = "vm-fw-saa"
}

# Cria uma interface de rede para a VM
resource "azurerm_network_interface" "vm-fw-nic" {
  ip_forwarding_enabled = true
  name                  = "vm-fw-nic"
  location              = var.location
  resource_group_name   = data.azurerm_resource_group.rg-local.name
  //accelerated_networking_enabled = true

  ip_configuration {
    name                          = "vm-fw-ipconfig"
    subnet_id                     = azurerm_subnet.sub-fw.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.1.1.4"
    public_ip_address_id          = azurerm_public_ip.vm-fw-pip.id
  }
  tags = local.tags
}

# Cria a VM com o Windows Server
resource "azurerm_windows_virtual_machine" "vm-fw" {
  name                  = "vm-fw"
  resource_group_name   = data.azurerm_resource_group.rg-local.name
  location              = var.location
  size                  = "Standard_B2s"
  admin_username        = "" // Substitua pelo nome de usuário desejado
  admin_password        = "" // Substitua pela senha desejada
  network_interface_ids = [azurerm_network_interface.vm-fw-nic.id]
  tags                  = local.tags

  # Configura o disco do sistema operacional
  os_disk {
    caching              = "ReadWrite"
    disk_size_gb         = 128
    storage_account_type = "StandardSSD_LRS"
    name                 = "vm-fw-os-disk"
  }

  # Configura a imagem do sistema operacional
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition-hotpatch"
    version   = "latest"
  }

  # Habilita o agente de provisionamento da VM
  provision_vm_agent = true

  # Configura o fuso horario da VM
  timezone = "E. South America Standard Time"

  # Habilita o hotpatching
  hotpatching_enabled = true

  # Configura o modo de patch
  patch_mode = "AutomaticByPlatform"

  # Habilita o TPM
  vtpm_enabled = true

  # Habilita o Secure Boot
  secure_boot_enabled = true

  # Habilita as atualizacoes da plataforma
  vm_agent_platform_updates_enabled = true

  depends_on = [azurerm_network_interface.vm-fw-nic, azurerm_public_ip.vm-fw-pip]
}

resource "azurerm_virtual_machine_extension" "DisableFW" {
  name                       = "DisableFW"
  virtual_machine_id         = azurerm_windows_virtual_machine.vm-fw.id
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


resource "azurerm_dev_test_global_vm_shutdown_schedule" "shutdown-schedule-vm-fw" {
  virtual_machine_id    = azurerm_windows_virtual_machine.vm-fw.id
  location              = var.location
  enabled               = true
  daily_recurrence_time = "1900"
  timezone              = "E. South America Standard Time"
  notification_settings {
    enabled = true
    email   = "" // Substitua pelo email desejado
  }
}