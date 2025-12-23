module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.2"
  suffix = compact([
    var.app_name,
    var.environment,
    module.azure_region.location_short
  ])
}

module "azure_region" {
  source  = "claranet/regions/azurerm"
  version = "8.0.2"

  azure_region = var.location
}

data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "this" {
  count = var.create_resource_group == false ? 1 : 0

  name = var.resource_group_name
}

resource "azurerm_resource_group" "this" {
  count = var.create_resource_group == true ? 1 : 0

  location = var.location
  name     = var.resource_group_name == null ? module.naming.resource_group.name : var.resource_group_name
}

data "azurerm_virtual_network" "this" {
  name                = var.virtual_network_name
  resource_group_name = var.virtual_network_resource_group_name
}

data "azurerm_subnet" "this" {
  count = var.create_subnet == false ? 1 : 0

  name                 = var.subnet_name
  resource_group_name  = data.azurerm_virtual_network.this.resource_group_name
  virtual_network_name = data.azurerm_virtual_network.this.name
}

resource "azurerm_subnet" "this" {
  count = var.create_subnet == true ? 1 : 0

  address_prefixes     = [var.subnet_address_prefix]
  name                 = var.subnet_name == null ? module.naming.subnet.name : var.subnet_name
  resource_group_name  = data.azurerm_virtual_network.this.resource_group_name
  virtual_network_name = data.azurerm_virtual_network.this.name
}

resource "azurerm_network_interface" "this" {
  count = var.virtual_machine_count

  location            = var.location
  name                = var.network_interface_name == null ? "${local.virtual_machine_names[count.index]}-nic01" : "${var.network_interface_name}${count.index}"
  resource_group_name = local.resource_group_name

  ip_configuration {
    name                          = "internal"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = local.subnet_id
  }
}

data "azurerm_key_vault" "this" {
  count = var.create_key_vault == false ? 1 : 0

  name                = var.key_vault_name
  resource_group_name = local.key_vault_resource_group_name

  depends_on = [tls_private_key.this]
}

resource "azurerm_key_vault" "this" {
  count = var.create_key_vault == true ? 1 : 0

  location            = var.location
  name                = var.key_vault_name == null ? module.naming.key_vault.name : var.key_vault_name
  resource_group_name = local.key_vault_resource_group_name
  sku_name            = "standard"
  tenant_id           = data.azurerm_client_config.current.tenant_id

  depends_on = [tls_private_key.this]
}

resource "tls_private_key" "this" {
  count = var.admin_login_type == "ssh" ? local.ssh_key_count : 0

  algorithm = "RSA"
  rsa_bits  = 4096
}

#trivy:ignore:avd-azu-0017 (LOW)
resource "azurerm_key_vault_secret" "privatekey" {
  count = var.admin_login_type == "ssh" ? local.ssh_key_count : 0

  key_vault_id = local.key_vault_id
  name         = "${local.virtual_machine_names[count.index]}-ssh"
  value        = tls_private_key.this[count.index].private_key_pem
  content_type = "privatekey"
}

resource "azurerm_ssh_public_key" "this" {
  count = var.admin_login_type == "ssh" ? local.ssh_key_count : 0

  location            = var.location
  name                = "${local.virtual_machine_names[count.index]}-ssh"
  public_key          = tls_private_key.this[count.index].public_key_openssh
  resource_group_name = local.resource_group_name
}

resource "random_password" "password" {
  count = var.admin_login_type == "password" ? 1 : 0

  length           = 24
  override_special = "!#$%&*()-_=+[]{}<>:?"
  special          = true
}

resource "azurerm_linux_virtual_machine" "this" {
  count = var.virtual_machine_count

  admin_username = var.admin_username
  location       = var.location
  name           = local.virtual_machine_names[count.index]
  network_interface_ids = [
    azurerm_network_interface.this[count.index].id,
  ]
  resource_group_name = local.resource_group_name
  size                = var.size
  admin_password      = var.admin_login_type == "password" ? random_password.password[0].result : null

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.os_storage_account_type
  }
  dynamic "admin_ssh_key" {
    for_each = var.admin_login_type == "ssh" ? [1] : []

    content {
      # TODO: Generate this
      public_key = var.single_ssh_key == true ? tls_private_key.this[0].public_key_openssh : tls_private_key.this[count.index].public_key_openssh
      username   = var.admin_username
    }
  }
  boot_diagnostics {
    storage_account_uri = null
  }
  identity {
    type = "SystemAssigned"
  }
  source_image_reference {
    offer     = var.image.offer
    publisher = var.image.publisher
    sku       = var.image.sku
    version   = var.image.version
  }
}


# TODO: Add
# - more disk options
# - custom image
# - diagnostics