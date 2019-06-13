locals {
  hash_suffix = "${substr(sha256(azurerm_resource_group.rg.name), 0, 6)}"
}

# Retrieve AAD User's Object ID
data "external" "aad" {
  count   = "${length(var.key_vault_users)}"
  program = ["bash", "query_aad.sh"]
  query = {
    userid = "${element(var.key_vault_users, count.index)}"
  }
}

# Current Tenant ID
data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "rg" {
  name     = "test_rg"
  location = "West Europe"
}


resource "azurerm_key_vault" "kv" {
  name                = "kv${local.hash_suffix}"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  tenant_id           = "${data.azurerm_client_config.current.tenant_id}"

  sku {
    name = "standard"
  }
}

resource "azurerm_key_vault_access_policy" "policy" {
  count = "${length(var.key_vault_users)}"

  vault_name          = "${azurerm_key_vault.kv.name}"
  resource_group_name = "${azurerm_key_vault.kv.resource_group_name}"

  tenant_id = "${data.azurerm_client_config.current.tenant_id}"
  object_id = "${data.external.aad.*.result.objectId[count.index]}"

  key_permissions = [
    "get",
  ]

  secret_permissions = [
    "get",
  ]
}
