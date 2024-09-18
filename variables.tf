locals {
  resource_group_name = try(azurerm_resource_group.this[0].name, data.azurerm_resource_group.this[0].name, null)
  virtual_machine_names = flatten([for v in range(0, var.virtual_machine_count) : [
    var.virtual_machine_name == null ? join("-", compact(concat(
      ["${module.naming.linux_virtual_machine.slug}"],
      [try("${var.app_name}${format("%02d", v + 1)}", "${format("%02d", v + 1)}")],
      local.suffix
    ))) : "${var.virtual_machine_name}${format("%02d", v + 1)}"
  ]])
  subnet_name                   = try(azurerm_subnet.this[0].name, data.azurerm_subnet.this[0].name)
  subnet_id                     = provider::azurerm::normalise_resource_id(try(azurerm_subnet.this[0].id, data.azurerm_subnet.this[0].id))
  key_vault_name                = try(azurerm_key_vault.this[0].name, data.azurerm_key_vault.this[0].name)
  key_vault_id                  = provider::azurerm::normalise_resource_id(try(azurerm_key_vault.this[0].id, data.azurerm_key_vault.this[0].id, null))
  key_vault_resource_group_name = var.key_vault_resource_group_name == null ? local.resource_group_name : var.key_vault_resource_group_name
  suffix = compact([
    var.environment,
    module.azure_region.location_short
  ])
  ssh_key_count = var.single_ssh_key == true ? 1 : var.virtual_machine_count
}

variable "subscription_id" {
  type        = string
  default     = null
  description = "(Required) Subscription Id for the deployment"
}

variable "app_name" {
  type        = string
  default     = null
  nullable    = true
  description = "(Optional) The name of the application that the VM is being used for."
}

variable "environment" {
  type        = string
  default     = null
  nullable    = true
  description = "(Optional) Environment to be used in the name for the resources"
}

variable "location" {
  type        = string
  default     = "eastus"
  description = "(Optional) The region to deploy the resources to"
}

variable "resource_group_name" {
  type        = string
  default     = null
  nullable    = true
  description = "(Optional) The name of the resource group to deploy to"
}

variable "create_resource_group" {
  type        = bool
  default     = true
  description = "(Optional) To specify if you want to create a new resource group or use an existing one"
}

variable "virtual_network_name" {
  type        = string
  default     = null
  description = "(Required) Supply a virtual network name that the network interface will use"
}

variable "virtual_network_resource_group_name" {
  type        = string
  default     = null
  description = "(Required) Specify the virtual network resource group where the specified virtual network resides"
}

variable "subnet_name" {
  type        = string
  default     = null
  nullable    = true
  description = "(Optional) The name of the subnet to create or assign to the network interface"
}

variable "create_subnet" {
  type        = bool
  default     = false
  description = "(Optional) Create a new subnet or use an existing one"
}

variable "subnet_address_prefix" {
  type     = string
  default  = null
  nullable = true
  validation {
    condition     = anytrue([var.subnet_address_prefix == null, var.create_subnet == true])
    error_message = "`var.create_subnet` must be true to assign an address prefix."
  }


  description = "(Optional) Only required if `create_subnet` = true"
}

variable "network_interface_name" {
  type        = string
  default     = null
  nullable    = true
  description = "(Optional) The name of the VM network interface. If nothing specified this will be the <vm_name>-nic."
}

variable "virtual_machine_name" {
  type        = string
  default     = null
  nullable    = true
  description = "(Optional) The name of the virtual machine to create. If not specified one will be generated for you."
}

variable "virtual_machine_count" {
  type    = number
  default = 3
  validation {
    condition     = alltrue([var.virtual_machine_count >= 1, var.virtual_machine_count <= 3])
    error_message = "Virtual machine count must be between 1 and 3."
  }
  description = "(Optional) The number of virtual machines to create"
}

variable "size" {
  type        = string
  default     = "Standard_B1s" #"Standard_D2s_v3"
  description = "(Optional) SKU Size for the VM."
}

variable "admin_username" {
  type        = string
  default     = "adminuser"
  description = "(Optional) Admin user to create for the VM."
}

variable "admin_login_type" {
  type    = string
  default = "ssh"
  validation {
    condition     = contains(["password", "ssh"], var.admin_login_type)
    error_message = "login_type must be either ssh or password"
  }
  description = "(Optional) Set the login type for the adminuser. ssh or password."
}

variable "os_storage_account_type" {
  type        = string
  default     = "Standard_LRS"
  description = "(Optional) Storage account type for the OS disk"
}

variable "image" {
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  default = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  description = "OS Image Reference"
}

variable "single_ssh_key" {
  type        = bool
  default     = true
  description = "(Optional) Use the same SSH key for all VMs."
}

variable "key_vault_name" {
  type     = string
  default  = null
  nullable = true
  validation {
    condition     = anytrue([var.key_vault_name == null, var.admin_login_type == "ssh"])
    error_message = "`login_type` must be set to ssh if a value is specified"
  }
  description = "(Optional) Key Vault to store the private ssh key"
}

variable "key_vault_resource_group_name" {
  type        = string
  default     = null
  nullable    = true
  description = "(Optional) Existing key vault resource group name. If not provided it will attempt to use the var.resource_group_name or create a new key vault."
}

variable "create_key_vault" {
  type    = bool
  default = false
  validation {
    condition = anytrue([
      var.create_key_vault == false,
      alltrue([
        var.key_vault_resource_group_name == null,
        var.create_resource_group == true
      ])
    ])
    error_message = "Can not create a key_vault when both `var.create_resource_group` is true and `var.key_vault_resource_group_name` is null."
  }
  description = "(Optional) Specify if you would like to create a new key vault or use an existing one. One will be created anyway if you specify ssh key creation."
}
