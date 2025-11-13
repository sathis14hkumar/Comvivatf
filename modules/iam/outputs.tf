output "iam_roles" {
  value = {
    "roles" = [
      for role in var.iam_roles : {
        "role" = role
        "members" = var.role_members[role]
      }
    ]
  }
}

output "service_accounts" {
  value = var.service_accounts
}