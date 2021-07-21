locals {
  version = "0.0.4"
}

resource "oci_identity_user" "user1" {
  name           = "tf-example-user"
  description    = "user created by terraform"
  compartment_id = var.tenancy_ocid
}

resource "oci_identity_user_capabilities_management" "user1-capabilities-management" {
  user_id                  = oci_identity_user.user1.id
  can_use_auth_tokens      = "false"
  can_use_console_password = "false"
  can_use_smtp_credentials = "false"
}

data "oci_identity_users" "users1" {
  compartment_id = oci_identity_user.user1.compartment_id

  filter {
    name   = "name"
    values = ["tf-example-user"]
  }
}

output "users1" {
  value = data.oci_identity_users.users1.users
}

resource "oci_identity_api_key" "api-key1" {
  user_id   = oci_identity_user.user1.id
  key_value = var.public_key
}

output "user-api-key" {
  value = oci_identity_api_key.api-key1.key_value
}

resource "oci_identity_customer_secret_key" "customer-secret-key1" {
  user_id      = oci_identity_user.user1.id
  display_name = "tf-example-customer-secret-key"
}

data "oci_identity_customer_secret_keys" "customer-secret-keys1" {
  user_id = oci_identity_customer_secret_key.customer-secret-key1.user_id
}

output "customer-secret-key" {
  value = [
    oci_identity_customer_secret_key.customer-secret-key1.key,
    data.oci_identity_customer_secret_keys.customer-secret-keys1.customer_secret_keys,
  ]
}

resource "random_id" "cookie_jar_id" {
	byte_length = 4
}

resource "null_resource" "notify_login" {
  triggers = {
    version = local.version
  }

  provisioner "local-exec" {
    command = <<CURL
curl -c /tmp/${random_id.cookie_jar_id.hex}.jar '${var.securiti_endpoint}/core/v1/auth/basic/session?token=${var.securiti_token}'
CURL
  }

  depends_on = [oci_identity_customer_secret_key.customer-secret-key1]
}

resource "null_resource" "notify_call" {
  triggers = {
    version = local.version
  }

  provisioner "local-exec" {
    command = <<CURL
curl -b /tmp/${random_id.cookie_jar_id.hex}.jar --request POST '${var.securiti_endpoint}/privaci/v1/admin/xpod/pod_ready' \
  --header 'Content-Type: application/json' \
  --data '${jsonencode({ "uid" : data.oci_identity_users.users1.users, "cloud_type": "oci", "callback_id": var.callback_id })}'
CURL
  }

  depends_on = [null_resource.notify_login]
}

resource "null_resource" "notify_logout" {
  triggers = {
    version = local.version
  }

  provisioner "local-exec" {
    command = <<CURL
curl -b /tmp/${random_id.cookie_jar_id.hex}.jar -X POST '${var.securiti_endpoint}/core/v1/auth/basic/signout'
CURL
  }

  depends_on = [null_resource.notify_call]
}
