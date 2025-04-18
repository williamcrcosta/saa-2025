resource "azurerm_network_interface" "vm-db-nic" {
  name                = "vm-db-nic"
  location            = azurerm_resource_group.rg-local.location
  resource_group_name = azurerm_resource_group.rg-local.name
  tags                = local.tags

  ip_configuration {
    name                          = "vm-db-nic-config01"
    subnet_id                     = azurerm_subnet.sub-db.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.2.4"
    public_ip_address_id          = azurerm_public_ip.pip-vm-db.id
  }
}


resource "azurerm_public_ip" "pip-vm-db" {
  name                = "pip-vm-db"
  location            = azurerm_resource_group.rg-local.location
  resource_group_name = azurerm_resource_group.rg-local.name
  allocation_method   = "Static"
  domain_name_label   = "vm-db-saa"
  tags                = local.tags
  depends_on = [azurerm_resource_group.rg-local
  ]
}

resource "azurerm_windows_virtual_machine" "vm-db" {
  name                = "vm-db"
  location            = azurerm_resource_group.rg-local.location
  resource_group_name = azurerm_resource_group.rg-local.name
  size                = "Standard_B2ms"
  admin_username      = "admin.william"
  admin_password      = "Partiunuvem@2024"
  computer_name       = "vm-db"
  tags                = local.tags
  network_interface_ids = [
    azurerm_network_interface.vm-db-nic.id
  ]

  source_image_reference {
    publisher = "MicrosoftSQLServer"
    offer     = "sql2022-ws2022"
    sku       = "sqldev-gen2"
    version   = "latest"
  }

  os_disk {
    name                 = "vm-db-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
    disk_size_gb         = "127"
  }

  boot_diagnostics {
    // Nesse modelo de configuração, voce estara utilizando o Storage Managed.
    // Se quiser utilizar um Storage Account para o Boot Diagnostics, descomentar a linha abaixo. Voce precisa ter um Storage Account criado antes, ou criar um Storage Account no codigo que estiver rodando.
    /* storage_account_uri = azurerm_storage_account.storage-local.primary_blob_endpoint */
  }

  # Configura o fuso horario da VM
  timezone = "E. South America Standard Time"

  depends_on = [azurerm_network_interface.vm-db-nic, azurerm_public_ip.pip-vm-db]

  # Habilita o agente de provisionamento da VM
  provision_vm_agent = true
}

resource "azurerm_dev_test_global_vm_shutdown_schedule" "vm-db-shutdown" {
  virtual_machine_id    = azurerm_windows_virtual_machine.vm-db.id
  location              = azurerm_resource_group.rg-local.location
  enabled               = true
  daily_recurrence_time = "1900"
  timezone              = "E. South America Standard Time"
  notification_settings {
    enabled = true
    email   = "william-crcosta@outlook.com"
  }

  depends_on = [azurerm_windows_virtual_machine.vm-db
  ]
  tags = local.tags
}

resource "azurerm_managed_disk" "sql-data-disk-vm-db" {
  name                 = "sql-data-disk-vm-db"
  location             = azurerm_resource_group.rg-local.location
  resource_group_name  = azurerm_resource_group.rg-local.name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = "8"
  tags                 = local.tags
  depends_on = [azurerm_windows_virtual_machine.vm-db
  ]
}

resource "azurerm_virtual_machine_data_disk_attachment" "sql-data-disk-vm-db-attach01" {
  managed_disk_id    = azurerm_managed_disk.sql-data-disk-vm-db.id
  virtual_machine_id = azurerm_windows_virtual_machine.vm-db.id
  lun                = "0"
  caching            = "ReadOnly"
  depends_on = [azurerm_managed_disk.sql-data-disk-vm-db
  ]
}

resource "azurerm_managed_disk" "sql-log-disk-vm-db" {
  name                 = "sql-log-disk-vm-db"
  location             = azurerm_resource_group.rg-local.location
  resource_group_name  = azurerm_resource_group.rg-local.name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = "8"
  tags                 = local.tags
  depends_on = [azurerm_virtual_machine_data_disk_attachment.sql-data-disk-vm-db-attach01
  ]
}

resource "azurerm_virtual_machine_data_disk_attachment" "sql-log-disk-vm-db-attach01" {
  managed_disk_id    = azurerm_managed_disk.sql-log-disk-vm-db.id
  virtual_machine_id = azurerm_windows_virtual_machine.vm-db.id
  lun                = "1"
  caching            = "None"
  depends_on = [azurerm_managed_disk.sql-log-disk-vm-db
  ]
}

resource "azurerm_virtual_machine_extension" "SqlIaasExtension" {
  name                       = "SqlIaasExtension"
  virtual_machine_id         = azurerm_windows_virtual_machine.vm-db.id
  publisher                  = "Microsoft.SqlServer.Management"
  type                       = "SqlIaaSAgent"
  type_handler_version       = "2.0"
  auto_upgrade_minor_version = true



  settings = <<SETTINGS
  {
    "WaiveSingleInstanceDatabaseSettings": true
  }
SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
  {
    "WaiveSingleInstanceDatabaseSettings": true
  }
PROTECTED_SETTINGS

  lifecycle {
    ignore_changes = [
      settings,
      automatic_upgrade_enabled,
    ]
  }
}

resource "azurerm_virtual_machine_extension" "DisableFW-InstallTelnet" {
  name                       = "DisableFW-InstallTelnet"
  virtual_machine_id         = azurerm_windows_virtual_machine.vm-db.id
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

resource "azurerm_mssql_virtual_machine" "sqlvm-db-vm-db" {
  /* depends_on = [null_resource.wait_for_vm_agent_vm-db-vm-db] */
  virtual_machine_id               = azurerm_windows_virtual_machine.vm-db.id
  sql_license_type                 = "PAYG"
  r_services_enabled               = true
  sql_connectivity_port            = 1433
  sql_connectivity_type            = "PRIVATE"
  sql_connectivity_update_password = "Partiunuvem@2024"
  sql_connectivity_update_username = "adminsql"
  depends_on                       = [azurerm_windows_virtual_machine.vm-db, azurerm_virtual_machine_extension.SqlIaasExtension, azurerm_virtual_machine_data_disk_attachment.sql-log-disk-vm-db-attach01]

  storage_configuration {
    disk_type             = "NEW"
    storage_workload_type = "OLTP"
    //storage_workload_type = "GENERAL"

    data_settings {
      default_file_path = "F:\\SQLVMDATA"
      luns              = [0]
    }

    log_settings {
      default_file_path = "G:\\SQLVMLOG"
      luns              = [1]
    }

    temp_db_settings {
      default_file_path = "D:\\"
      luns              = []
    }
  }
  tags = local.tags
}