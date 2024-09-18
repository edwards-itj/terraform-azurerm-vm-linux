[![Terraform](https://github.com/edwards-itj/terraform-azurerm-vm-linux/actions/workflows/terraform.yml/badge.svg)](https://github.com/edwards-itj/terraform-azurerm-vm-linux/actions/workflows/terraform.yml)

# Azure Linux VM Module

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.9.5 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.2.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.6.3 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 4.0.6 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_azure_region"></a> [azure\_region](#module\_azure\_region) | claranet/regions/azurerm | 7.2.0 |
| <a name="module_naming"></a> [naming](#module\_naming) | Azure/naming/azurerm | 0.4.1 |

## Resources

| Name | Type |
|------|------|
| [azurerm_key_vault.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault) | resource |
| [azurerm_key_vault_secret.privatekey](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_linux_virtual_machine.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine) | resource |
| [azurerm_network_interface.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | resource |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_ssh_public_key.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/ssh_public_key) | resource |
| [azurerm_subnet.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [random_password.password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [tls_private_key.this](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_key_vault.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault) | data source |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_subnet.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet) | data source |
| [azurerm_virtual_network.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_login_type"></a> [admin\_login\_type](#input\_admin\_login\_type) | (Optional) Set the login type for the adminuser. ssh or password. | `string` | `"ssh"` | no |
| <a name="input_admin_username"></a> [admin\_username](#input\_admin\_username) | (Optional) Admin user to create for the VM. | `string` | `"adminuser"` | no |
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | (Optional) The name of the application that the VM is being used for. | `string` | `null` | no |
| <a name="input_create_key_vault"></a> [create\_key\_vault](#input\_create\_key\_vault) | (Optional) Specify if you would like to create a new key vault or use an existing one. One will be created anyway if you specify ssh key creation. | `bool` | `false` | no |
| <a name="input_create_resource_group"></a> [create\_resource\_group](#input\_create\_resource\_group) | (Optional) To specify if you want to create a new resource group or use an existing one | `bool` | `true` | no |
| <a name="input_create_subnet"></a> [create\_subnet](#input\_create\_subnet) | (Optional) Create a new subnet or use an existing one | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | (Optional) Environment to be used in the name for the resources | `string` | `null` | no |
| <a name="input_image"></a> [image](#input\_image) | OS Image Reference | <pre>object({<br>    publisher = string<br>    offer     = string<br>    sku       = string<br>    version   = string<br>  })</pre> | <pre>{<br>  "offer": "0001-com-ubuntu-server-jammy",<br>  "publisher": "Canonical",<br>  "sku": "22_04-lts",<br>  "version": "latest"<br>}</pre> | no |
| <a name="input_key_vault_name"></a> [key\_vault\_name](#input\_key\_vault\_name) | (Optional) Key Vault to store the private ssh key | `string` | `null` | no |
| <a name="input_key_vault_resource_group_name"></a> [key\_vault\_resource\_group\_name](#input\_key\_vault\_resource\_group\_name) | (Optional) Existing key vault resource group name. If not provided it will attempt to use the var.resource\_group\_name or create a new key vault. | `string` | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | (Optional) The region to deploy the resources to | `string` | `"eastus"` | no |
| <a name="input_network_interface_name"></a> [network\_interface\_name](#input\_network\_interface\_name) | (Optional) The name of the VM network interface. If nothing specified this will be the <vm\_name>-nic. | `string` | `null` | no |
| <a name="input_os_storage_account_type"></a> [os\_storage\_account\_type](#input\_os\_storage\_account\_type) | (Optional) Storage account type for the OS disk | `string` | `"Standard_LRS"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | (Optional) The name of the resource group to deploy to | `string` | `null` | no |
| <a name="input_single_ssh_key"></a> [single\_ssh\_key](#input\_single\_ssh\_key) | (Optional) Use the same SSH key for all VMs. | `bool` | `true` | no |
| <a name="input_size"></a> [size](#input\_size) | (Optional) SKU Size for the VM. | `string` | `"Standard_B1s"` | no |
| <a name="input_subnet_address_prefix"></a> [subnet\_address\_prefix](#input\_subnet\_address\_prefix) | (Optional) Only required if `create_subnet` = true | `string` | `null` | no |
| <a name="input_subnet_name"></a> [subnet\_name](#input\_subnet\_name) | (Optional) The name of the subnet to create or assign to the network interface | `string` | `null` | no |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | (Required) Subscription Id for the deployment | `string` | `null` | no |
| <a name="input_virtual_machine_count"></a> [virtual\_machine\_count](#input\_virtual\_machine\_count) | (Optional) The number of virtual machines to create | `number` | `3` | no |
| <a name="input_virtual_machine_name"></a> [virtual\_machine\_name](#input\_virtual\_machine\_name) | (Optional) The name of the virtual machine to create. If not specified one will be generated for you. | `string` | `null` | no |
| <a name="input_virtual_network_name"></a> [virtual\_network\_name](#input\_virtual\_network\_name) | (Required) Supply a virtual network name that the network interface will use | `string` | `null` | no |
| <a name="input_virtual_network_resource_group_name"></a> [virtual\_network\_resource\_group\_name](#input\_virtual\_network\_resource\_group\_name) | (Required) Specify the virtual network resource group where the specified virtual network resides | `string` | `null` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->