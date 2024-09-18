module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.1"
  suffix = compact([
    var.app_name,
    var.environment,
    module.azure_region.location_short
  ])
}

module "azure_region" {
  source  = "claranet/regions/azurerm"
  version = "7.2.0"

  azure_region = var.location
}

data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "this" {
  count = var.create_resource_group == false ? 1 : 0
  name  = var.resource_group_name
}

resource "azurerm_resource_group" "this" {
  count    = var.create_resource_group == true ? 1 : 0
  name     = var.resource_group_name == null ? module.naming.resource_group.name : var.resource_group_name
  location = var.location
}

data "azurerm_virtual_network" "this" {
  name                = var.virtual_network_name
  resource_group_name = var.virtual_network_resource_group_name
}

data "azurerm_subnet" "this" {
  count                = var.create_subnet == false ? 1 : 0
  name                 = var.subnet_name
  virtual_network_name = data.azurerm_virtual_network.this.name
  resource_group_name  = data.azurerm_virtual_network.this.resource_group_name
}

resource "azurerm_subnet" "this" {
  count                = var.create_subnet == true ? 1 : 0
  name                 = var.subnet_name == null ? module.naming.subnet.name : var.subnet_name
  virtual_network_name = data.azurerm_virtual_network.this.name
  resource_group_name  = data.azurerm_virtual_network.this.resource_group_name
  address_prefixes     = [var.subnet_address_prefix]
}

resource "azurerm_network_interface" "this" {
  count               = var.virtual_machine_count
  name                = var.network_interface_name == null ? "${local.virtual_machine_names[count.index]}-nic01" : "${var.network_interface_name}${count.indext}"
  location            = var.location
  resource_group_name = local.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = local.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

data "azurerm_key_vault" "this" {
  count               = var.create_key_vault == false ? 1 : 0
  name                = var.key_vault_name
  resource_group_name = local.key_vault_resource_group_name
  depends_on          = [tls_private_key.this]
}

resource "azurerm_key_vault" "this" {
  count               = var.create_key_vault == true ? 1 : 0
  name                = var.key_vault_name == null ? module.naming.key_vault.name : var.key_vault_name
  resource_group_name = local.key_vault_resource_group_name
  location            = var.location
  sku_name            = "standard"
  tenant_id           = data.azurerm_client_config.current.tenant_id
  depends_on          = [tls_private_key.this]
}

resource "tls_private_key" "this" {
  count     = var.admin_login_type == "ssh" ? local.ssh_key_count : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_key_vault_secret" "privatekey" {
  count        = var.admin_login_type == "ssh" ? local.ssh_key_count : 0
  name         = "${local.virtual_machine_names[count.index]}-ssh"
  value        = tls_private_key.this[count.index].private_key_pem
  key_vault_id = local.key_vault_id
}

resource "azurerm_ssh_public_key" "this" {
  count               = var.admin_login_type == "ssh" ? local.ssh_key_count : 0
  name                = "${local.virtual_machine_names[count.index]}-ssh"
  resource_group_name = local.resource_group_name
  location            = var.location
  public_key          = tls_private_key.this[count.index].public_key_openssh
}

resource "random_password" "password" {
  count            = var.admin_login_type == "password" ? 1 : 0
  length           = 24
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "azurerm_linux_virtual_machine" "this" {
  count               = var.virtual_machine_count
  name                = local.virtual_machine_names[count.index]
  resource_group_name = local.resource_group_name
  location            = var.location
  size                = var.size
  admin_username      = var.admin_username
  admin_password      = var.admin_login_type == "password" ? random_password.password[0].result : null
  network_interface_ids = [
    azurerm_network_interface.this[count.index].id,
  ]

  identity {
    type = "SystemAssigned"
  }

  dynamic "admin_ssh_key" {
    for_each = var.admin_login_type == "ssh" ? [1] : []
    content {
      username = var.admin_username
      # TODO: Generate this
      public_key = var.single_ssh_key == true ? tls_private_key.this[0].public_key_openssh : tls_private_key.this[count.index].public_key_openssh
    }
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.os_storage_account_type
  }

  source_image_reference {
    publisher = var.image.publisher
    offer     = var.image.offer
    sku       = var.image.sku
    version   = var.image.version
  }

  boot_diagnostics {
    storage_account_uri = null
  }
}


# TODO: Add
# - more disk options
# - custom image
# - diagnostics