<!-- BEGIN_TF_DOCS -->
[![Terraform](https://github.com/edwards-itj/terraform-azurerm-vm-linux/actions/workflows/terraform-check.yml/badge.svg)](https://github.com/edwards-itj/terraform-azurerm-vm-linux/actions/workflows/terraform-check.yml)

# Azure Linux VM Module

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (~> 1.9.5)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (>= 4)

- <a name="requirement_random"></a> [random](#requirement\_random) (3.6.3)

- <a name="requirement_tls"></a> [tls](#requirement\_tls) (4.0.6)

## Providers

The following providers are used by this module:

- <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) (>= 4)

- <a name="provider_random"></a> [random](#provider\_random) (3.6.3)

- <a name="provider_tls"></a> [tls](#provider\_tls) (4.0.6)

## Resources

The following resources are used by this module:

- [azurerm_key_vault.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault) (resource)
- [azurerm_key_vault_secret.privatekey](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) (resource)
- [azurerm_linux_virtual_machine.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine) (resource)
- [azurerm_network_interface.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) (resource)
- [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) (resource)
- [azurerm_ssh_public_key.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/ssh_public_key) (resource)
- [azurerm_subnet.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) (resource)
- [random_password.password](https://registry.terraform.io/providers/hashicorp/random/3.6.3/docs/resources/password) (resource)
- [tls_private_key.this](https://registry.terraform.io/providers/hashicorp/tls/4.0.6/docs/resources/private_key) (resource)
- [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) (data source)
- [azurerm_key_vault.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault) (data source)
- [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) (data source)
- [azurerm_subnet.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet) (data source)
- [azurerm_virtual_network.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network) (data source)

<!-- markdownlint-disable MD013 -->
## Required Inputs

No required inputs.

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_admin_login_type"></a> [admin\_login\_type](#input\_admin\_login\_type)

Description: (Optional) Set the login type for the adminuser. ssh or password.

Type: `string`

Default: `"ssh"`

### <a name="input_admin_username"></a> [admin\_username](#input\_admin\_username)

Description: (Optional) Admin user to create for the VM.

Type: `string`

Default: `"adminuser"`

### <a name="input_app_name"></a> [app\_name](#input\_app\_name)

Description: (Optional) The name of the application that the VM is being used for.

Type: `string`

Default: `null`

### <a name="input_create_key_vault"></a> [create\_key\_vault](#input\_create\_key\_vault)

Description: (Optional) Specify if you would like to create a new key vault or use an existing one. One will be created anyway if you specify ssh key creation.

Type: `bool`

Default: `false`

### <a name="input_create_resource_group"></a> [create\_resource\_group](#input\_create\_resource\_group)

Description: (Optional) To specify if you want to create a new resource group or use an existing one

Type: `bool`

Default: `true`

### <a name="input_create_subnet"></a> [create\_subnet](#input\_create\_subnet)

Description: (Optional) Create a new subnet or use an existing one

Type: `bool`

Default: `false`

### <a name="input_environment"></a> [environment](#input\_environment)

Description: (Optional) Environment to be used in the name for the resources

Type: `string`

Default: `null`

### <a name="input_image"></a> [image](#input\_image)

Description: OS Image Reference

Type:

```hcl
object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
```

Default:

```json
{
  "offer": "0001-com-ubuntu-server-jammy",
  "publisher": "Canonical",
  "sku": "22_04-lts",
  "version": "latest"
}
```

### <a name="input_key_vault_name"></a> [key\_vault\_name](#input\_key\_vault\_name)

Description: (Optional) Key Vault to store the private ssh key

Type: `string`

Default: `null`

### <a name="input_key_vault_resource_group_name"></a> [key\_vault\_resource\_group\_name](#input\_key\_vault\_resource\_group\_name)

Description: (Optional) Existing key vault resource group name. If not provided it will attempt to use the var.resource\_group\_name or create a new key vault.

Type: `string`

Default: `null`

### <a name="input_location"></a> [location](#input\_location)

Description: (Optional) The region to deploy the resources to

Type: `string`

Default: `"eastus"`

### <a name="input_network_interface_name"></a> [network\_interface\_name](#input\_network\_interface\_name)

Description: (Optional) The name of the VM network interface. If nothing specified this will be the <vm\_name>-nic.

Type: `string`

Default: `null`

### <a name="input_os_storage_account_type"></a> [os\_storage\_account\_type](#input\_os\_storage\_account\_type)

Description: (Optional) Storage account type for the OS disk

Type: `string`

Default: `"Standard_LRS"`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: (Optional) The name of the resource group to deploy to

Type: `string`

Default: `null`

### <a name="input_single_ssh_key"></a> [single\_ssh\_key](#input\_single\_ssh\_key)

Description: (Optional) Use the same SSH key for all VMs.

Type: `bool`

Default: `true`

### <a name="input_size"></a> [size](#input\_size)

Description: (Optional) SKU Size for the VM.

Type: `string`

Default: `"Standard_B1s"`

### <a name="input_subnet_address_prefix"></a> [subnet\_address\_prefix](#input\_subnet\_address\_prefix)

Description: (Optional) Only required if `create_subnet` = true

Type: `string`

Default: `null`

### <a name="input_subnet_name"></a> [subnet\_name](#input\_subnet\_name)

Description: (Optional) The name of the subnet to create or assign to the network interface

Type: `string`

Default: `null`

### <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id)

Description: (Required) Subscription Id for the deployment

Type: `string`

Default: `null`

### <a name="input_virtual_machine_count"></a> [virtual\_machine\_count](#input\_virtual\_machine\_count)

Description: (Optional) The number of virtual machines to create

Type: `number`

Default: `3`

### <a name="input_virtual_machine_name"></a> [virtual\_machine\_name](#input\_virtual\_machine\_name)

Description: (Optional) The name of the virtual machine to create. If not specified one will be generated for you.

Type: `string`

Default: `null`

### <a name="input_virtual_network_name"></a> [virtual\_network\_name](#input\_virtual\_network\_name)

Description: (Required) Supply a virtual network name that the network interface will use

Type: `string`

Default: `null`

### <a name="input_virtual_network_resource_group_name"></a> [virtual\_network\_resource\_group\_name](#input\_virtual\_network\_resource\_group\_name)

Description: (Required) Specify the virtual network resource group where the specified virtual network resides

Type: `string`

Default: `null`

## Outputs

No outputs.

## Modules

The following Modules are called:

### <a name="module_azure_region"></a> [azure\_region](#module\_azure\_region)

Source: claranet/regions/azurerm

Version: 7.2.0

### <a name="module_naming"></a> [naming](#module\_naming)

Source: Azure/naming/azurerm

Version: 0.4.1

  
<!-- END_TF_DOCS -->    
