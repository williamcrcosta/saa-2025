# Cria um IP publico para a VM
resource "azurerm_public_ip" "vm-app-pip" {
  name                = "vm-app-pip"
  resource_group_name = azurerm_resource_group.rg-local.name
  location            = azurerm_resource_group.rg-local.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.tags
  domain_name_label   = "vm-app-saa"
}

# Cria uma interface de rede para a VM
resource "azurerm_network_interface" "vm-app-nic" {
  name                = "vm-app-nic"
  location            = azurerm_resource_group.rg-local.location
  resource_group_name = azurerm_resource_group.rg-local.name

  ip_configuration {
    name                          = "vm-app-ipconfig"
    subnet_id                     = azurerm_subnet.sub-app.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm-app-pip.id
  }
  tags = local.tags
}

# Cria a VM com o Windows Server
resource "azurerm_windows_virtual_machine" "vm-app" {
  name                  = "vm-app"
  resource_group_name   = azurerm_resource_group.rg-local.name
  location              = azurerm_resource_group.rg-local.location
  size                  = "Standard_B2s"
  admin_username        = "admin.william"
  admin_password        = "Partiunuvem@123"
  network_interface_ids = [azurerm_network_interface.vm-app-nic.id]
  tags                  = local.tags

  # Configura o disco do sistema operacional
  os_disk {
    caching              = "ReadWrite"
    disk_size_gb         = 128
    storage_account_type = "StandardSSD_LRS"
    name                 = "vm-app-os-disk"
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

  boot_diagnostics {
    // Nesse modelo de configuração, voce estara utilizando o Storage Managed.
    // Se quiser utilizar um Storage Account para o Boot Diagnostics, descomentar a linha abaixo. Voce precisa ter um Storage Account criado antes, ou criar um Storage Account no codigo que estiver rodando.
    /* storage_account_uri = azurerm_storage_account.storage-local.primary_blob_endpoint */
  }
}

resource "azurerm_dev_test_global_vm_shutdown_schedule" "shutdown-schedule-vm-app" {
  virtual_machine_id    = azurerm_windows_virtual_machine.vm-app.id
  location              = azurerm_resource_group.rg-local.location
  enabled               = true
  daily_recurrence_time = "1900"
  timezone              = "E. South America Standard Time"
  notification_settings {
    enabled = true
    email   = "william-crcosta@outlook.com"
  }
}