# Cria um IP publico para a VM
resource "azurerm_public_ip" "vm-saa-pip" {
  name                = "vm-saa-pip"
  resource_group_name = azurerm_resource_group.rg-saa.name
  location            = azurerm_resource_group.rg-saa.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.tags
}

# Cria uma interface de rede para a VM
resource "azurerm_network_interface" "vm-saa-nic" {
  name                = "vm-saa-nic"
  location            = azurerm_resource_group.rg-saa.location
  resource_group_name = azurerm_resource_group.rg-saa.name

  ip_configuration {
    name                          = "vm-saa-ipconfig"
    subnet_id                     = azurerm_subnet.sub-saa.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm-saa-pip.id
  }
  tags = local.tags
}

# Cria a VM com o Windows Server
resource "azurerm_windows_virtual_machine" "vm-saa" {
  name                  = "vm-saa"
  resource_group_name   = azurerm_resource_group.rg-saa.name
  location              = azurerm_resource_group.rg-saa.location
  size                  = "Standard_B2s"
  admin_username        = "" // Substitua pelo nome de usuário desejado
  admin_password        = "" // Substitua pela senha desejada
  network_interface_ids = [azurerm_network_interface.vm-saa-nic.id]
  tags                  = local.tags

  # Configura o disco do sistema operacional
  os_disk {
    caching              = "ReadWrite"
    disk_size_gb         = 128
    storage_account_type = "StandardSSD_LRS"
    name                 = "vm-saa-os-disk"
  }

  # Configura a imagem do sistema operacional
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    //sku       = "2025-datacenter-azure-edition"
    sku     = "2022-datacenter-azure-edition-hotpatch"
    version = "latest"
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
}

resource "azurerm_dev_test_global_vm_shutdown_schedule" "shutdown-schedule-vm-saa" {
  virtual_machine_id    = azurerm_windows_virtual_machine.vm-saa.id
  location              = azurerm_resource_group.rg-saa.location
  enabled               = true
  daily_recurrence_time = "1900"
  timezone              = "E. South America Standard Time"
  notification_settings {
    enabled = true
    email   = "" // Substitua pelo email desejado
  }
}