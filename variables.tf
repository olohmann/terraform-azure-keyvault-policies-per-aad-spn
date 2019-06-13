variable "key_vault_users" {
  description = "Define the list of Key Vault users with their AAD UPNs."
  default = ["oliverlo@microsoft.com", "grkalil@microsoft.com"]
  type = "list"
}
