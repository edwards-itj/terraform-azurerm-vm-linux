locals {
  resource_group_name = try(azurerm_resource_group.this[0].name, data.azurerm_resource_group.this[0].name, null)
  virtual_machine_names = flatten([for v in range(0, var.virtual_machine_count) : [
    var.virtual_machine_name == null ? join("-", compact(concat(
      [module.naming.linux_virtual_machine.slug],
      [try("${var.app_name}${format("%02d", v + 1)}", format("%02d", v + 1))],
      local.suffix
    ))) : "${var.virtual_machine_name}${format("%02d", v + 1)}"
  ]])
  subnet_id                     = provider::azurerm::normalise_resource_id(try(azurerm_subnet.this[0].id, data.azurerm_subnet.this[0].id))
  key_vault_id                  = provider::azurerm::normalise_resource_id(try(azurerm_key_vault.this[0].id, data.azurerm_key_vault.this[0].id, null))
  key_vault_resource_group_name = var.key_vault_resource_group_name == null ? local.resource_group_name : var.key_vault_resource_group_name
  suffix = compact([
    var.environment,
    module.azure_region.location_short
  ])
  ssh_key_count = var.single_ssh_key == true ? 1 : var.virtual_machine_count
}