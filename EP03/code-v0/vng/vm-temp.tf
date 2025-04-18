data "azurerm_subnet" "wc-snet-prd-uks-001" {
  name                 = "wc-snet-prd-uks-001"
  virtual_network_name = data.azurerm_virtual_network.wc-vnet-prd-uks-001.name
  resource_group_name  = data.azurerm_resource_group.wc-rg-prd-uks-001.name
}

# Cria um IP publico para a VM
resource "azurerm_public_ip" "wc-pip-dev-vm-uks-001" {
  name                = "wc-pip-dev-vm-uks-001"
  resource_group_name = data.azurerm_resource_group.wc-rg-prd-uks-001.name
  location            = data.azurerm_resource_group.wc-rg-prd-uks-001.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.tags
  domain_name_label   = "wcdevvm"
}

# Cria uma interface de rede para a VM
resource "azurerm_network_interface" "wc-nic-dev-vm-uks-001" {
  name                = "wc-nic-dev-vm-uks-001"
  location            = data.azurerm_resource_group.wc-rg-prd-uks-001.location
  resource_group_name = data.azurerm_resource_group.wc-rg-prd-uks-001.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = data.azurerm_subnet.wc-snet-prd-uks-001.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.wc-pip-dev-vm-uks-001.id
  }
  tags = local.tags
}

# Cria a VM com o Windows Server
resource "azurerm_windows_virtual_machine" "wc-vm-dev-tmp-uks-001" {
  name                  = "wc-vm-dev-tmp-uks-001"
  resource_group_name   = data.azurerm_resource_group.wc-rg-prd-uks-001.name
  location              = data.azurerm_resource_group.wc-rg-prd-uks-001.location
  size                  = "Standard_B2s"
  admin_username        = "" // Substitua pelo seu nome de usuário
  admin_password        = "" // Substitua pela sua senha
  network_interface_ids = [azurerm_network_interface.wc-nic-dev-vm-uks-001.id]
  tags                  = local.tags

  # Configura o disco do sistema operacional
  os_disk {
    caching              = "ReadWrite"
    disk_size_gb         = 128
    storage_account_type = "StandardSSD_LRS"
    name                 = "wc-vm-dev-tmp-uks-001-osdisk"
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
}

resource "azurerm_virtual_machine_extension" "DisableFW-wc-vm-dev-tmp-uks-001" {
  name                       = "DisableFW-wc-vm-dev-tmp-uks-001"
  virtual_machine_id         = azurerm_windows_virtual_machine.wc-vm-dev-tmp-uks-001.id
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

resource "azurerm_dev_test_global_vm_shutdown_schedule" "shutdown-schedule-dev-vm-uks-001" {
  virtual_machine_id    = azurerm_windows_virtual_machine.wc-vm-dev-tmp-uks-001.id
  location              = data.azurerm_resource_group.wc-rg-prd-uks-001.location
  enabled               = true
  daily_recurrence_time = "1900"
  timezone              = "E. South America Standard Time"
  notification_settings {
    enabled = true
    email   = "email@dominio" // Substitua pelo seu e-mail
  }
}